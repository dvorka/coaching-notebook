#!/usr/bin/env bash
# Compiles src/ into war/WEB-INF/classes, standing in for what Eclipse's own
# incremental builder does - so `make run` works without the IDE open.
#
# Bytecode target is 1.7 (matches .settings/org.eclipse.jdt.core.prefs): the
# vendored DataNucleus JDO enhancer (see enhance.sh) can't read Java 8+ class
# files, and the source has no Java 8 syntax, so 1.7 is safe.
#
# Override the compiler with JAVA_HOME if you don't want whatever `javac` is
# on PATH.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

CLASSES_DIR="war/WEB-INF/classes"
LIB_DIR="war/WEB-INF/lib"
JAVAC="${JAVA_HOME:+$JAVA_HOME/bin/}javac"

mkdir -p "$CLASSES_DIR"

CP="$(find "$LIB_DIR" -name '*.jar' | paste -sd: -)"

SRC_LIST="$(mktemp)"
trap 'rm -f "$SRC_LIST"' EXIT
find src -name '*.java' > "$SRC_LIST"

echo "compiling $(wc -l < "$SRC_LIST") sources -> $CLASSES_DIR ..."
"$JAVAC" -nowarn -source 1.7 -target 1.7 -cp "$CP" -d "$CLASSES_DIR" @"$SRC_LIST"

echo "copying non-.java resources ..."
find src -type f ! -name '*.java' | while read -r f; do
    rel="${f#src/}"
    mkdir -p "$CLASSES_DIR/$(dirname "$rel")"
    cp "$f" "$CLASSES_DIR/$rel"
done

echo "compiled $(find "$CLASSES_DIR" -name '*.class' | wc -l) classes"
