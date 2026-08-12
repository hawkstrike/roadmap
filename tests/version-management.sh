#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version_script="$repository_root/scripts/set-version.sh"
temporary_root="$(mktemp -d)"
initial_version="$(cat "$repository_root/VERSION")"
IFS='.' read -r initial_major_version initial_minor_version initial_patch_version <<< "$initial_version"

cleanup() {
  rm -rf "$temporary_root"
}

trap cleanup EXIT

create_fixture() {
  local fixture_root="$1"

  mkdir -p \
    "$fixture_root/scripts" \
    "$fixture_root/.claude-plugin" \
    "$fixture_root/.codex-plugin"
  cp "$version_script" "$fixture_root/scripts/set-version.sh"
  cp "$repository_root/VERSION" "$fixture_root/VERSION"
  cp "$repository_root/.claude-plugin/plugin.json" "$fixture_root/.claude-plugin/plugin.json"
  cp "$repository_root/.claude-plugin/marketplace.json" "$fixture_root/.claude-plugin/marketplace.json"
  cp "$repository_root/.codex-plugin/plugin.json" "$fixture_root/.codex-plugin/plugin.json"
}

assert_version() {
  local fixture_root="$1"
  local expected_version="$2"

  python3 - "$fixture_root" "$expected_version" <<'PYTHON'
import json
import pathlib
import sys

fixture_root = pathlib.Path(sys.argv[1])
expected_version = sys.argv[2]

assert fixture_root.joinpath('VERSION').read_text().strip() == expected_version

for manifest_path in (
    fixture_root / '.claude-plugin/plugin.json',
    fixture_root / '.claude-plugin/marketplace.json',
    fixture_root / '.codex-plugin/plugin.json',
):
    manifest = json.loads(manifest_path.read_text())
    version = (
        manifest['plugins'][0]['version']
        if manifest_path.name == 'marketplace.json'
        else manifest['version']
    )
    assert version == expected_version, manifest_path
PYTHON
}

bump_versions() {
  local fixture_root="$temporary_root/bump"

  create_fixture "$fixture_root"

  "$fixture_root/scripts/set-version.sh" patch
  assert_version "$fixture_root" "$initial_major_version.$initial_minor_version.$((initial_patch_version + 1))"

  "$fixture_root/scripts/set-version.sh" minor
  assert_version "$fixture_root" "$initial_major_version.$((initial_minor_version + 1)).0"

  "$fixture_root/scripts/set-version.sh" major
  assert_version "$fixture_root" "$((initial_major_version + 1)).0.0"

  "$fixture_root/scripts/set-version.sh" 3.4.5
  assert_version "$fixture_root" '3.4.5'
}

reject_invalid_version() {
  local fixture_root="$temporary_root/invalid"
  local before_checksum
  local after_checksum

  create_fixture "$fixture_root"
  before_checksum="$(find "$fixture_root" -type f -exec shasum {} + | sort | shasum)"

  if "$fixture_root/scripts/set-version.sh" '1.2' > "$fixture_root/output.log" 2>&1; then
    echo 'Expected invalid version to fail' >&2

    return 1
  fi

  rm "$fixture_root/output.log"
  after_checksum="$(find "$fixture_root" -type f -exec shasum {} + | sort | shasum)"
  test "$before_checksum" = "$after_checksum"
  assert_version "$fixture_root" "$initial_version"
}

reject_inconsistent_manifests() {
  local fixture_root="$temporary_root/inconsistent"

  create_fixture "$fixture_root"
  python3 - "$fixture_root/.codex-plugin/plugin.json" <<'PYTHON'
import json
import pathlib
import sys

manifest_path = pathlib.Path(sys.argv[1])
manifest = json.loads(manifest_path.read_text())
manifest['version'] = '9.9.9'
manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
PYTHON

  if "$fixture_root/scripts/set-version.sh" patch > "$fixture_root/output.log" 2>&1; then
    echo 'Expected inconsistent manifests to fail' >&2

    return 1
  fi

  grep -q 'does not match VERSION' "$fixture_root/output.log"
  test "$(cat "$fixture_root/VERSION")" = "$initial_version"
}

validate_release_tag() {
  local fixture_root="$temporary_root/tag"

  create_fixture "$fixture_root"
  "$fixture_root/scripts/set-version.sh" --check
  "$fixture_root/scripts/set-version.sh" --check-tag "v$initial_version"

  if "$fixture_root/scripts/set-version.sh" --check-tag v99.99.99 > "$fixture_root/output.log" 2>&1; then
    echo 'Expected mismatched release tag to fail' >&2

    return 1
  fi

  grep -q 'does not match VERSION' "$fixture_root/output.log"
}

bump_versions
reject_invalid_version
reject_inconsistent_manifests
validate_release_tag

echo 'version management tests passed'
