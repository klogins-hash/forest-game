#!/bin/bash
# Forest Chop — local deploy script
# Starts a Python HTTP server in the background, auto-restarts on crash,
# logs to a file, listens on all interfaces so the phone can reach it too.

set -e

APP_DIR="$HOME/projects/forest-game"
PORT="${PORT:-8000}"
LOG="$HOME/.hermes/logs/forest-game.log"
PIDFILE="$HOME/.hermes/run/forest-game.pid"

mkdir -p "$(dirname "$LOG")" "$(dirname "$PIDFILE")"

# If something's already serving the port, stop it
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "Stopping previous server (pid $(cat "$PIDFILE"))..."
  kill "$(cat "$PIDFILE")" 2>/dev/null || true
  sleep 0.5
fi
# Belt-and-braces: clear anything still on the port
lsof -ti:"$PORT" | xargs kill 2>/dev/null || true

cd "$APP_DIR"

# Respawn loop — if the server ever dies, bring it back within 1s
(
  while true; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] starting python3 -m http.server $PORT on 0.0.0.0" >> "$LOG"
    python3 -m http.server "$PORT" --bind 0.0.0.0 >> "$LOG" 2>&1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] server exited, respawning in 1s" >> "$LOG"
    sleep 1
  done
) &

SERVER_PID=$!
echo "$SERVER_PID" > "$PIDFILE"

# Wait a beat, then verify it actually came up
sleep 0.6
if curl -sI "http://127.0.0.1:$PORT/" | head -1 | grep -q "200 OK"; then
  LAN_IP=$(ifconfig | grep -E "inet [0-9]" | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
  LOCAL_URL="http://localhost:$PORT/"
  LAN_URL="http://${LAN_IP}:$PORT/"

  # Auto-open in the default browser (Kenneth's standing preference)
  # We use `open -a` with the explicit app name so it works even if the
  # system-level default hasn't been flipped to Chrome yet (macOS gates that
  # behind a one-time System Settings click for security). OPEN_BROWSER=0
  # disables this if you want to deploy silently.
  if [ "${OPEN_BROWSER:-1}" = "1" ]; then
    if command -v open >/dev/null 2>&1; then
      if [ -d "/Applications/Google Chrome.app" ]; then
        open -a "Google Chrome" "$LOCAL_URL" && echo "   Browser:  opened $LOCAL_URL in Google Chrome"
      else
        open "$LOCAL_URL" && echo "   Browser:  opened $LOCAL_URL in default browser"
      fi
    elif command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$LOCAL_URL" >/dev/null 2>&1 && echo "   Browser:  opened $LOCAL_URL in default browser"
    else
      echo "   Browser:  (no 'open' command available — open $LOCAL_URL manually)"
    fi
  fi

  echo ""
  echo "✅ Forest Chop is live"
  echo "   Local:    $LOCAL_URL"
  echo "   Network:  $LAN_URL   (use this from your phone on the same Wi-Fi)"
  echo "   PID:      $SERVER_PID  (stored in $PIDFILE)"
  echo "   Log:      tail -f $LOG"
  echo "   Stop:     ./stop.sh  (or: kill \$(cat $PIDFILE))"
else
  echo "❌ Server failed to start. Last log lines:"
  tail -20 "$LOG"
  exit 1
fi
