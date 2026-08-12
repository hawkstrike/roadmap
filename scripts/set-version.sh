#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
requested_version="${1:-}"

if [[ -z "$requested_version" ]]; then
  echo 'Usage: ./scripts/set-version.sh patch|minor|major|<version>|--check|--check-tag <tag>' >&2

  exit 1
fi

if [[ "$requested_version" == '--check-tag' ]]; then
  if [[ "$#" -ne 2 ]]; then
    echo 'Usage: ./scripts/set-version.sh --check-tag <tag>' >&2

    exit 1
  fi

  requested_version="$requested_version:${2}"
elif [[ "$#" -ne 1 ]]; then
  echo 'Usage: ./scripts/set-version.sh patch|minor|major|<version>|--check|--check-tag <tag>' >&2

  exit 1
fi

python3 - "$repository_root" "$requested_version" <<'PYTHON'
import json
import os
import pathlib
import re
import sys
import tempfile

repository_root = pathlib.Path(sys.argv[1])
requested_version = sys.argv[2]
version_file = repository_root / 'VERSION'
manifest_paths = (
    repository_root / '.claude-plugin/plugin.json',
    repository_root / '.claude-plugin/marketplace.json',
    repository_root / '.codex-plugin/plugin.json',
)
semantic_version_pattern = re.compile(r'^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$')


def read_manifest_version(manifest_path, manifest):
    if manifest_path.name == 'marketplace.json':
        return manifest['plugins'][0]['version']

    return manifest['version']


def set_manifest_version(manifest_path, manifest, version):
    if manifest_path.name == 'marketplace.json':
        manifest['plugins'][0]['version'] = version
    else:
        manifest['version'] = version


def replace_file(path, content):
    file_descriptor, temporary_path = tempfile.mkstemp(dir=path.parent)

    try:
        with os.fdopen(file_descriptor, 'w') as temporary_file:
            temporary_file.write(content)

        os.replace(temporary_path, path)
    except BaseException:
        if os.path.exists(temporary_path):
            os.unlink(temporary_path)

        raise


current_version = version_file.read_text().strip()
current_match = semantic_version_pattern.fullmatch(current_version)

if current_match is None:
    raise SystemExit(f'Invalid VERSION value: {current_version}')

manifests = {}

for manifest_path in manifest_paths:
    manifest = json.loads(manifest_path.read_text())
    manifest_version = read_manifest_version(manifest_path, manifest)

    if manifest_version != current_version:
        raise SystemExit(
            f'{manifest_path.relative_to(repository_root)} version {manifest_version} '
            f'does not match VERSION {current_version}'
        )

    manifests[manifest_path] = manifest

if requested_version == '--check':
    print(f'Version {current_version} is consistent')

    raise SystemExit(0)

if requested_version.startswith('--check-tag:'):
    release_tag = requested_version.removeprefix('--check-tag:')
    expected_tag = f'v{current_version}'

    if release_tag != expected_tag:
        raise SystemExit(f'Release tag {release_tag} does not match VERSION {current_version}')

    print(f'Release tag {release_tag} matches VERSION')

    raise SystemExit(0)

if requested_version in ('patch', 'minor', 'major'):
    major_version, minor_version, patch_version = map(int, current_match.groups())

    if requested_version == 'patch':
        patch_version += 1
    elif requested_version == 'minor':
        minor_version += 1
        patch_version = 0
    else:
        major_version += 1
        minor_version = 0
        patch_version = 0

    next_version = f'{major_version}.{minor_version}.{patch_version}'
else:
    if semantic_version_pattern.fullmatch(requested_version) is None:
        raise SystemExit(f'Invalid semantic version: {requested_version}')

    next_version = requested_version

serialized_manifests = {}

for manifest_path, manifest in manifests.items():
    set_manifest_version(manifest_path, manifest, next_version)
    serialized_manifests[manifest_path] = json.dumps(manifest, indent=2) + '\n'

replace_file(version_file, f'{next_version}\n')

for manifest_path, content in serialized_manifests.items():
    replace_file(manifest_path, content)

print(f'Updated roadmap version from {current_version} to {next_version}')
PYTHON
