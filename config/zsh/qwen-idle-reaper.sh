#!/bin/zsh
QWEN_PID_FILE=${QWEN_PID_FILE:-$HOME/.local/state/qwen.pid}
QWEN_LOG=${QWEN_LOG:-$HOME/.local/state/qwen.log}
QWEN_REAPER_LOG=${QWEN_REAPER_LOG:-$HOME/.local/state/qwen-reaper.log}
QWEN_IDLE_MIN=${QWEN_IDLE_MIN:-30}
QWEN_PORT=${QWEN_PORT:-1235}
CCP_PID_FILE=${CCP_PID_FILE:-$HOME/.local/state/claude-code-proxy.pid}

log() { print -r -- "$(date '+%Y-%m-%d %H:%M:%S')  $*" >> "$QWEN_REAPER_LOG"; }

[[ -f "$QWEN_PID_FILE" ]] || exit 0
pid=$(cat "$QWEN_PID_FILE" 2>/dev/null)
[[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null || { rm -f "$QWEN_PID_FILE"; exit 0; }
[[ -f "$QWEN_LOG" ]] || exit 0

idle=$(( $(date +%s) - $(stat -f %m "$QWEN_LOG") ))
threshold=$(( QWEN_IDLE_MIN * 60 ))
(( idle < threshold )) && exit 0

if lsof -nP -iTCP:"$QWEN_PORT" -sTCP:ESTABLISHED 2>/dev/null | grep -q ESTABLISHED; then
  log "idle but client connected, deferring"; exit 0
fi

log "stopping pid=$pid (idle ${idle}s)"
kill "$pid" 2>/dev/null
i=0; while kill -0 "$pid" 2>/dev/null && (( i < 10 )); do sleep 1; (( i++ )); done
kill -9 "$pid" 2>/dev/null
rm -f "$QWEN_PID_FILE"

if [[ -f "$CCP_PID_FILE" ]]; then
  cpid=$(cat "$CCP_PID_FILE" 2>/dev/null)
  [[ -n "$cpid" ]] && kill -0 "$cpid" 2>/dev/null && kill "$cpid" 2>/dev/null
  pkill -f 'claude-code-proxy' 2>/dev/null
  rm -f "$CCP_PID_FILE"
fi
log "stopped"
