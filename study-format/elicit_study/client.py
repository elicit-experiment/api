"""Small synchronous Python client for the asynchronous delivery API."""

import json
import hashlib
import os
import tempfile
import time
import uuid
from pathlib import Path
from urllib.parse import urljoin, urlsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener


def _origin(url):
    parsed = urlsplit(url)
    return parsed.scheme, parsed.hostname, parsed.port or (443 if parsed.scheme == 'https' else 80)


class _SafeRedirect(HTTPRedirectHandler):
    def redirect_request(self, request, response, code, message, headers, url):
        redirected = super().redirect_request(request, response, code, message, headers, url)
        if redirected is not None and _origin(request.full_url) != _origin(url):
            redirected.remove_header('Authorization')
        return redirected


class Client:
    def __init__(self, base_url, token, *, timeout=60):
        self.base_url = base_url.rstrip('/') + '/'
        if urlsplit(self.base_url).scheme not in ('http', 'https'):
            raise ValueError('An HTTP(S) API base URL is required')
        self.token = token
        self.timeout = timeout
        self.opener = build_opener(_SafeRedirect())

    def _request(self, path, *, data=None, key=None, content_type='application/json'):
        url = urljoin(self.base_url, path)
        headers = {'Accept': 'application/json'}
        if _origin(url) == _origin(self.base_url):
            headers['Authorization'] = f'Bearer {self.token}'
        if data is not None:
            headers['Content-Type'] = content_type
        if key:
            headers['Idempotency-Key'] = key
        if isinstance(data, Path):
            headers['Content-Length'] = str(data.stat().st_size)
            with data.open('rb') as source:
                return self.opener.open(Request(url, data=source, headers=headers, method='POST'), timeout=self.timeout)
        return self.opener.open(Request(url, data=data, headers=headers), timeout=self.timeout)

    def submit(self, path, document, *, key=None, content_type='application/json'):
        with self._request(path, data=document, key=key or str(uuid.uuid4()), content_type=content_type) as response:
            return json.load(response)

    def wait(self, operation, *, timeout=1800, interval=1):
        deadline = time.monotonic() + timeout
        while operation['status'] in ('queued', 'running'):
            if time.monotonic() >= deadline:
                raise TimeoutError(f"Operation {operation['id']} is still processing; resume polling its self link")
            time.sleep(interval)
            with self._request(operation['links']['self']) as response:
                operation = json.load(response)
        if operation['status'] != 'succeeded':
            raise ValueError(json.dumps(operation.get('diagnostics', [])))
        return operation

    def import_study(self, document, *, key=None):
        return self.submit('/api/v2/study-imports', Path(document), key=key)

    def import_results(self, study_id, revision_id, document, *, key=None):
        return self.submit(f'/api/v2/studies/{study_id}/revisions/{revision_id}/result-imports', Path(document), key=key, content_type='application/x-ndjson')

    def export_results(self, study_id, revision_id, *, participants=None, key=None):
        options = {} if participants is None else {'participant_ids': participants}
        return self.submit(f'/api/v2/studies/{study_id}/revisions/{revision_id}/result-exports', json.dumps(options).encode(), key=key)

    def download(self, operation, destination):
        # Refresh operation metadata so signed object URLs are freshly issued.
        with self._request(operation['links']['self']) as response:
            operation = json.load(response)
        if operation['status'] != 'succeeded':
            raise ValueError('Operation has not succeeded')
        artifact = operation['artifacts'][0]
        destination = Path(destination)
        with tempfile.NamedTemporaryFile(dir=destination.parent, delete=False) as output:
            temporary = Path(output.name)
            try:
                digest = hashlib.sha256()
                with self._request(artifact['download_url']) as response:
                    for chunk in iter(lambda: response.read(1024 * 1024), b''):
                        digest.update(chunk)
                        output.write(chunk)
                if digest.hexdigest() != operation['result']['archive_sha256']:
                    raise ValueError('Downloaded archive checksum does not match')
                output.flush()
                # Atomic publication without overwriting an existing file.
                os.link(temporary, destination)
            finally:
                temporary.unlink(missing_ok=True)
        return destination
