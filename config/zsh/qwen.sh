# qwen.sh — control mlx_lm.server + claude-code-proxy.
zmodload -F zsh/datetime +b:EPOCHREALTIME +b:EPOCHSECONDS 2>/dev/null

QWEN_MODEL_PATH=${QWEN_MODEL_PATH:-$HOME/models/qwen3-8b}
QWEN_PORT=${QWEN_PORT:-1235}
QWEN_HOST=${QWEN_HOST:-127.0.0.1}
QWEN_PID_FILE=${QWEN_PID_FILE:-$HOME/.local/state/qwen.pid}
QWEN_LOG=${QWEN_LOG:-$HOME/.local/state/qwen.log}
QWEN_MODEL_ID=${QWEN_MODEL_ID:-$QWEN_MODEL_PATH}

CCP_DIR=${CCP_DIR:-$HOME/Code/claude-code-proxy}
CCP_PORT=${CCP_PORT:-8082}
CCP_HOST=${CCP_HOST:-127.0.0.1}
CCP_PID_FILE=${CCP_PID_FILE:-$HOME/.local/state/claude-code-proxy.pid}
CCP_LOG=${CCP_LOG:-$HOME/.local/state/claude-code-proxy.log}

_qwen_pid() {
  [[ -f "$QWEN_PID_FILE" ]] || return 1
  local pid; pid=$(cat "$QWEN_PID_FILE" 2>/dev/null)
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null && echo "$pid"
}

_ccp_pid() {
  [[ -f "$CCP_PID_FILE" ]] || return 1
  local pid; pid=$(cat "$CCP_PID_FILE" 2>/dev/null)
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null && echo "$pid"
}

_ccp_start() {
  if _ccp_pid >/dev/null; then return 0; fi
  [[ -d "$CCP_DIR" ]] || { echo "claude-code-proxy missing at $CCP_DIR" >&2; return 0; }
  echo "starting claude-code-proxy on $CCP_HOST:$CCP_PORT"
  ( cd "$CCP_DIR" && nohup uv run claude-code-proxy >"$CCP_LOG" 2>&1 & echo $! > "$CCP_PID_FILE" )
  local i=0
  until curl -s -o /dev/null "http://$CCP_HOST:$CCP_PORT/" 2>/dev/null; do
    sleep 1; (( i++ )); (( i >= 30 )) && { echo "ccp timeout"; return 1; }
  done
  echo "claude-code-proxy ready (pid $(cat $CCP_PID_FILE))"
}

_ccp_stop() {
  local pid; pid=$(_ccp_pid)
  [[ -z "$pid" ]] && { rm -f "$CCP_PID_FILE"; return 0; }
  kill "$pid" 2>/dev/null
  local i=0; while kill -0 "$pid" 2>/dev/null && (( i < 10 )); do sleep 1; (( i++ )); done
  kill -9 "$pid" 2>/dev/null
  pkill -f 'claude-code-proxy' 2>/dev/null
  rm -f "$CCP_PID_FILE"
}

qwen-status() {
  local pid cpid
  pid=$(_qwen_pid); cpid=$(_ccp_pid)
  [[ -n "$pid"  ]] && echo "qwen        running  pid=$pid   port=$QWEN_PORT" || echo "qwen        not running"
  [[ -n "$cpid" ]] && echo "claude-code-proxy  running  pid=$cpid  port=$CCP_PORT"  || echo "claude-code-proxy  not running"
  [[ -n "$pid" ]]
}

qwen-start() {
  if _qwen_pid >/dev/null; then echo "qwen already running"; _ccp_start; return 0; fi
  if [[ ! -d "$QWEN_MODEL_PATH" ]]; then
    echo "qwen: model dir not found: $QWEN_MODEL_PATH" >&2; return 1
  fi
  if lsof -nP -iTCP:"$QWEN_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "qwen: port $QWEN_PORT already in use; run 'qwen-stop' or kill the listener" >&2; return 1
  fi
  mkdir -p "$(dirname "$QWEN_PID_FILE")"
  echo "starting qwen on $QWEN_HOST:$QWEN_PORT (model=$QWEN_MODEL_PATH)"
  nohup mlx_lm.server --model "$QWEN_MODEL_PATH" --host "$QWEN_HOST" --port "$QWEN_PORT" \
    --chat-template-args '{"enable_thinking": false}' \
    --log-level INFO >"$QWEN_LOG" 2>&1 &
  echo $! > "$QWEN_PID_FILE"
  local pid=$!
  printf "qwen: waiting for /v1/models"
  local i=0
  until curl -s -f -m 1 "http://$QWEN_HOST:$QWEN_PORT/v1/models" >/dev/null 2>&1; do
    if ! kill -0 "$pid" 2>/dev/null; then
      echo " server died (see $QWEN_LOG)"; rm -f "$QWEN_PID_FILE"; return 1
    fi
    sleep 1; printf "."; (( i++ )); (( i >= 60 )) && { echo " timeout"; return 1; }
  done
  echo " ok"
  # verify the model path is actually registered (catches stale --model arg mismatch)
  if ! curl -s -m 2 "http://$QWEN_HOST:$QWEN_PORT/v1/models" | grep -q "\"id\""; then
    echo "qwen: WARNING /v1/models reports no model — server probably started with a stale path" >&2
  fi
  echo "qwen ready (pid $pid)"
  _ccp_start
}

qwen-stop() {
  _ccp_stop
  local pid; pid=$(_qwen_pid)
  [[ -z "$pid" ]] && { rm -f "$QWEN_PID_FILE"; return 0; }
  kill "$pid" 2>/dev/null
  local i=0; while kill -0 "$pid" 2>/dev/null && (( i < 10 )); do sleep 1; (( i++ )); done
  kill -9 "$pid" 2>/dev/null
  rm -f "$QWEN_PID_FILE"
}

qwen-warm() {
  _qwen_pid >/dev/null || { echo "not running"; return 1; }
  curl -sS -m 180 -o /dev/null -X POST "http://$QWEN_HOST:$QWEN_PORT/v1/chat/completions" \
    -H 'Content-Type: application/json' \
    -d "{\"model\":\"$QWEN_MODEL_ID\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"max_tokens\":1,\"stream\":false}"
}

qwen-logs() { tail -f "$QWEN_LOG"; }

qwen-bench() {
  _qwen_pid >/dev/null || { echo "not running"; return 1; }
  local n=${1:-128}
  echo "qwen-bench: requesting $n tokens..."
  local t0=$EPOCHREALTIME
  local resp
  resp=$(curl -sS -m 600 -X POST "http://$QWEN_HOST:$QWEN_PORT/v1/chat/completions" \
    -H 'Content-Type: application/json' \
    -d "{\"model\":\"$QWEN_MODEL_ID\",\"messages\":[{\"role\":\"user\",\"content\":\"Write a short python function.\"}],\"max_tokens\":$n,\"stream\":false}") || { echo "bench failed"; return 1; }
  local t1=$EPOCHREALTIME
  local out_tok=$(print -r -- "$resp" | sed -n 's/.*"completion_tokens":\([0-9]*\).*/\1/p')
  local elapsed=$(printf '%.2f' "$((t1 - t0))")
  if [[ -n "$out_tok" && "$out_tok" -gt 0 ]]; then
    local tps=$(printf '%.1f' "$((out_tok / (t1 - t0)))")
    echo "qwen-bench: ${out_tok} tok in ${elapsed}s = ${tps} tok/s"
  else
    echo "qwen-bench: ${elapsed}s elapsed (no completion_tokens in response)"
  fi
}

qwen-mem() {
  local pid; pid=$(_qwen_pid) || { echo "not running"; return 1; }
  ps -o pid,rss,vsz,%cpu,etime,command -p "$pid" | awk 'NR==1{print; next} {printf "%s  %.2f GiB rss  %.2f GiB vsz  %s%%  %s  %s\n", $1, $2/1024/1024, $3/1024/1024, $4, $5, $6}'
}
