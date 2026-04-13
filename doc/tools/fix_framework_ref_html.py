#!/usr/bin/env python3
"""Rewrite paths inside copied Doxygen framework-reference HTML for Antora site layout.

Pages live at site/_/ref/accumulators_framework_reference/*.html.
Legacy HTML used deep relative paths into the Boost tree.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

_SPIRIT_NAV_HEAD_STYLE = """<style id="accumulators-spirit-nav-fix">
div.spirit-nav{display:flex;flex-direction:row;flex-wrap:wrap;align-items:center;gap:2px;justify-content:flex-end;margin:.35rem 0}
div.spirit-nav a{display:inline-flex;align-items:center;justify-content:center;line-height:0}
div.spirit-nav a img{display:inline-block!important;max-width:none;height:auto;vertical-align:middle}
</style>"""


def _inject_spirit_nav_style(html: str) -> str:
    if 'id="accumulators-spirit-nav-fix"' in html or "spirit-nav" not in html:
        return html
    return re.sub(r"</head\s*>", _SPIRIT_NAV_HEAD_STYLE + "\n</head>", html, count=1, flags=re.I)


def patch_html(text: str) -> str:
    text = text.replace("\r\n", "\n")
    text = text.replace(
        "../../../../../../doc/src/boostbook.css", "../../css/boostlook.css"
    )
    text = text.replace("../../../../../../boost.png", "../../img/boost.png")
    text = text.replace("../../../../../../doc/src/images/", "../../img/")
    text = text.replace('href="../../../../../../index.html"', 'href="../../../index.html"')
    text = text.replace('href="../../../../../../libs/', 'href="https://www.boost.org/libs/')
    text = text.replace('href="../../../../../../more/', 'href="https://www.boost.org/more/')
    text = text.replace('href="../../accumulators/', 'href="../../../accumulators/')
    text = text.replace('href="../../index.html"', 'href="../../../accumulators/index.html"')
    return _inject_spirit_nav_style(text)


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else None
    if root is None or not root.is_dir():
        print("usage: fix_framework_ref_html.py <accumulators_framework_reference_dir>", file=sys.stderr)
        return 2
    for path in sorted(root.glob("*.html")):
        raw = path.read_text(encoding="utf-8", errors="replace")
        out = patch_html(raw)
        if out != raw:
            path.write_text(out, encoding="utf-8")
            print("patched", path.name)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
