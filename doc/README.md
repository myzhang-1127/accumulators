## Building the documentation

Use the Boost release-tools script from this directory:

```bash
./macosdocs.sh
```

Or from a full Boost tree:

```bash
cd libs/accumulators/doc
./macosdocs.sh ..
```

Output is written to `html/index.html` (site home and table of contents).

Narrative chapters build to `html/*.html` at the top level (for example `user_s_guide.html`, `the_statistical_accumulators_library.html`). The API reference follows the same layout as [Boost.JSON](https://www.boost.org/doc/libs/latest/libs/json/doc/html/ref.html): an index page at `html/ref.html` plus one HTML file per documented entity under `html/ref/`.

To change how many HTML files are generated, adjust `pagelevels` on sections in `pages/main.adoc` / `pages/reference.adoc` and see `htmldir.rb`.

The chapter TOC in the left sidebar is the same on every page; it is built in `htmldir.rb` (`convert_accumulators_home_outline`).

Narrative pages under `pages/` were migrated from QuickBook. The conversion helper `qbk_to_adoc.py` remains for reference; restore `accumulators.qbk` from git history to re-run it.

API reference generation uses `docca_runner/` (`accumulators_docca.py` + `accumulators_docca.jam`) so Accumulators-specific Doxygen output works without modifying `tools/docca/docca.py`. See `docca_runner/README.md`.
