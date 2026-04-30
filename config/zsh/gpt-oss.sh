# gpt-oss.sh — control gpt-oss-20b on Ollama (loads/unloads via API; daemon
# is managed externally by the Ollama menubar app, we don't start/stop it here).

GPT_MODEL=${GPT_MODEL:-gpt-oss-20b}
GPT_HOST=${GPT_HOST:-127.0.0.1}
GPT_PORT=${GPT_PORT:-11434}
GPT_KEEP_ALIVE=${GPT_KEEP_ALIVE:-30m}
GPT_LOG=${GPT_LOG:-$HOME/.ollama/logs/server.log}

_gpt_daemon_up() {
  curl -s -f -m 1 "http://$GPT_HOST:$GPT_PORT/api/tags" >/dev/null 2>&1
}

_gpt_loaded() {
  curl -s -m 2 "http://$GPT_HOST:$GPT_PORT/api/ps" 2>/dev/null \
    | grep -q "\"name\":\"$GPT_MODEL"
}

gpt-start() {
  if ! _gpt_daemon_up; then
    echo "ollama daemon not running. Start it via the menubar app or 'ollama serve &'." >&2
    return 1
  fi
  if _gpt_loaded; then
    echo "gpt-oss-20b already loaded"
    return 0
  fi
  echo "loading $GPT_MODEL (keep_alive=$GPT_KEEP_ALIVE, ~12 GB into GPU memory)..."
  curl -sS -m 300 -X POST "http://$GPT_HOST:$GPT_PORT/api/chat" \
    -H 'Content-Type: application/json' \
    -d "{\"model\":\"$GPT_MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"options\":{\"num_predict\":1},\"keep_alive\":\"$GPT_KEEP_ALIVE\",\"stream\":false}" \
    >/dev/null
  if _gpt_loaded; then
    echo "$GPT_MODEL loaded"
  else
    echo "failed to load (see: gpt-logs)" >&2
    return 1
  fi
}

gpt-stop() {
  _gpt_daemon_up || { echo "ollama daemon not running"; return 0; }
  _gpt_loaded   || { echo "$GPT_MODEL not loaded"; return 0; }
  echo "unloading $GPT_MODEL..."
  curl -sS -m 30 -X POST "http://$GPT_HOST:$GPT_PORT/api/chat" \
    -H 'Content-Type: application/json' \
    -d "{\"model\":\"$GPT_MODEL\",\"messages\":[],\"keep_alive\":0,\"stream\":false}" \
    >/dev/null
  sleep 1
  if _gpt_loaded; then echo "still loaded (try again)" >&2; return 1
  else echo "unloaded"
  fi
}

gpt-restart() { gpt-stop; gpt-start; }

gpt-status() {
  if ! _gpt_daemon_up; then
    echo "ollama daemon not running"
    return 1
  fi
  echo "ollama daemon  running  http://$GPT_HOST:$GPT_PORT"
  ollama ps
}

gpt-warm() {
  gpt-start || return $?
  echo "warming (1-token request to JIT Metal kernels)..."
  local t0=$EPOCHREALTIME
  curl -sS -m 60 -o /dev/null -X POST "http://$GPT_HOST:$GPT_PORT/api/chat" \
    -H 'Content-Type: application/json' \
    -d "{\"model\":\"$GPT_MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"options\":{\"num_predict\":1},\"keep_alive\":\"$GPT_KEEP_ALIVE\",\"stream\":false}" \
    && printf "warm in %.2fs\n" "$((EPOCHREALTIME - t0))"
}

gpt-bench() {
  _gpt_loaded || gpt-start || return 1
  local n=${1:-128}
  echo "gpt-bench: requesting $n tokens..."
  local resp
  resp=$(curl -sS -m 600 -X POST "http://$GPT_HOST:$GPT_PORT/api/chat" \
    -H 'Content-Type: application/json' \
    -d "{\"model\":\"$GPT_MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"Write a short python function that returns the nth fibonacci number. Just code.\"}],\"options\":{\"num_predict\":$n},\"keep_alive\":\"$GPT_KEEP_ALIVE\",\"stream\":false}") || {
      echo "bench failed (see: gpt-logs)" >&2; return 1
    }
  print -r -- "$resp" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
except Exception as e:
    print('parse error:', e); sys.exit(1)
pec, ped = d.get('prompt_eval_count', 0), d.get('prompt_eval_duration', 0)
ec,  ed  = d.get('eval_count', 0),       d.get('eval_duration', 0)
total = d.get('total_duration', 0) / 1e9
parts = [f'total {total:.2f}s']
if ped > 0: parts.append(f'prefill {pec} tok in {ped/1e9:.2f}s = {pec*1e9/ped:.0f} tok/s')
if ed  > 0: parts.append(f'decode {ec} tok in {ed/1e9:.2f}s = {ec*1e9/ed:.0f} tok/s')
print('gpt-bench:', '; '.join(parts))
"
}

gpt-mem() {
  _gpt_daemon_up || { echo "ollama daemon not running"; return 1; }
  if _gpt_loaded; then
    ollama ps
  else
    echo "$GPT_MODEL not loaded"
  fi
}

gpt-logs() {
  [[ -f "$GPT_LOG" ]] || { echo "no log at $GPT_LOG (try: ls ~/.ollama/logs/)"; return 1; }
  tail -n "${1:-50}" "$GPT_LOG"
}
