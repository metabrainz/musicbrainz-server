#!/usr/bin/env python3

# This script cleans up old image versions pushed to ghcr.io by our
# CI workflow (.github/workflows/ci.yml). The versions can be viewed
# online here:
# https://github.com/metabrainz/musicbrainz-server/pkgs/container/musicbrainz-tests/versions

import os
import sys
import json
import urllib.request
import urllib.error
from datetime import datetime, timedelta

GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
if not GITHUB_TOKEN:
    sys.exit('GITHUB_TOKEN not found in the current environment')

default_headers = {
    'Authorization': f'Bearer {GITHUB_TOKEN}',
    'Accept': 'application/vnd.github.v3+json'
}
versions_base_url = \
    'https://api.github.com/orgs/metabrainz' \
    '/packages/container/musicbrainz-tests/versions'

versions_req = urllib.request.Request(
    versions_base_url,
    method='GET',
    headers=default_headers,
    data=None,
)
versions_res = urllib.request.urlopen(versions_req)
if versions_res.status != 200:
    sys.exit(f'Failed to get image versions: {versions_res.status}')
versions_data = json.loads(versions_res.read().decode('utf-8'))

print('Image versions: ' +
      json.dumps(versions_data, indent=2, sort_keys=True))

# Clean up image versions after 5 days.
# They are primarily useful to keep around in case an individual job that
# uses an image needs to be re-run.

now = datetime.now(datetime.utc)
five_days_ago = now - timedelta(days=5)
do_not_delete = set(('production', 'beta', 'test'))
version_ids_to_delete = []

for version in versions_data:
    created_at = datetime.fromisoformat(version['created_at'])
    if created_at > five_days_ago:
        continue
    metadata = version.get('metadata', {})
    package_type = metadata.get('package_type')
    if package_type != 'container':
        continue
    tags = set((metadata.get('container', {}).get('tags', [])))
    if tags & do_not_delete:
        continue
    version_ids_to_delete.append(version['id'])

if not version_ids_to_delete:
    print('No image versions older than five days')
    sys.exit(0)

for version_id in version_ids_to_delete:
    print(f'Deleting version {version_id}')
    delete_url = f'{versions_base_url}/{version_id}'
    delete_req = urllib.request.Request(
        delete_url,
        method='DELETE',
        headers=default_headers,
        data=None,
    )
    delete_res = urllib.request.urlopen(delete_req)
    if delete_res.status != 200:
        print(f'Failed to delete version: {delete_res.status}',
              file=sys.stderr)
