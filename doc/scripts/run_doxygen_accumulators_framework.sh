#!/usr/bin/env bash
#
# Generate Doxygen HTML for the Accumulators framework into the Antora attachments tree.
# Requires: doxygen, python3 (or python), BOOST_SRC_DIR, and optional Graphviz `dot` for diagrams.

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DOC_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)
DOXY_DIR="$DOC_DIR/doxygen"
OUT_DIR="$DOC_DIR/modules/ROOT/attachments/doxygen/accumulators_framework_reference"

if ! command -v doxygen >/dev/null 2>&1; then
  echo "ERROR: doxygen not found in PATH. Install Doxygen before building Antora docs." >&2
  exit 1
fi

_PY=
if command -v python3 >/dev/null 2>&1; then
  _PY=python3
elif command -v python >/dev/null 2>&1; then
  _PY=python
else
  echo "ERROR: python3/python not found in PATH (needed for Doxygen HTML postprocess)." >&2
  exit 1
fi

if [ -z "${BOOST_SRC_DIR:-}" ]; then
  echo "ERROR: BOOST_SRC_DIR is not set. Point it at the Boost super-project root." >&2
  exit 1
fi

_INPUT_DIR="$BOOST_SRC_DIR/libs/accumulators/include/boost/accumulators"
if [ ! -d "$_INPUT_DIR" ]; then
  echo "ERROR: Accumulators headers not found: $_INPUT_DIR" >&2
  exit 1
fi

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

RUNTIME="$DOXY_DIR/Doxyfile._runtime"
if command -v dot >/dev/null 2>&1; then
  cat >"$RUNTIME" <<'EOF'
HAVE_DOT               = YES
CLASS_GRAPH            = YES
COLLABORATION_GRAPH    = YES
INCLUDE_GRAPH          = YES
INCLUDED_BY_GRAPH      = YES
CALL_GRAPH             = NO
CALLER_GRAPH           = NO
EOF
else
  echo "WARNING: Graphviz 'dot' not found; Doxygen class/collaboration graphs will be skipped." >&2
  cat >"$RUNTIME" <<'EOF'
HAVE_DOT               = NO
CLASS_GRAPH            = NO
COLLABORATION_GRAPH    = NO
INCLUDE_GRAPH          = NO
INCLUDED_BY_GRAPH      = NO
CALL_GRAPH             = NO
CALLER_GRAPH           = NO
EOF
fi

cd "$DOXY_DIR"
echo "Running Doxygen (framework API) into attachments..."
doxygen Doxyfile.accumulators_framework

echo "Post-processing Doxygen HTML for Antora bridge CSS..."
"$_PY" "$DOC_DIR/scripts/postprocess_doxygen_antora_bridge.py" "$OUT_DIR"

echo "Doxygen framework API HTML ready at: $OUT_DIR"
