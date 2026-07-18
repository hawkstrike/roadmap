#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
install_script="$repository_root/roadmap/scripts/install.sh"
temporary_root="$(mktemp -d)"

cleanup() {
  rm -rf "$temporary_root"
}

trap cleanup EXIT

create_failing_move() {
  local home_directory="$1"

  mkdir -p "$home_directory/bin"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    '' \
    'if [[ "$1" == "$HOME/.claude/skills/.roadmap-install."* && "$2" == "$HOME/.claude/skills/roadmap" ]]; then' \
    '  exit 1' \
    'fi' \
    '' \
    'exec "$REAL_MV" "$@"' > "$home_directory/bin/mv"
  chmod +x "$home_directory/bin/mv"
}

create_signaling_move() {
  local home_directory="$1"

  mkdir -p "$home_directory/bin"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    '' \
    'if [[ "$1" == "$HOME/.claude/skills/.roadmap-install."* && "$2" == "$HOME/.claude/skills/roadmap" ]]; then' \
    '  kill -s "$INJECT_SIGNAL" "$PPID"' \
    '  exit 0' \
    'fi' \
    '' \
    'exec "$REAL_MV" "$@"' > "$home_directory/bin/mv"
  chmod +x "$home_directory/bin/mv"
}

standard_installation() {
  local home_directory="$temporary_root/standard"
  local target

  HOME="$home_directory" bash "$install_script"
  HOME="$home_directory" bash "$install_script"

  for target in \
    "$home_directory/.agents/skills/roadmap" \
    "$home_directory/.claude/skills/roadmap"; do
    test -f "$target/SKILL.md"
    test -f "$target/agents/openai.yaml"
    test -f "$target/references/roadmap-structure.md"
    test -f "$target/references/session-closeout.md"
    test -f "$target/scripts/install.sh"
    diff -qr "$repository_root/roadmap" "$target"
  done
}

conflict_rejection() {
  local home_directory="$temporary_root/conflict"
  local conflict_target="$home_directory/.agents/skills/roadmap"

  mkdir -p "$conflict_target"
  printf '%s\n' \
    '---' \
    'name: another-skill' \
    'description: conflict fixture' \
    '---' \
    '' \
    'name: roadmap' > "$conflict_target/SKILL.md"

  if HOME="$home_directory" bash "$install_script" > "$home_directory/output.log" 2>&1; then
    echo 'Expected conflicting installation to fail' >&2
    return 1
  fi

  grep -q 'Refusing to replace non-roadmap skill' "$home_directory/output.log"
  grep -q '^name: another-skill$' "$conflict_target/SKILL.md"
  test ! -e "$home_directory/.claude/skills/roadmap"
}

quoted_frontmatter_names() {
  local name_variant
  local variant_index=0

  for name_variant in 'name: "roadmap"' "name: 'roadmap'"; do
    local home_directory="$temporary_root/quoted-$variant_index"
    local target="$home_directory/.agents/skills/roadmap"

    mkdir -p "$target"
    printf '%s\n' \
      '---' \
      "$name_variant" \
      'description: quoted name fixture' \
      '---' > "$target/SKILL.md"

    HOME="$home_directory" bash "$install_script"
    diff -qr "$repository_root/roadmap" "$target"

    variant_index=$((variant_index + 1))
  done
}

existing_installation_rollback() {
  local home_directory="$temporary_root/existing-rollback"
  local agents_target="$home_directory/.agents/skills/roadmap"
  local claude_target="$home_directory/.claude/skills/roadmap"
  local real_move

  HOME="$home_directory" bash "$install_script"
  printf '%s\n' 'original agents state' > "$agents_target/original-state.txt"
  printf '%s\n' 'original claude state' > "$claude_target/original-state.txt"
  cp -R "$agents_target" "$home_directory/expected-agents"
  cp -R "$claude_target" "$home_directory/expected-claude"
  create_failing_move "$home_directory"
  real_move="$(command -v mv)"

  if HOME="$home_directory" REAL_MV="$real_move" PATH="$home_directory/bin:$PATH" \
    bash "$install_script" > "$home_directory/output.log" 2>&1; then
    echo 'Expected second-target replacement to fail' >&2
    return 1
  fi

  diff -qr "$home_directory/expected-agents" "$agents_target"
  diff -qr "$home_directory/expected-claude" "$claude_target"
  test -z "$(find "$home_directory" \( -name '.roadmap-install.*' -o -name '.roadmap-backup.*' -o -name 'roadmap.backup.*' \) -print)"
}

first_installation_rollback() {
  local home_directory="$temporary_root/first-rollback"
  local real_move

  create_failing_move "$home_directory"
  real_move="$(command -v mv)"

  if HOME="$home_directory" REAL_MV="$real_move" PATH="$home_directory/bin:$PATH" \
    bash "$install_script" > "$home_directory/output.log" 2>&1; then
    echo 'Expected second-target replacement to fail' >&2
    return 1
  fi

  test ! -e "$home_directory/.agents/skills/roadmap"
  test ! -e "$home_directory/.claude/skills/roadmap"
  test -z "$(find "$home_directory" \( -name '.roadmap-install.*' -o -name '.roadmap-backup.*' -o -name 'roadmap.backup.*' \) -print)"
}

signal_rollback() {
  local signal="$1"
  local expected_exit_status="$2"
  local installation_state="$3"
  local home_directory="$temporary_root/signal-$signal-$installation_state"
  local agents_target="$home_directory/.agents/skills/roadmap"
  local claude_target="$home_directory/.claude/skills/roadmap"
  local real_move
  local exit_status

  if [[ "$installation_state" == 'existing' ]]; then
    HOME="$home_directory" bash "$install_script"
    printf '%s\n' 'original agents state' > "$agents_target/original-state.txt"
    printf '%s\n' 'original claude state' > "$claude_target/original-state.txt"
    cp -R "$agents_target" "$home_directory/expected-agents"
    cp -R "$claude_target" "$home_directory/expected-claude"
  fi

  create_signaling_move "$home_directory"
  real_move="$(command -v mv)"

  set +e
  HOME="$home_directory" INJECT_SIGNAL="$signal" REAL_MV="$real_move" PATH="$home_directory/bin:$PATH" \
    bash "$install_script" > "$home_directory/output.log" 2>&1
  exit_status=$?
  set -e

  if [[ "$exit_status" -ne "$expected_exit_status" ]]; then
    echo "Expected $signal installation interruption to exit with $expected_exit_status, got $exit_status" >&2
    return 1
  fi

  if [[ "$installation_state" == 'existing' ]]; then
    diff -qr "$home_directory/expected-agents" "$agents_target"
    diff -qr "$home_directory/expected-claude" "$claude_target"
  else
    test ! -e "$agents_target"
    test ! -e "$claude_target"
  fi

  test -z "$(find "$home_directory" \( -name '.roadmap-install.*' -o -name '.roadmap-backup.*' -o -name 'roadmap.backup.*' \) -print)"
}

signal_rollbacks() {
  signal_rollback INT 130 existing
  signal_rollback INT 130 first
  signal_rollback TERM 143 existing
  signal_rollback TERM 143 first
}

standard_installation
conflict_rejection
quoted_frontmatter_names
existing_installation_rollback
first_installation_rollback
signal_rollbacks

echo 'install-roadmap-skill tests passed'
