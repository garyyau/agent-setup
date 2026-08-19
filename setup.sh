#!/bin/bash
# Idempotent installer for this repo's agent setup. Safe to re-run any time.
#
# What it does:
#   1. Symlinks skills/* into ~/.claude/skills/ and claude/{statusline.sh,CLAUDE.md}
#      into ~/.claude/ — so `git pull` in this repo updates every machine live.
#   2. Deep-merges claude/settings.json into ~/.claude/settings.json
#      (repo keys win; local-only keys are never touched or deleted).
#   3. Installs the plugins declared under enabledPlugins in the fragment.
#
# What it never does: delete anything. If a target exists and isn't a symlink
# into this repo, it's skipped with a warning — resolve those via the
# agent-led cleanup pass described in README.md.
#
# The repo may live anywhere; symlinks point at wherever this script sits.
# Don't move the clone afterward.

set -euo pipefail

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CLAUDE_DIR="$HOME/.claude"
FRAGMENT="$REPO_DIR/claude/settings.json"

warnings=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; warnings=$((warnings + 1)); }

command -v jq >/dev/null 2>&1 || { echo "error: jq is required (settings merge + statusline). Install it and re-run." >&2; exit 1; }

mkdir -p "$CLAUDE_DIR/skills"

# --- 1. Symlinks ---
# link <source-in-repo> <target>: create only when the target is absent or
# already the right symlink; anything else is skipped, never replaced.
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "$dst → already linked"
  elif [ -e "$dst" ] || [ -L "$dst" ]; then
    warn "$dst exists and is not a link into this repo — skipped (see README cleanup pass)"
  else
    ln -s "$src" "$dst"
    ok "$dst → linked"
  fi
}

echo "Symlinks:"
for skill in "$REPO_DIR"/skills/*/; do
  link "${skill%/}" "$CLAUDE_DIR/skills/$(basename "$skill")"
done
link "$REPO_DIR/claude/statusline.sh" "$CLAUDE_DIR/statusline.sh"
link "$REPO_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# --- 2. Settings merge ---
echo "Settings:"
SETTINGS="$CLAUDE_DIR/settings.json"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
merged=$(jq -s '.[0] * .[1]' "$SETTINGS" "$FRAGMENT")
if [ "$merged" = "$(cat "$SETTINGS")" ]; then
  ok "$SETTINGS → already up to date"
else
  # Atomic write (temp + mv, so an interrupt can't truncate live settings),
  # and show exactly what the merge changed — settings can carry keys that
  # execute commands (hooks, statusLine), so changes should never be silent.
  tmp=$(mktemp "$SETTINGS.XXXXXX")
  printf '%s\n' "$merged" > "$tmp"
  echo "  merge changes:"
  diff -u "$SETTINGS" "$tmp" | tail -n +3 | grep '^[+-]' | sed 's/^/    /' || true
  mv "$tmp" "$SETTINGS"
  ok "$SETTINGS → merged repo fragment (local-only keys preserved)"
fi

# --- 3. Plugins ---
echo "Plugins:"
if command -v claude >/dev/null 2>&1; then
  while IFS= read -r plugin; do
    if claude plugin install "$plugin" >/dev/null 2>&1; then
      ok "$plugin → installed"
    else
      warn "$plugin → install failed; run 'claude plugin install $plugin' manually"
    fi
  done < <(jq -r '.enabledPlugins | keys[]' "$FRAGMENT")
else
  warn "claude CLI not found — plugins not installed; re-run after installing Claude Code"
fi

echo
if [ "$warnings" -gt 0 ]; then
  echo "Done with $warnings warning(s) above — resolve them via the cleanup pass in README.md."
else
  echo "Done. All artifacts installed."
fi
