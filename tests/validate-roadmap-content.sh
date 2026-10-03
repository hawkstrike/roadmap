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
    /^```/ {
      in_fence = !in_fence

      next
    }

    !in_fence && $0 == heading {
      in_section = 1

      next
    }

    in_section && !in_fence && /^## / {
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
assert_contains "$skill_file" 'relevant skills available in the current environment'
assert_contains "$skill_file" 'archive index'
assert_contains "$agent_metadata" 'Inspect or bootstrap self-contained project roadmaps'
assert_contains "$agent_metadata" "Use \$roadmap to inspect this project's current roadmap or bootstrap"

assert_contains "$structure_reference" '## Contents'
assert_contains "$structure_reference" '## Shared execution rules'
assert_contains "$structure_reference" '## Session prompt policy'
assert_contains "$structure_reference" '## Active roadmap and archives'
assert_contains "$structure_reference" '## Priority and sequencing decisions'
assert_contains "$structure_reference" '## Completed work archives'
assert_contains "$structure_reference" 'link directly to every archive document'
assert_contains "$structure_reference" 'Group archived sessions by a coherent phase or track'
assert_contains "$structure_reference" 'Change history records material changes to the plan'
assert_contains "$structure_reference" '🟡 Pending'
assert_contains "$structure_reference" '🔵 In progress'
assert_contains "$structure_reference" '🔴 Blocked'
assert_contains "$structure_reference" '🟢 Complete'
assert_contains "$structure_reference" 'Planned verification'
assert_contains "$structure_reference" 'Completion evidence'
assert_contains "$structure_reference" 'continue to use relevant skills'
assert_not_contains "$structure_reference" 'unrelated global skills'

assert_contains "$closeout_reference" '## Contents'
assert_contains "$closeout_reference" '## Detailed completed-session prompt'
assert_contains "$closeout_reference" '## Detailed continuation prompt'
assert_contains "$closeout_reference" '## Compact completed-session prompt'
assert_contains "$closeout_reference" '## Compact continuation prompt'
assert_contains "$closeout_reference" 'Generate the next self-contained prompt'
assert_contains "$closeout_reference" 'recognized by the current runtime'
assert_contains "$closeout_reference" 'status emoji and text label'
assert_contains "$closeout_reference" 'archive index links'
assert_contains "$closeout_reference" 'only when the plan itself changed'
assert_not_contains "$closeout_reference" 'another skill invocation'
assert_not_contains "$closeout_reference" '$roadmap'
assert_not_contains "$closeout_reference" '/roadmap'
assert_section_contains "$closeout_reference" '## Detailed completed-session prompt' 'Use relevant skills available in the current environment'
assert_section_contains "$closeout_reference" '## Detailed continuation prompt' 'Goal: {goal}'
assert_section_contains "$closeout_reference" '## Detailed continuation prompt' 'Prerequisites: {prerequisites}'
assert_section_contains "$closeout_reference" '## Detailed continuation prompt' 'Use relevant skills available in the current environment'
assert_section_contains "$closeout_reference" '## Compact completed-session prompt' 'Goal: {goal}'
assert_section_contains "$closeout_reference" '## Compact completed-session prompt' 'Use relevant skills available in the current environment'
assert_section_contains "$closeout_reference" '## Compact continuation prompt' 'Goal: {goal}'
assert_section_contains "$closeout_reference" '## Compact continuation prompt' 'Prerequisites: {prerequisites}'
assert_section_contains "$closeout_reference" '## Compact continuation prompt' 'Use relevant skills available in the current environment'

assert_contains "$english_readme" 'Detailed or compact'
assert_contains "$english_readme" 'do not need to invoke the skill again'
assert_contains "$english_readme" 'OpenClaw'
assert_contains "$english_readme" '### Recommended: install with `/plugin`'
assert_contains "$english_readme" 'You do not need both Claude Code and Codex.'
assert_contains "$english_readme" '/roadmap'
assert_contains "$english_readme" 'Agent Skills-compatible'
assert_contains "$english_readme" 'read-only inspection'
assert_contains "$english_readme" '`🟢 Complete`, `🔵 In progress`, `🟡 Pending`, or `🔴 Blocked`'
assert_contains "$english_readme" 'links directly to every archive document'
assert_contains "$english_readme" 'material plan changes rather than routine session completion'
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
assert_contains "$korean_readme" '`🟢 완료`, `🔵 진행 중`, `🟡 대기`, `🔴 차단`'
assert_contains "$korean_readme" '모든 아카이브 문서로 직접 연결'
assert_contains "$korean_readme" '일상적인 세션 완료가 아니라 중요한 계획 변경만 기록'
assert_contains "$korean_readme" 'Codex 개발 환경'
assert_contains "$korean_readme" 'CODEX_HOME'

# The startable-session area must precede background in the default output layout.
layout="$(awk '/^# \{Project name\} roadmap$/ { in_layout = 1; next } in_layout && /^```$/ { exit } in_layout && /^## / { print }' "$structure_reference")"
expected_top="$(printf '%s\n' '## Current and next sessions' '## Copyable session prompts')"

if [[ "$(head -n 2 <<< "$layout")" != "$expected_top" ]]; then
  echo 'Expected startable sessions and copyable prompts before roadmap background' >&2

  exit 1
fi

assert_section_contains "$structure_reference" '## Startable sessions and copyable prompts' 'first body sections'
assert_section_contains "$structure_reference" '## Startable sessions and copyable prompts' 'fenced `text` code block'
assert_section_contains "$structure_reference" '## Startable sessions and copyable prompts' 'prerequisites are satisfied'
assert_section_contains "$structure_reference" '## Startable sessions and copyable prompts' 'no session is startable'
assert_section_contains "$structure_reference" '## Phase placement for new sessions' 'inspect existing phases and their archive index'
assert_section_contains "$structure_reference" '## Phase placement for new sessions' 'Reuse a related phase'
assert_section_contains "$structure_reference" '## Phase placement for new sessions' 'only when no existing phase fits'
assert_section_contains "$structure_reference" '## Active roadmap and archives' 'one Markdown archive file per phase'
assert_section_contains "$structure_reference" '## Active roadmap and archives' 'Before removing details'
assert_section_contains "$structure_reference" '## Active roadmap and archives' 'completed sessions from a still-active phase'
assert_section_contains "$structure_reference" '## Shared execution rules' 'top session and prompt sections'
assert_contains "$skill_file" 'reuse a related phase'

for heading in '## Detailed completed-session prompt' '## Detailed continuation prompt' '## Compact completed-session prompt' '## Compact continuation prompt'; do
  assert_section_contains "$closeout_reference" "$heading" 'top session and prompt sections'
  assert_section_contains "$closeout_reference" "$heading" 'reuse a related phase'
  assert_section_contains "$closeout_reference" "$heading" '🟡 Pending, 🔵 In progress, 🔴 Blocked, 🟢 Complete'
done

assert_contains "$english_readme" 'top of the roadmap'
assert_contains "$korean_readme" '로드맵 상단'

echo 'roadmap content tests passed'
