#!/usr/bin/env bash

set -euo pipefail

skill_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
home_directory="${HOME:?HOME is required}"
targets=(
  "$home_directory/.agents/skills/roadmap"
  "$home_directory/.claude/skills/roadmap"
)
staging_directories=()
backup_directories=()
target_existed=()
replacement_count=0
transaction_complete=0

validate_target() {
  local target="$1"

  if [[ ! -e "$target" ]]; then
    return
  fi

  if [[ ! -d "$target" || ! -f "$target/SKILL.md" ]]; then
    echo "Refusing to replace non-roadmap skill: $target" >&2
    return 1
  fi

  if ! awk '
    NR == 1 {
      if ($0 != "---") {
        exit 1
      }

      next
    }

    $0 == "---" {
      frontmatter_closed = 1
      exit name_is_roadmap ? 0 : 1
    }

    /^name:[[:space:]]*/ {
      name_value = $0
      sub(/^name:[[:space:]]+/, "", name_value)
      sub(/[[:space:]]*$/, "", name_value)

      if (name_value == "\"roadmap\"" || name_value == "\047roadmap\047") {
        name_value = "roadmap"
      }

      if (name_value != "roadmap") {
        exit 1
      }

      name_is_roadmap = 1
    }

    END {
      if (!frontmatter_closed || !name_is_roadmap) {
        exit 1
      }
    }
  ' "$target/SKILL.md"; then
    echo "Refusing to replace non-roadmap skill: $target" >&2
    return 1
  fi
}

prepare_target() {
  local target_index="$1"
  local target="${targets[$target_index]}"
  local parent
  local staging

  parent="$(dirname "$target")"
  mkdir -p "$parent"
  staging_directories[$target_index]="$(mktemp -d "$parent/.roadmap-install.XXXXXX")"
  staging="${staging_directories[$target_index]}"

  cp -R "$skill_directory/." "$staging/"

  if [[ -e "$target" ]]; then
    backup_directories[$target_index]="$(mktemp -d "$parent/.roadmap-backup.XXXXXX")"
    target_existed[$target_index]=1
    cp -R "$target/." "${backup_directories[$target_index]}/"
  else
    backup_directories[$target_index]=''
    target_existed[$target_index]=0
  fi
}

cleanup() {
  local exit_status=$?
  local target_index

  trap - EXIT INT TERM
  set +e

  if [[ "$transaction_complete" -eq 0 ]]; then
    for ((target_index = replacement_count - 1; target_index >= 0; target_index -= 1)); do
      rm -rf "${targets[$target_index]}"

      if [[ "${target_existed[$target_index]}" -eq 1 ]]; then
        if mv "${backup_directories[$target_index]}" "${targets[$target_index]}"; then
          backup_directories[$target_index]=''
        else
          echo "Failed to restore roadmap skill backup: ${backup_directories[$target_index]}" >&2
          backup_directories[$target_index]=''
        fi
      fi
    done
  fi

  for staging in "${staging_directories[@]}"; do
    if [[ -n "$staging" ]]; then
      rm -rf "$staging"
    fi
  done

  for backup in "${backup_directories[@]}"; do
    if [[ -n "$backup" ]]; then
      rm -rf "$backup"
    fi
  done

  exit "$exit_status"
}

trap 'exit 130' INT
trap 'exit 143' TERM
trap cleanup EXIT

for target in "${targets[@]}"; do
  validate_target "$target"
done

for ((target_index = 0; target_index < ${#targets[@]}; target_index += 1)); do
  prepare_target "$target_index"
done

for ((target_index = 0; target_index < ${#targets[@]}; target_index += 1)); do
  replacement_count=$((target_index + 1))
  rm -rf "${targets[$target_index]}"
  mv "${staging_directories[$target_index]}" "${targets[$target_index]}"
  staging_directories[$target_index]=''
done

transaction_complete=1

for target in "${targets[@]}"; do
  echo "Installed roadmap skill to $target"
done
