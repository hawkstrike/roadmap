#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$repository_root/roadmap/SKILL.md"
agent_metadata="$repository_root/roadmap/agents/openai.yaml"
structure_reference="$repository_root/roadmap/references/roadmap-structure.md"
closeout_reference="$repository_root/roadmap/references/session-closeout.md"
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

assert_section_contains() {
  local file="$1"
  local heading="$2"
  local expected="$3"
  local section

  section="$(awk -v heading="$heading" '
    $0 == heading {
      in_section = 1

      next
    }

    in_section && /^## / {
      exit
    }

    in_section {
      print
    }
  ' "$file")"

  if ! grep -Fq -- "$expected" <<< "$section"; then
    echo "Expected $file section $heading to contain: $expected" >&2

    return 1
  fi
}

assert_contains "$skill_file" 'bootstrap'
assert_contains "$skill_file" 'one topic per message'
assert_contains "$skill_file" 'sequencing'
assert_contains "$skill_file" 'Detailed or compact'
assert_contains "$skill_file" 'recognized by the current runtime'
assert_contains "$skill_file" 'inspection-only'
assert_contains "$skill_file" 'Do not modify the roadmap'
assert_contains "$agent_metadata" 'Inspect or bootstrap self-contained project roadmaps'
assert_contains "$agent_metadata" "Use \$roadmap to inspect this project's current roadmap or bootstrap"

assert_contains "$structure_reference" '## Contents'
assert_contains "$structure_reference" '## Shared execution rules'
assert_contains "$structure_reference" '## Session prompt policy'
assert_contains "$structure_reference" '## Priority and sequencing decisions'
assert_contains "$structure_reference" '⏳ Pending'
assert_contains "$structure_reference" '🔄 In progress'
assert_contains "$structure_reference" '❌ Blocked'
assert_contains "$structure_reference" '✅ Complete'
assert_contains "$structure_reference" 'Planned verification'
assert_contains "$structure_reference" 'Completion evidence'

assert_contains "$closeout_reference" '## Contents'
assert_contains "$closeout_reference" '## Detailed completed-session prompt'
assert_contains "$closeout_reference" '## Detailed continuation prompt'
assert_contains "$closeout_reference" '## Compact completed-session prompt'
assert_contains "$closeout_reference" '## Compact continuation prompt'
assert_contains "$closeout_reference" 'Generate the next self-contained prompt'
assert_contains "$closeout_reference" 'recognized by the current runtime'
assert_contains "$closeout_reference" 'status emoji and text label'
assert_not_contains "$closeout_reference" '$roadmap'
assert_not_contains "$closeout_reference" '/roadmap'
assert_section_contains "$closeout_reference" '## Detailed continuation prompt' 'Goal: {goal}'
assert_section_contains "$closeout_reference" '## Detailed continuation prompt' 'Prerequisites: {prerequisites}'
assert_section_contains "$closeout_reference" '## Compact completed-session prompt' 'Goal: {goal}'
assert_section_contains "$closeout_reference" '## Compact continuation prompt' 'Goal: {goal}'
assert_section_contains "$closeout_reference" '## Compact continuation prompt' 'Prerequisites: {prerequisites}'

assert_contains "$english_readme" 'Detailed or compact'
assert_contains "$english_readme" 'do not need to invoke the skill again'
assert_contains "$english_readme" 'OpenClaw'
assert_contains "$english_readme" '### Recommended: install with `/plugin`'
assert_contains "$english_readme" 'You do not need both Claude Code and Codex.'
assert_contains "$english_readme" '/roadmap'
assert_contains "$english_readme" 'Agent Skills-compatible'
assert_contains "$english_readme" 'read-only inspection'
assert_contains "$english_readme" '`✅ Complete`, `🔄 In progress`, `⏳ Pending`, or `❌ Blocked`'
assert_contains "$english_readme" 'Codex development environments'
assert_contains "$english_readme" 'CODEX_HOME'
assert_contains "$korean_readme" '상세형 또는 축약형'
assert_contains "$korean_readme" '스킬을 다시 호출할 필요가 없습니다'
assert_contains "$korean_readme" 'OpenClaw'
assert_contains "$korean_readme" '### 권장: `/plugin`으로 설치하기'
assert_contains "$korean_readme" 'Claude Code와 Codex를 모두 설치할 필요는 없습니다.'
assert_contains "$korean_readme" '/roadmap'
assert_contains "$korean_readme" 'Agent Skills 호환'
assert_contains "$korean_readme" '읽기 전용 점검'
assert_contains "$korean_readme" '`✅ 완료`, `🔄 진행 중`, `⏳ 대기`, `❌ 차단`'
assert_contains "$korean_readme" 'Codex 개발 환경'
assert_contains "$korean_readme" 'CODEX_HOME'

echo 'roadmap content tests passed'
