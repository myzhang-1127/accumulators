# Boost.Accumulators documentation

## Legacy build (Quickbook + BoostBook + Doxygen)

From the Boost superproject root (with `user-config.jam` set up as in [release-tools](https://github.com/boostorg/release-tools) `linuxdocs.sh`):

```bash
./b2 libs/accumulators/doc
```

HTML output is under `doc/html/`. This requires LaTeX, dvips, and Ghostscript for formula images in the statistics reference (see `Jamfile.v2`).

## Modern build (Antora + AsciiDoc)

Prerequisites: **Node.js** (for `npm ci` / Antora), **bash** (Git Bash or WSL on Windows), and optionally **quickbook** on `PATH` for conversion.

### 1. Scaffold (already committed)

`antora.yml`, `local-playbook.yml`, `package.json`, and `supplemental-ui/` define the Antora site.

### 2. Generate `.adoc` pages from Quickbook

Use the sibling project `boost-doc-modernize`:

```bash
pip install -e path/to/boost-doc-modernize
# Global `--boost-root` must come *before* the `convert` subcommand (Typer callback options).
# Do not overwrite the hand-generated `reference.adoc` (from boost.org) or the xinclude-based hub:
python -m boost_doc_modernize.cli --boost-root /path/to/boost convert --library accumulators \
  --skip-reference-hub --preserve-page reference.adoc
```

To refresh the monolithic `reference.adoc` from the official site (optional, needs `pip install beautifulsoup4` for the import tool):

```bash
python tools/import_reference_from_official.py --out modules/ROOT/pages/reference.adoc
```

Or pass pre-generated BoostBook XML:

```bash
quickbook --output-format boostbook --output-file accum.xml accumulators.qbk
python -m boost_doc_modernize.cli --boost-root /path/to/boost convert --library accumulators --boostbook-xml accum.xml
```

### 3. Build the site

```bash
cd libs/accumulators/doc
./build_antora.sh
```

**QuickBook → AsciiDoc parity (links):** `['_accumulator_set_]` and similar become BoostBook `<classname alt="…">` without an explicit `<link>`; the legacy HTML toolchain adds Reference targets. The converter maps those class names to `xref:reference.adoc#doxygen…​` (see `accumulators_reference_xref.py`). Regenerate with `convert` (§2), then **`npx antora --clean`** so cached HTML is not reused.

Or from Boost root:

```bash
./b2 libs/accumulators/doc//antora-html
```

Output: `doc/build/site/`. Doxygen HTML (if `b2` succeeded) is copied to `build/site/_/ref/{accdoc,statsdoc,opdoc}/` for the Reference page links.

### 4. `linuxdocs.sh` / `windowsdocs.ps1`

While both this `Jamfile.v2` (legacy) and Antora files exist, auto-detection prefers the **main** (b2 Quickbook) path. To build Antora via release-tools, pass **`--type antora`** explicitly:

```bash
./linuxdocs.sh --type antora /path/to/boostorg/accumulators
```

## Reference chapter

The committed `modules/ROOT/pages/reference.adoc` is **generated from** `https://www.boost.org/doc/libs/latest/doc/html/accumulators/reference.html` via `tools/import_reference_from_official.py` so anchors match the official Reference (required for User's Guide class-name links).

Optional legacy Doxygen copies still land under `build/site/_/ref/{accdoc,statsdoc,opdoc}/` when `build_antora.sh` runs `b2` successfully.
