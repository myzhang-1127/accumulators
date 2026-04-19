# Parity vs official Boost.Accumulators HTML (boost.org)

This document records how we compare the **Antora / AsciiDoc** site to the **authoritative** legacy HTML shipped with Boost (`latest` doc tree), what differences are expected, and where fixes belong (converter vs content policy).

## Gold standard (reference only)

- Main: `https://www.boost.org/doc/libs/latest/doc/html/accumulators.html`
- User’s Guide: `https://www.boost.org/doc/libs/latest/doc/html/accumulators/user_s_guide.html`
- Reference: `https://www.boost.org/doc/libs/latest/doc/html/accumulators/reference.html`

Treat **content, structure, nesting, internal anchors, and link targets** on those pages (and linked siblings under `accumulators/`) as normative. **Visual styling** (fonts, spacing, Antora chrome) is not.

## Repeatable comparison workflow

1. **Structural / source acceptance** (BoostBook XML vs generated pages):

   ```bash
   python -m boost_doc_modernize.cli --boost-root /path/to/boost accept-report \
     --qbk /path/to/boost/libs/accumulators/doc/accumulators.qbk \
     --pages /path/to/boost/libs/accumulators/doc/modules/ROOT/pages
   ```

2. **Quickbook vs pages inventory**:

   ```bash
   python -m boost_doc_modernize.cli --boost-root /path/to/boost compare-sources \
     --library accumulators --out compare-sources.json
   ```

3. **Legacy HTML vs Antora site** (requires a **local** legacy tree, e.g. from `./b2 libs/accumulators/doc` → `doc/html/`, and `npx antora` → `doc/build/site/`):

   ```bash
   python -m boost_doc_modernize.cli compare-html \
     --legacy /path/to/boost/libs/accumulators/doc/html \
     --modern /path/to/boost/libs/accumulators/doc/build/site \
     --out compare-html.json
   ```

4. **Against boost.org “latest”**  
   There is no single checked-in mirror of `doc/libs/latest/`. For strict online parity, mirror the relevant `accumulators/*.html` URLs (or a full doc tarball from a Boost release) into a scratch directory and point `--legacy` at that tree, or extend the compare step with a small download script. The JSON reports above stay the contract for automation.

## Difference categories (root cause)

| Symptom | Typical root | Fix location |
|--------|----------------|--------------|
| Missing or wrong section order vs BoostBook | Converter skips tags or splits pages differently | `boost-doc-modernize` `boostbook_to_adoc.py` |
| Wrong class / emphasis / code in narrative | QuickBook → BoostBook → AsciiDoc inline mapping | Same + regenerate `.adoc` |
| Reference hub lists each corpus **twice** (xref + same static link) | Hub always appended static `link:` after every xref | **Fixed** in `write_xincluded_reference_pages`: stubs → one `link:`; non-stubs → one `xref:` only |
| Reference page is “one long HTML” vs Antora multi-page | Information architecture (single `reference.adoc` vs hub + children) | Product choice; parity is **semantic** (same sections and links), not necessarily one file |
| Statistics / numeric detail only on Doxygen HTML | Stub `library-reference` + Doxygen build | Keep static `/_/ref/statsdoc/` (or grow non-stub XML if upstream ships it) |
| Stale generated HTML | Antora cache | `npx antora --clean` after `convert` |

## Converter change log (this effort)

- **`convert_library_reference_xml`**: now returns `(title, body, is_stub)` so callers know whether the XML was a Doxygen stub.
- **`write_xincluded_reference_pages`**: hub `reference.adoc` no longer duplicates navigation (previously every entry appeared as `xref:` **and** `link:` to `/_/ref/`, which does not match the intent of a single logical link per corpus).

## Manual deep review (ongoing)

A line-by-line diff of the entire Reference chapter against `reference.html` is **large** (hundreds of synopsis blocks). After each `convert` + Antora rebuild, spot-check:

- Table of contents order and anchor IDs for major headers.
- Cross-links from User’s Guide to Reference sections.
- Statistics chapter links vs `statsdoc` when formulas require the legacy LaTeX pipeline.

Update this file when new converter fixes land or when the gold standard URL layout changes between Boost releases.
