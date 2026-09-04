#!/usr/bin/env bash
# Starts the App Engine Java dev server against war/, matching what the old
# Google Plugin for Eclipse's "Run As > Web Application" used to launch.
#
# Runs under a JDK 7 specifically (GAE_JAVA_HOME) - this ~2013 SDK predates
# JDK 8's release; under JDK 8 its bundled JSP compiler fails with
# "java.io.ObjectInputStream cannot be resolved". JDK 7 works cleanly.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

SDK="${GAE_SDK_HOME:-/home/dvorka/p/openstack/kepler-64b/plugins/com.google.appengine.eclipse.sdkbundle_1.8.8/appengine-java-sdk-1.8.8}"
JAVA_BIN="${GAE_JAVA_HOME:-/opt/oracle/jdk1.7.0_80}/bin/java"
PORT="${PORT:-8080}"

JAR="$SDK/lib/appengine-tools-api.jar"
if [ ! -f "$JAR" ]; then
    echo "error: appengine-tools-api.jar not found under $SDK/lib" >&2
    echo "set GAE_SDK_HOME to an App Engine Java SDK 1.8.x install" >&2
    exit 1
fi
if [ ! -x "$JAVA_BIN" ]; then
    echo "error: $JAVA_BIN not found - set GAE_JAVA_HOME to a JDK 7 install" >&2
    exit 1
fi

echo "starting dev server on http://localhost:$PORT ..."
exec "$JAVA_BIN" -ea -cp "$JAR" com.google.appengine.tools.KickStart \
    com.google.appengine.tools.development.DevAppServerMain \
    --address=localhost --port="$PORT" war
