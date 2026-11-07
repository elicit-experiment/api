"""Upload any rewritten example, optionally import results, then download Parquet.

ELICIT_API_URL=http://localhost:3000 ELICIT_TOKEN=... python deliver.py \
    01-likert.study.json --results /tmp/results.ndjson --output /tmp/results.zip

The token is read from the environment, never printed. Polling follows async
operation resources; no graph traversal or result pagination is needed.
"""

import argparse
import json
import os

from elicit_study.client import Client

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('definition')
parser.add_argument('--results')
parser.add_argument('--output')
parser.add_argument('--participant', action='append')
parser.add_argument('--idempotency-key', help='Reuse this key to resume an interrupted submission')
args = parser.parse_args()
client = Client(os.environ['ELICIT_API_URL'], os.environ['ELICIT_TOKEN'])
study = client.wait(client.import_study(args.definition, key=args.idempotency_key))
print(json.dumps({'study_id': study['study_id'], 'revision_id': study['revision_id']}))
if args.results:
    key = f'{args.idempotency_key}-results' if args.idempotency_key else None
    client.wait(client.import_results(study['study_id'], study['revision_id'], args.results, key=key))
if args.output:
    operation = client.wait(client.export_results(study['study_id'], study['revision_id'], participants=args.participant))
    client.download(operation, args.output)
    print(args.output)
