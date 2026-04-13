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
python -m boost_doc_modernize.cli --boost-root /path/to/boost convert --library accumulators
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

**QuickBook → AsciiDoc parity (narrative terms):** Phrases such as `['_accumulator_set_]` in `accumulators.qbk` become BoostBook `<classname>` and, after `convert`, AsciiDoc `_accumulator_set_`. A fresh Antora build should render those as **emphasis** (`<em>accumulator_set</em>`), not as `<a href>`. If you still see hyperlinks around that word, regenerate pages with `boost-doc-modernize convert` (see §2), then rebuild with **`npx antora --clean`** so old HTML is not reused. From the `boost-doc-modernize` repo, after building the site:  
`python scripts/verify_accumulators_narrative_html.py /path/to/boost/libs/accumulators/doc/build/site/accumulators/user_s_guide.html`

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

The Quickbook `[xinclude]` Doxygen corpora are not inlined into AsciiDoc. The generated `reference.adoc` links to static HTML under `/_/ref/` after `build_antora.sh` runs.
