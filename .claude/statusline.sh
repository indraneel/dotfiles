#!/bin/bash
# Claude Code status line for indraneel.
# Reads session JSON on stdin, prints a multi-line status bar.
# Palette is colorblind-safe (blue / yellow / magenta — avoids the red-green
# axis) and every bar is paired with its numeric %, so meaning never relies on
# color alone. Tweak the COL_* values below to taste.

input=$(cat)

# --- Single jq pass: extract everything as \x1f-separated fields ---------------
# \x1f (unit separator) is non-whitespace, so empty fields (e.g. absent rate
# limits) survive `read -a` instead of being collapsed like tabs/spaces would.
IFS=$'\x1f' read -r -a F <<< "$(printf '%s' "$input" | jq -r '[
  (.model.display_name // "?"),
  (.effort.level // ""),
  (.workspace.current_dir // ""),
  (.context_window.used_percentage // 0),
  (.context_window.total_input_tokens // 0),
  (.context_window.total_output_tokens // 0),
  (.context_window.context_window_size // 200000),
  (.context_window.current_usage.input_tokens // 0),
  (.context_window.current_usage.cache_creation_input_tokens // 0),
  (.context_window.current_usage.cache_read_input_tokens // 0),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.five_hour.resets_at // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.rate_limits.seven_day.resets_at // ""),
  (.cost.total_cost_usd // 0),
  (.cost.total_duration_ms // 0),
  (.cost.total_api_duration_ms // 0),
  (.cost.total_lines_added // 0),
  (.cost.total_lines_removed // 0),
  (.exceeds_200k_tokens // false)
] | map(tostring) | join("")')"

MODEL="${F[0]}"
EFFORT="${F[1]}"
DIR="${F[2]}"
CTX_PCT="${F[3]%%.*}"          # int-truncate
CTX_IN_TOTAL="${F[4]}"
CTX_OUT_TOTAL="${F[5]}"
CTX_SIZE="${F[6]}"
U_INPUT="${F[7]}"
U_CACHE_CREATE="${F[8]}"
U_CACHE_READ="${F[9]}"
RL5_PCT="${F[10]}"
RL5_RESET="${F[11]}"
RL7_PCT="${F[12]}"
RL7_RESET="${F[13]}"
COST="${F[14]}"
DUR_MS="${F[15]}"
API_MS="${F[16]}"
ADDED="${F[17]}"
REMOVED="${F[18]}"
EXCEEDS="${F[19]}"

# --- Colors (colorblind-safe; bars are bolded for light-background contrast) ---
DIM=$'\033[2m'; BOLD=$'\033[1m'; RESET=$'\033[0m'
OK=$'\033[34m'      # blue
WARN=$'\033[33m'    # yellow
CRIT=$'\033[35m'    # magenta
ACCENT=$'\033[36m'  # cyan

# --- Helpers ------------------------------------------------------------------
hn() { # humanize an integer token count -> 8.5k / 1.2M
  local n=${1:-0}; [[ "$n" =~ ^[0-9]+$ ]] || n=0
  if   [ "$n" -ge 1000000 ]; then awk -v n="$n" 'BEGIN{printf "%.1fM", n/1000000}'
  elif [ "$n" -ge 1000 ];    then awk -v n="$n" 'BEGIN{printf "%.1fk", n/1000}'
  else printf '%s' "$n"; fi
}

pctcol() { local p=${1:-0}
  if   [ "$p" -ge 90 ]; then printf '%s' "$CRIT"
  elif [ "$p" -ge 70 ]; then printf '%s' "$WARN"
  else printf '%s' "$OK"; fi
}

bar() { # $1 pct(int) $2 width -> ▓▓░░ run
  local p=${1:-0} w=${2:-10} filled empty f e b=""
  [[ "$p" =~ ^[0-9]+$ ]] || p=0
  filled=$(( p * w / 100 )); [ "$filled" -gt "$w" ] && filled=$w; [ "$filled" -lt 0 ] && filled=0
  empty=$(( w - filled ))
  [ "$filled" -gt 0 ] && printf -v f "%${filled}s" && b="${f// /▓}"
  [ "$empty"  -gt 0 ] && printf -v e "%${empty}s"  && b="${b}${e// /░}"
  printf '%s' "$b"
}

reltime() { # epoch seconds -> "2h14m" until reset
  local t=$1 now delta d h m
  [[ "$t" =~ ^[0-9]+$ ]] || { printf '?'; return; }
  now=$(date +%s); delta=$(( t - now )); [ "$delta" -lt 0 ] && delta=0
  d=$(( delta/86400 )); h=$(( (delta%86400)/3600 )); m=$(( (delta%3600)/60 ))
  if   [ "$d" -gt 0 ]; then printf '%dd%dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%dh%dm' "$h" "$m"
  else printf '%dm' "$m"; fi
}

dur() { # ms -> "4m 12s" / "1h 3m"
  local ms=${1:-0} s m; [[ "$ms" =~ ^[0-9]+$ ]] || ms=0
  s=$(( ms/1000 )); m=$(( s/60 ))
  if [ "$m" -ge 60 ]; then printf '%dh %dm' $((m/60)) $((m%60)); else printf '%dm %ds' "$m" $((s%60)); fi
}

usage_seg() { # label, pct(may be ""), reset-epoch(may be "") -> colored segment or ""
  local label=$1 pct=$2 reset=$3 ip
  [ -z "$pct" ] && return
  ip="${pct%%.*}"; [[ "$ip" =~ ^[0-9]+$ ]] || ip=0
  local col; col=$(pctcol "$ip")
  printf '%s %s%s%s %s%d%%%s' \
    "$label" "$BOLD$col" "$(bar "$ip" 6)" "$RESET" "$col" "$ip" "$RESET"
  [ -n "$reset" ] && printf ' %s↻%s%s' "$DIM" "$(reltime "$reset")" "$RESET"
}

# --- Line 1: identity ---------------------------------------------------------
L1="${ACCENT}${BOLD}${MODEL}${RESET}"
[ -n "$EFFORT" ] && L1="$L1 ${DIM}·${RESET} ${EFFORT}"
[ -n "$DIR" ] && L1="$L1 ${DIM}·${RESET} 📁 ${DIR##*/}"
if git -C "${DIR:-.}" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
  [ -n "$BRANCH" ] && L1="$L1 ${DIM}·${RESET} 🌿 ${BRANCH}"
fi

# --- Line 2: context window (detailed) ----------------------------------------
CTX_COL=$(pctcol "${CTX_PCT:-0}")
CACHE_TOTAL=$(( ${U_CACHE_READ:-0} + ${U_CACHE_CREATE:-0} ))
WARN200=""; [ "$EXCEEDS" = "true" ] && WARN200=" ${CRIT}${BOLD}⚠200k${RESET}"
CACHE_DENOM=$(( ${U_INPUT:-0} + CACHE_TOTAL ))
if [ "$CACHE_DENOM" -gt 0 ]; then CACHE_HIT=$(( ${U_CACHE_READ:-0} * 100 / CACHE_DENOM )); else CACHE_HIT=0; fi
L2="ctx ${BOLD}${CTX_COL}$(bar "${CTX_PCT:-0}" 8)${RESET} ${CTX_COL}${CTX_PCT:-0}%${RESET}"
L2="$L2 ${DIM}·${RESET} $(hn "$CTX_IN_TOTAL")/$(hn "$CTX_SIZE")"
L2="$L2 ${DIM}·${RESET} ${DIM}tok/in${RESET} $(hn "$U_INPUT") ${DIM}cache${RESET} ${CACHE_HIT}% ${DIM}tok/out${RESET} $(hn "$CTX_OUT_TOTAL")${WARN200}"

# --- Line 3: usage windows ----------------------------------------------------
SESS=$(usage_seg "session" "$RL5_PCT" "$RL5_RESET")
WEEK=$(usage_seg "week" "$RL7_PCT" "$RL7_RESET")
if [ -n "$SESS" ] || [ -n "$WEEK" ]; then
  L3="$SESS"
  [ -n "$SESS" ] && [ -n "$WEEK" ] && L3="$L3 ${DIM}·${RESET} "
  L3="$L3$WEEK"
else
  L3="${DIM}usage: waiting for first API response…${RESET}"
fi

# --- Line 4: cost + duration --------------------------------------------------
COST_FMT=$(awk -v c="${COST:-0}" 'BEGIN{printf "$%.2f", c}')
L4="💰 ${COST_FMT} ${DIM}·${RESET} ⏱ $(dur "$API_MS") ${DIM}api${RESET}"
L4="$L4 ${DIM}·${RESET} ${OK}+${ADDED:-0}${RESET}/${CRIT}-${REMOVED:-0}${RESET}"

printf '%b\n' "$L1"
printf '%b\n' "$L2"
printf '%b\n' "$L3"
printf '%b\n' "$L4"
