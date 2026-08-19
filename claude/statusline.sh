#!/bin/bash
# Custom Claude Code status line — colored segments, native data only.
# Deps: jq (JSON parse) + git (branch). No network, no credentials, no npm.
# Data source: the JSON payload Claude Code sends on stdin. Nothing else.
#
# Wire into ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "bash ~/.claude/statusline.sh", "padding": 0, "refreshInterval": 10 }

input=$(cat)

# --- Extract everything in ONE jq call (fast; runs every refresh) ---
# Delimit with ASCII Unit Separator (0x1f), not tab: tab is IFS-whitespace and
# would collapse empty fields (e.g. absent effort), shifting later values.
IFS=$'\037' read -r cwd model effort cw_size cw_used cw_pct \
  fh_pct fh_reset sd_pct sd_reset cost < <(
  printf '%s' "$input" | jq -r '[
    (.workspace.current_dir // ""),
    (.model.display_name // ""),
    (.effort.level // ""),
    (.context_window.context_window_size // 0),
    (.context_window.total_input_tokens // 0),
    (.context_window.used_percentage // 0),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.rate_limits.seven_day.resets_at // ""),
    (.cost.total_cost_usd // "")
  ] | map(tostring) | join("\u001f")'
)

# --- Git branch (the only thing not in the payload) ---
branch=""
if command -v git >/dev/null 2>&1 && [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" symbolic-ref --short -q HEAD 2>/dev/null \
        || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

now=$(date +%s)
round() { printf '%.0f' "${1:-0}" 2>/dev/null || echo 0; }
fmt_hm()  { local s=${1:-0}; ((s<0)) && s=0; printf '%d:%02d'      $((s/3600))  $(((s%3600)/60)); }
# Compact duration: 2d4h / 4h30m / 45m — coarse-grained to stay short.
fmt_short() { local s=${1:-0}; ((s<0)) && s=0; local d=$((s/86400)) h=$(((s%86400)/3600)) m=$(((s%3600)/60))
  if ((d>0)); then printf '%dd%dh' "$d" "$h"; elif ((h>0)); then printf '%dh%dm' "$h" "$m"; else printf '%dm' "$m"; fi; }
fmt_max() { local t=${1:-0}; if [ "$t" -ge 1000000 ] 2>/dev/null; then printf '%dM' $((t/1000000)); else printf '%dK' $((t/1000)); fi; }
# Truncate to N visible chars with a trailing ellipsis.
trunc() { local s=$1 n=${2:-28}; if [ "${#s}" -gt "$n" ]; then printf '%s…' "${s:0:n-1}"; else printf '%s' "$s"; fi; }
# Colors are tuned for a DARK terminal background (VS Code Dark Modern palette).
# Text color by usage %: <50 green, 50-79 amber, >=80 red
usage_fg() { local p; p=$(round "${1:-0}"); if [ "$p" -ge 80 ] 2>/dev/null; then echo "241;76;76"; elif [ "$p" -ge 50 ] 2>/dev/null; then echo "229;192;123"; else echo "35;209;139"; fi; }

# Only the Powerline branch glyph (U+E0A0) is used — it's far more widely
# supported than the Font Awesome (U+F000+) icons, which many fonts lack.
# Set OMC_GLYPHS=0 to disable it too.
GLYPHS=${OMC_GLYPHS:-1}
G_DIR=''; G_BRANCH=''; G_MODEL=''; G_CTX=''; G_COST=''; G_CLOCK=''

# --- Build segments across two lines. addN "text" "R;G;B" "glyph". ---
# Line 1 = workspace/utility (repo, branch, cost). Line 2 = model & usage.
# Each segment's color is applied to the text itself.
l1texts=(); l1fgs=(); l2texts=(); l2fgs=()
seg() { if [ "$GLYPHS" = 1 ] && [ -n "$2" ]; then printf '%s %s' "$2" "$1"; else printf '%s' "$1"; fi; }
add1() { l1texts+=("$(seg "$1" "$3")"); l1fgs+=("$2"); }
add2() { l2texts+=("$(seg "$1" "$3")"); l2fgs+=("$2"); }

# --- LINE 1: workspace/utility ---
# directory
add1 "${cwd##*/}" "255;140;90" "$G_DIR"           # orange
# git branch
[ -n "$branch" ] && add1 "$(trunc "$branch" 28)" "150;150;150" "$G_BRANCH"   # gray
# session cost
[ -n "$cost" ] && add1 "$(printf '$%.2f' "$cost")" "160;160;160" "$G_COST"   # gray

# --- LINE 2: model & usage ---
# model + effort
model_l=$(printf '%s' "$model" | tr '[:upper:]' '[:lower:]')
[ -n "$effort" ] && model_l="$model_l $effort"
add2 "$model_l" "79;193;255" "$G_MODEL"           # blue
# context window — just the fill %, colored by fullness
if [ "${cw_size:-0}" -gt 0 ] 2>/dev/null; then
  add2 "ctx $(round "$cw_pct")%" "$(usage_fg "$cw_pct")" "$G_CTX"
fi
# 5-hour session — colored by usage %
if [ -n "$fh_pct" ]; then
  cd5=""; [ -n "$fh_reset" ] && cd5=" $(fmt_hm $((fh_reset - now)))"
  add2 "5h $(round "$fh_pct")%${cd5}" "$(usage_fg "$fh_pct")" "$G_CLOCK"
fi
# 7-day session
if [ -n "$sd_pct" ]; then
  cd7=""; [ -n "$sd_reset" ] && cd7=" $(fmt_short $((sd_reset - now)))"
  add2 "7d $(round "$sd_pct")%${cd7}" "214;112;214" "$G_CLOCK"   # purple
fi

# --- Render: two left-aligned lines, segments joined by a dim " │ " pipe. ---
RESET=$'\033[0m'
SEP=$'\033[38;2;90;90;90m'" │ "                    # dim gray pipe
# eval-copy instead of `local -n`: macOS ships bash 3.2, which lacks namerefs.
render_line() { local out="" i
  eval 'local T=("${'"$1"'[@]}") F=("${'"$2"'[@]}")'
  [ "${#T[@]}" -eq 0 ] && return
  for i in "${!T[@]}"; do
    [ "$i" -gt 0 ] && out+="$SEP"
    out+=$'\033[38;2;'"${F[$i]}"'m'"${T[$i]}"
  done
  printf '%s%s\n' "$out" "$RESET"
}
render_line l1texts l1fgs
render_line l2texts l2fgs
