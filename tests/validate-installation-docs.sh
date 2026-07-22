#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
english_readme="$repository_root/README.md"
korean_readme="$repository_root/README.ko.md"

assert_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    echo "Expected $file to contain: $expected" >&2

    return 1
  fi
}

assert_contains "$english_readme" '### Option 1: Git clone with directory links'
assert_contains "$english_readme" '#### macOS and Linux'
assert_contains "$english_readme" 'mkdir -p "$(dirname "$roadmap_repository")"'
assert_contains "$english_readme" 'ln -s'
assert_contains "$english_readme" '#### Windows PowerShell'
assert_contains "$english_readme" 'New-Item -ItemType Junction'
assert_contains "$english_readme" 'git pull --ff-only'
assert_contains "$english_readme" '### Option 2: GitHub with `npx skills`'
assert_contains "$english_readme" 'npx skills add hawkstrike/roadmap --skill roadmap'
assert_contains "$english_readme" 'npx skills update roadmap'
assert_contains "$english_readme" 'The command is `npx skills`'
assert_contains "$english_readme" 'uses a directory junction on Windows and falls back to copying'
assert_contains "$english_readme" 'Do not keep two installations named `roadmap`'
assert_contains "$english_readme" 'bash tests/validate-installation-docs.sh'

assert_contains "$korean_readme" '### 방법 1: Git 저장소 복제와 디렉터리 링크'
assert_contains "$korean_readme" '#### macOS와 Linux'
assert_contains "$korean_readme" 'mkdir -p "$(dirname "$roadmap_repository")"'
assert_contains "$korean_readme" 'ln -s'
assert_contains "$korean_readme" '#### Windows PowerShell'
assert_contains "$korean_readme" 'New-Item -ItemType Junction'
assert_contains "$korean_readme" 'git pull --ff-only'
assert_contains "$korean_readme" '### 방법 2: GitHub와 `npx skills`'
assert_contains "$korean_readme" 'npx skills add hawkstrike/roadmap --skill roadmap'
assert_contains "$korean_readme" 'npx skills update roadmap'
assert_contains "$korean_readme" '명령 이름은 `npx skills`'
assert_contains "$korean_readme" 'Windows에서는 디렉터리 정션을 사용하고 링크 생성에 실패하면 복사 방식으로 전환합니다'
assert_contains "$korean_readme" '`roadmap`이라는 같은 이름의 설치본을 두 곳에 남겨 두지 마세요'
assert_contains "$korean_readme" 'bash tests/validate-installation-docs.sh'

echo 'installation documentation tests passed'
