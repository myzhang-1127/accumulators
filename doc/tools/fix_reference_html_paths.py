#!/usr/bin/env python3
"""Patch legacy BoostBook reference.html after copy into Antora site/accumulators/."""
from __future__ import annotations

import re
import sys
from pathlib import Path

# boostlook.css applies img { display: block } globally; DocBook spirit-nav then stacks vertically.
_SPIRIT_NAV_HEAD_STYLE = """<style id="accumulators-spirit-nav-fix">
div.spirit-nav{display:flex;flex-direction:row;flex-wrap:wrap;align-items:center;gap:2px;justify-content:flex-end;margin:.35rem 0}
div.spirit-nav a{display:inline-flex;align-items:center;justify-content:center;line-height:0}
div.spirit-nav a img{display:inline-block!important;max-width:none;height:auto;vertical-align:middle}
</style>"""


def _inject_spirit_nav_style(html: str) -> str:
    if 'id="accumulators-spirit-nav-fix"' in html or "spirit-nav" not in html:
        return html
    return re.sub(r"</head\s*>", _SPIRIT_NAV_HEAD_STYLE + "\n</head>", html, count=1, flags=re.I)


def patch_reference(text: str) -> str:
    text = text.replace("\r\n", "\n")
    text = text.replace("../../../../../doc/src/boostbook.css", "../_/css/boostlook.css")
    text = text.replace("../../../../../boost.png", "../_/img/boost.png")
    text = text.replace("../../../../../doc/src/images/", "../_/img/")
    text = text.replace('href="../../../../../index.html"', 'href="../index.html"')
    text = text.replace('href="../../../../../libs/', 'href="https://www.boost.org/libs/')
    text = text.replace('href="../../../../../more/', 'href="https://www.boost.org/more/')
    text = text.replace("../doxygen/accumulators_framework_reference/", "../_/ref/accumulators_framework_reference/")
    text = re.sub(
        r'href="\.\./\.\./\.\./\.\./boost/([^"]+)"',
        r'href="https://github.com/boostorg/accumulators/blob/develop/include/boost/\1"',
        text,
    )
    return _inject_spirit_nav_style(text)


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: fix_reference_html_paths.py <reference.html>", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    raw = path.read_text(encoding="utf-8", errors="replace")
    out = patch_reference(raw)
    path.write_text(out, encoding="utf-8")
    print("patched", path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
