#!/usr/bin/env bash
#
# Copyright 2005, 2006 Eric Niebler
# Copyright 2026 boost-doc-modernize contributors
#
# Distributed under the Boost Software License, Version 1.0.
#
# Build Antora site under doc/build/site. Optionally builds Doxygen HTML via b2
# and copies it to build/site/_/ref/ for the Reference hub.
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
      libs/accumulators/doc//opdoc ) || echo "warning: b2 Doxygen targets failed; reference static copy may be empty."
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

# REF_DST="$SITE/_/ref"
# mkdir -p "$REF_DST"
# for d in accdoc statsdoc opdoc; do
#   if [ -d "$SCRIPT_DIR/html/$d" ]; then
#    echo "Copying html/$d -> _/ref/"
#     rm -rf "$REF_DST/$d"
#     cp -r "$SCRIPT_DIR/html/$d" "$REF_DST/"
#   fi
# done
# Framework struct pages linked from the User's Guide (depends_on<>, feature_of<>, as_feature<>).
# if [ -d "$SCRIPT_DIR/html/doxygen/accumulators_framework_reference" ]; then
#  echo "Copying html/doxygen/accumulators_framework_reference -> _/ref/"
#  rm -rf "$REF_DST/accumulators_framework_reference"
#  cp -r "$SCRIPT_DIR/html/doxygen/accumulators_framework_reference" "$REF_DST/"
#fi

# IMG_DST="$SITE/_/img"
# mkdir -p "$IMG_DST"
# if [ -n "${BOOST_SRC_DIR:-}" ]; then
#   if [ -f "$BOOST_SRC_DIR/boost.png" ]; then
#     cp "$BOOST_SRC_DIR/boost.png" "$IMG_DST/"
#     echo "Copied boost.png -> _/img/"
#   fi
#   for f in prev.png next.png up.png home.png; do
#     if [ -f "$BOOST_SRC_DIR/doc/src/images/$f" ]; then
#       cp "$BOOST_SRC_DIR/doc/src/images/$f" "$IMG_DST/"
#     fi
#   done
# fi

# if [ -d "$REF_DST/accumulators_framework_reference" ]; then
#   echo "Patching framework reference HTML paths for Antora layout..."
#   PY=python3
#   command -v python3 >/dev/null 2>&1 || PY=python
#   "$PY" "$SCRIPT_DIR/tools/fix_framework_ref_html.py" "$REF_DST/accumulators_framework_reference" || true
# fi

# if [ -n "${BOOST_SRC_DIR:-}" ]; then
#   BL="$BOOST_SRC_DIR/tools/boostlook/boostlook.css"
#   if [ -f "$BL" ]; then
#     cp "$BL" "$SITE/_/css/"
#     echo "Copied boostlook.css to site _/css/"
#   fi
# fi

# # Replace thin Antora reference page with legacy BoostBook reference (Doxygen section anchors + working links).
# LEGREF="$SCRIPT_DIR/html/accumulators/reference.html"
# if [ -f "$LEGREF" ]; then
#   mkdir -p "$SITE/accumulators"
#   cp "$LEGREF" "$SITE/accumulators/reference.html"
#   echo "Installed legacy reference.html (Doxygen anchors) under accumulators/"
#   PY=python3
#   command -v python3 >/dev/null 2>&1 || PY=python
#   "$PY" "$SCRIPT_DIR/tools/fix_reference_html_paths.py" "$SITE/accumulators/reference.html" || true
# fi

echo "Done. Open build/site/index.html or the component index under build/site/accumulators/"
