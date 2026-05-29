# Docca runner (Accumulators)

Boost.Accumulators needs small Docca behavior changes for Doxygen output that stock
`tools/docca/docca.py` does not handle (header `\f$` / `\f[` formulas, Boost.Parameter
parameter XML). Those fixes live in `accumulators_docca.py`, which imports the
real Docca module and patches it before `main()`. Doxygen `<formula>` elements are
converted to Asciidoctor `stem:` markup (see `:stem: latexmath` in `pages/main.adoc`).

`accumulators_docca.jam` defines `accumulators_docca.pyreference`, which mirrors
stock `docca.pyreference` but runs `accumulators_docca.py` for the reference
generation step. The doc `Jamfile` imports both `docca` (features, Doxygen) and
`accumulators_docca` (custom pyreference).

When upstream Docca absorbs these fixes, drop this directory and switch the
`Jamfile` back to `docca.pyreference`.
