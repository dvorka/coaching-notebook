#!/usr/bin/env bash
# Stops a dev server started by `make run` / run.sh (whether launched via the
# Makefile or backgrounded manually with nohup). KickStart launches a second,
# actual Jetty child process - `pkill -f` on the class name catches both.

set -euo pipefail

if ! pgrep -f "com.google.appengine.tools.development.DevAppServerMain" > /dev/null; then
    echo "no dev server running"
    exit 0
fi

echo "stopping dev server..."
pkill -f "com.google.appengine.tools.development.DevAppServerMain"

for _ in $(seq 1 10); do
    pgrep -f "com.google.appengine.tools.development.DevAppServerMain" > /dev/null || { echo "stopped"; exit 0; }
    sleep 1
done

echo "still running after 10s, sending SIGKILL..." >&2
pkill -9 -f "com.google.appengine.tools.development.DevAppServerMain"
echo "stopped"
