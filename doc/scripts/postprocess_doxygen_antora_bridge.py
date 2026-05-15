"""Post-process Doxygen HTML for Antora attachment pages (toolbar, footer, bridge CSS)."""

from __future__ import annotations

import re
import sys
from pathlib import Path


def _read_branding(doc_dir: Path, name: str) -> str:
    p = doc_dir / "doxygen" / "branding" / name
    return p.read_text(encoding="utf-8").strip()


def ensure_root_class(html: str) -> str:
    if "boost-doc-antora" in html:
        return html
    return re.sub(r"<html\b", '<html class="boost-doc-antora"', html, count=1)


def ensure_bridge_css(html: str) -> str:
    if "antora-doxygen-bridge.css" in html:
        return html
    return re.sub(
        r'(<link href="doxygen\.css" rel="stylesheet" type="text/css"\s*/>)',
        r'\1\n<link href="antora-doxygen-bridge.css" rel="stylesheet" type="text/css"/>',
        html,
        count=1,
    )


def ensure_toolbar(html: str, toolbar: str) -> str:
    if "boost-doxy-site-toolbar" in html:
        return html
    return re.sub(r"(<body[^>]*>)", r"\1\n" + toolbar + "\n", html, count=1)


def ensure_footer(html: str, footer: str) -> str:
    if "boost-doxy-page-nav" in html:
        return html
    return re.sub(r"</body>\s*</html>", footer + "\n</body>\n</html>", html, count=1, flags=re.IGNORECASE | re.DOTALL)


def strip_memdoc_definition_lines(html: str) -> str:
    """Remove Doxygen 'Definition at line …' footers in member docs (matches legacy HTML)."""
    return re.sub(
        r'<p class="definition">Definition at line.+?</p>\s*',
        "",
        html,
        flags=re.DOTALL,
    )


def normalize_accumulators_struct_titles(html: str) -> str:
    """Match legacy packet HTML: short <title> and <h1> for struct templates under boost::accumulators."""
    html = re.sub(
        r"<title>Boost\.Accumulators: boost::accumulators::(?:\w+::)*(\w+)&lt;.*?&gt; Struct Template Reference</title>",
        r"<title>Struct template \1</title>",
        html,
        count=1,
    )
    html = re.sub(
        r'(<div class="headertitle"><div class="title">)boost::accumulators::(?:\w+::)*(\w+)&lt;.*?&gt; Struct Template Reference(</div></div>)',
        r"\1Struct template \2\3",
        html,
        count=1,
    )
    return html


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: postprocess_doxygen_antora_bridge.py OUT_DIR", file=sys.stderr)
        return 2
    out = Path(sys.argv[1])
    if not out.is_dir():
        print(f"error: not a directory: {out}", file=sys.stderr)
        return 1

    doc_dir = out.resolve().parents[4]
    toolbar = _read_branding(doc_dir, "doxygen_html_header.html")
    footer = _read_branding(doc_dir, "doxygen_html_footer.html")

    for path in sorted(out.rglob("*.html")):
        text = path.read_text(encoding="utf-8", errors="surrogateescape")
        updated = text
        updated = ensure_root_class(updated)
        updated = ensure_bridge_css(updated)
        updated = ensure_toolbar(updated, toolbar)
        updated = strip_memdoc_definition_lines(updated)
        updated = normalize_accumulators_struct_titles(updated)
        updated = ensure_footer(updated, footer)
        if updated != text:
            path.write_text(updated, encoding="utf-8", errors="surrogateescape")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
