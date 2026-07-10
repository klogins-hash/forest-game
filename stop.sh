#!/bin/bash
# Stop the Forest Chop dev server.
PIDFILE="$HOME/.hermes/run/forest-game.pid"
PORT="${PORT:-8000}"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  kill "$(cat "$PIDFILE")"
  rm -f "$PIDFILE"
  echo "Stopped server (was pid $(cat "$PIDFILE" 2>/dev/null || echo '?'))."
else
  # Fallback: kill anything on the port
  lsof -ti:"$PORT" | xargs kill 2>/dev/null
  rm -f "$PIDFILE"
  echo "No PID file, port $PORT cleared."
fi
