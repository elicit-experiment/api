import hashlib
import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import Mock
from urllib.request import Request

from elicit_study.client import Client, _SafeRedirect


class ClientTests(unittest.TestCase):
    def client(self, payload=b'parquet-archive'):
        client = Client('https://api.example/', 'test-token')
        operation = {
            'status': 'succeeded', 'links': {'self': 'https://api.example/api/v2/study_operations/1'},
            'artifacts': [{'download_url': 'https://storage.example/archive?signature=example'}],
            'result': {'archive_sha256': hashlib.sha256(b'parquet-archive').hexdigest()},
        }
        calls = []

        def respond(request, timeout):
            calls.append(request)
            return io.BytesIO(json.dumps(operation).encode() if len(calls) == 1 else payload)

        client.opener = Mock(open=respond)
        return client, operation, calls

    def test_signed_storage_download_does_not_receive_api_credentials(self):
        client, operation, calls = self.client()
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / 'results.zip'
            client.download(operation, target)
            self.assertEqual(target.read_bytes(), b'parquet-archive')
        self.assertEqual(calls[0].get_header('Authorization'), 'Bearer test-token')
        self.assertIsNone(calls[1].get_header('Authorization'))

    def test_corrupt_download_is_not_published(self):
        client, operation, _ = self.client(b'corrupt')
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                client.download(operation, Path(directory) / 'results.zip')
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_existing_download_is_never_overwritten(self):
        client, operation, _ = self.client()
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / 'results.zip'
            target.write_bytes(b'existing')
            with self.assertRaises(FileExistsError):
                client.download(operation, target)
            self.assertEqual(target.read_bytes(), b'existing')

    def test_cross_origin_redirect_drops_authorization(self):
        request = Request('https://api.example/download', headers={'Authorization': 'Bearer test-token'})
        redirected = _SafeRedirect().redirect_request(request, None, 302, 'Found', {}, 'https://storage.example/archive')
        self.assertIsNone(redirected.get_header('Authorization'))


if __name__ == '__main__':
    unittest.main()
