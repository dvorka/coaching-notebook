#!/usr/bin/env bash
# Runs the DataNucleus JDO bytecode enhancer over this project's @PersistenceCapable
# classes (war/WEB-INF/classes/**/beans/Gae*Bean.class).
#
# The old Google Plugin for Eclipse used to do this automatically as a build step
# (see .project-legacy-gae-plugin's com.google.appengine.eclipse.core.enhancerbuilder).
# That plugin is dead, so this script replaces it. Without it, any code path that
# touches a JDO entity bean fails at runtime with:
#   "... does not seem to have been enhanced ... has no table in the database"
#
# Re-run this after every Eclipse build that changes a @PersistenceCapable class,
# before starting the dev server (dev_appserver.sh / DevAppServerMain).
#
# Requires an App Engine Java SDK ~1.8.x install for its v1 DataNucleus enhancer
# (lib/opt/tools/datanucleus/v1/{datanucleus-enhancer-1.1.4.jar,asm-4.1.jar}).
# Override the default location via GAE_SDK_HOME if yours lives elsewhere.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

SDK="${GAE_SDK_HOME:-/home/dvorka/p/openstack/kepler-64b/plugins/com.google.appengine.eclipse.sdkbundle_1.8.8/appengine-java-sdk-1.8.8}"
ENHANCER_LIB="$SDK/lib/opt/tools/datanucleus/v1"
CLASSES_DIR="war/WEB-INF/classes"
LIB_DIR="war/WEB-INF/lib"

if [ ! -f "$ENHANCER_LIB/datanucleus-enhancer-1.1.4.jar" ]; then
    echo "error: DataNucleus v1 enhancer not found under $ENHANCER_LIB" >&2
    echo "set GAE_SDK_HOME to an App Engine Java SDK 1.8.x install" >&2
    exit 1
fi

if [ ! -d "$CLASSES_DIR" ]; then
    echo "error: $CLASSES_DIR not found - build the project in Eclipse first" >&2
    exit 1
fi

CP="$ENHANCER_LIB/datanucleus-enhancer-1.1.4.jar:$ENHANCER_LIB/asm-4.1.jar"
CP="$CP:$LIB_DIR/datanucleus-core-1.1.5.jar:$LIB_DIR/datanucleus-jpa-1.1.5.jar"
CP="$CP:$LIB_DIR/datanucleus-appengine-1.0.10.final.jar:$LIB_DIR/jdo2-api-2.3-eb.jar"
CP="$CP:$LIB_DIR/geronimo-jpa_3.0_spec-1.1.1.jar:$LIB_DIR/geronimo-jta_1.1_spec-1.1.1.jar"
CP="$CP:$LIB_DIR/appengine-api-1.0-sdk-1.8.8.jar:$CLASSES_DIR"

mapfile -t PC_CLASSES < <(grep -rl '@PersistenceCapable' src --include='*.java' \
    | sed -e "s#^src/#${CLASSES_DIR}/#" -e 's/\.java$/.class/')

if [ "${#PC_CLASSES[@]}" -eq 0 ]; then
    echo "no @PersistenceCapable classes found under src/ - nothing to enhance"
    exit 0
fi

missing=0
for c in "${PC_CLASSES[@]}"; do
    [ -f "$c" ] || { echo "warning: $c not compiled yet" >&2; missing=1; }
done
[ "$missing" -eq 0 ] || { echo "error: rebuild the project first (Project > Clean in Eclipse)" >&2; exit 1; }

echo "enhancing ${#PC_CLASSES[@]} persistence-capable classes..."
java -cp "$CP" org.datanucleus.enhancer.DataNucleusEnhancer -api JDO -d "$CLASSES_DIR" -v "${PC_CLASSES[@]}"
