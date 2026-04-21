#!/usr/bin/env bash
#
# Copyright 2005, 2006 Eric Niebler
# Copyright 2026 boost-doc-modernize contributors
#
# Distributed under the Boost Software License, Version 1.0.
#
# Build Antora site under doc/build/site. Optionally builds Doxygen HTML via b2
# (accdoc/statsdoc/opdoc) into doc/html. Snapshot before removing dead commented
# post-Antora blocks: build_antora.sh.bak (restore with: cp build_antora.sh.bak build_antora.sh).
#

set -e

SCRIPT_DIR=$( cd -- "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

if [ -z "${BOOST_SRC_DIR:-}" ]; then
  CANDIDATE=$( cd "$SCRIPT_DIR/../../.." 2>/dev/null && pwd )
  if [ -n "$CANDIDATE" ]; then
    BOOST_SRC_DIR_IS_VALID=ON
    for F in "CMakeLists.txt" "Jamroot" "boost-build.jam" "bootstrap.sh" "libs"; do
      if [ ! -e "$CANDIDATE/$F" ]; then
        BOOST_SRC_DIR_IS_VALID=OFF
        break
      fi
    done
    if [ "$BOOST_SRC_DIR_IS_VALID" = "ON" ]; then
      export BOOST_SRC_DIR="$CANDIDATE"
      echo "Using BOOST_SRC_DIR=$BOOST_SRC_DIR"
    fi
  fi
fi

if [ $# -eq 0 ]; then
  PLAYBOOK="local-playbook.yml"
else
  PLAYBOOK=$1
fi

if [ "${SKIP_LEGACY_DOXYGEN:-}" != "1" ] && [ -n "${BOOST_SRC_DIR:-}" ]; then
  echo "Building Doxygen reference targets (optional; set SKIP_LEGACY_DOXYGEN=1 to skip)..."
  ( cd "$BOOST_SRC_DIR" && ./b2 -q -d0 \
      libs/accumulators/doc//accdoc \
      libs/accumulators/doc//statsdoc \
      libs/accumulators/doc//opdoc ) || echo "warning: b2 Doxygen targets failed (doc/html may be incomplete)."
fi

echo "Installing npm dependencies..."
npm ci

echo "Running Antora..."
PATH="$(pwd)/node_modules/.bin:${PATH}"
export PATH
npx antora --clean --fetch "$PLAYBOOK" --stacktrace --log-level info

SITE="$SCRIPT_DIR/build/site"
# Labeled lists (BoostBook variablelist): bordered dl like legacy HTML tables.
DLCSS="$SCRIPT_DIR/supplemental-ui/css/accumulators-dlist.css"
SITECSS="$SITE/_/css/site.css"
if [ -f "$DLCSS" ] && [ -f "$SITECSS" ]; then
  if ! grep -q "accumulators-dlist-injected" "$SITECSS" 2>/dev/null; then
    printf '\n' >> "$SITECSS"
    cat "$DLCSS" >> "$SITECSS"
    echo "Appended accumulators-dlist rules to _/css/site.css"
  fi
fi

mkdir -p "$SITE/_/css"
LEG_HTML_CSS="$SCRIPT_DIR/supplemental-ui/css/accumulators-legacy-html.css"
if [ -f "$LEG_HTML_CSS" ]; then
  cp "$LEG_HTML_CSS" "$SITE/_/css/accumulators-legacy-html.css"
  echo "Copied accumulators-legacy-html.css to site _/css/"
fi

echo "Done. Open build/site/index.html or the component index under build/site/accumulators/"
