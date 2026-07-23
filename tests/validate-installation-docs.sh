#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
english_readme="$repository_root/README.md"
korean_readme="$repository_root/README.ko.md"

assert_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq -- "$expected" "$file"; then
    echo "Expected $file to contain: $expected" >&2

    return 1
  fi
}

assert_not_contains() {
  local file="$1"
  local unexpected="$2"

  if grep -Fq -- "$unexpected" "$file"; then
    echo "Expected $file not to contain: $unexpected" >&2

    return 1
  fi
}

assert_contains "$english_readme" '### Recommended: install with `/plugin`'
assert_contains "$english_readme" '#### Codex'
assert_contains "$english_readme" '#### Claude Code'
assert_contains "$english_readme" 'hawkstrike/roadmap'
assert_contains "$english_readme" 'Install only the client or clients you use.'
assert_contains "$english_readme" '### Alternative: GitHub with `npx skills`'
assert_contains "$english_readme" 'npx skills add hawkstrike/roadmap --skill roadmap'
assert_contains "$english_readme" 'npx skills update roadmap'
assert_contains "$english_readme" 'The command is `npx skills`'
assert_contains "$english_readme" 'bash tests/validate-installation-docs.sh'
assert_not_contains "$english_readme" '#### macOS and Linux'
assert_not_contains "$english_readme" '#### Windows PowerShell'
assert_not_contains "$english_readme" '--agent codex --agent claude-code'

assert_contains "$korean_readme" '### 권장: `/plugin`으로 설치하기'
assert_contains "$korean_readme" '#### Codex'
assert_contains "$korean_readme" '#### Claude Code'
assert_contains "$korean_readme" 'hawkstrike/roadmap'
assert_contains "$korean_readme" '사용하는 도구에만 각각 설치하면 됩니다.'
assert_contains "$korean_readme" '### 대안: GitHub와 `npx skills`'
assert_contains "$korean_readme" 'npx skills add hawkstrike/roadmap --skill roadmap'
assert_contains "$korean_readme" 'npx skills update roadmap'
assert_contains "$korean_readme" '명령 이름은 `npx skills`'
assert_contains "$korean_readme" 'bash tests/validate-installation-docs.sh'
assert_not_contains "$korean_readme" '#### macOS와 Linux'
assert_not_contains "$korean_readme" '#### Windows PowerShell'
assert_not_contains "$korean_readme" '--agent codex --agent claude-code'

python3 - "$repository_root" <<'PYTHON'
import json
import pathlib
import sys

repository_root = pathlib.Path(sys.argv[1])

for manifest_path in (
    repository_root / '.codex-plugin/plugin.json',
    repository_root / '.claude-plugin/plugin.json',
):
    manifest = json.loads(manifest_path.read_text())
    assert manifest['name'] == 'roadmap'
    assert manifest['version'] == '1.0.0'
    assert manifest['skills'] == './roadmap/'

codex_marketplace = json.loads(
    (repository_root / '.agents/plugins/marketplace.json').read_text()
)
assert codex_marketplace['name'] == 'roadmap'
assert codex_marketplace['plugins'][0]['name'] == 'roadmap'
assert codex_marketplace['plugins'][0]['source']['path'] == './'

claude_marketplace = json.loads(
    (repository_root / '.claude-plugin/marketplace.json').read_text()
)
assert claude_marketplace['name'] == 'roadmap'
assert claude_marketplace['plugins'][0]['name'] == 'roadmap'
assert claude_marketplace['plugins'][0]['source'] == './'
PYTHON

echo 'installation documentation tests passed'
