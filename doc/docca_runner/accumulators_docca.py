#!/usr/bin/env python
#
# Copyright (C) 2026 Ming Yang Zhang, Leo Chen
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
#
# Thin wrapper around tools/docca/docca.py for Boost.Accumulators. Applies
# Accumulators-specific fixes without modifying the shared docca.py:
#   - Doxygen <formula> from \\f$...\\f$ / \\f[...\\f] in header comments
#   - Boost.Parameter-style parameter XML from Doxygen
#

import os
import sys


def _tools_docca_path():
    here = os.path.dirname(os.path.realpath(__file__))
    boost_root = os.path.abspath(os.path.join(here, '..', '..', '..', '..'))
    return os.path.join(boost_root, 'tools', 'docca', 'docca.py')


def _formula_raw_text(element, docca, index, allow_missing_refs=False):
    if element.text:
        return element.text.strip()
    parts = docca.phrase_content(
        element, index, allow_missing_refs=allow_missing_refs)
    return ''.join(p for p in parts if isinstance(p, str)).strip()


def _normalize_formula(text):
    display = False
    if text.startswith(r'\['):
        display = True
        text = text[2:].lstrip()
        if text.endswith(r'\]'):
            text = text[:-2].rstrip()
    elif text.startswith('$$'):
        display = True
        text = text[2:].lstrip()
        if text.endswith('$$'):
            text = text[:-2].rstrip()
    elif text.startswith('$'):
        text = text[1:].lstrip()
        if text.endswith('$'):
            text = text[:-1].rstrip()
    return text, display


def _apply_patches(docca):
    class Formula(docca.Phrase):
        def __init__(self, latex, display=False):
            super().__init__([latex])
            self.latex = latex
            self.display = display

    docca.Formula = Formula

    _orig_construct_environment = docca.construct_environment

    def construct_environment(loader, config):
        env = _orig_construct_environment(loader, config)
        env.tests['Formula'] = lambda x: isinstance(x, Formula)
        return env

    docca.construct_environment = construct_environment

    _orig_make_phrase = docca.make_phrase

    def make_phrase(element, index, allow_missing_refs=False):
        if element.tag == 'formula':
            text, display = _normalize_formula(
                _formula_raw_text(
                    element, docca, index,
                    allow_missing_refs=allow_missing_refs))
            return Formula(text, display)
        return _orig_make_phrase(
            element, index, allow_missing_refs=allow_missing_refs)

    docca.make_phrase = make_phrase

    def parameter_init(self, element, parent):
        self.type = docca.text_with_refs(element.find('type'), parent.index)
        self.default_value = docca.text_with_refs(
            element.find('defval'), parent.index)

        self.description = element.find('briefdescription')
        if self.description is not None:
            self.description = docca.make_blocks(self.description, parent)
        else:
            self.description = []

        self.name = element.find('declname')
        if self.name is not None:
            self.name = self.name.text

        self.array = docca.text_with_refs(element.find('array'), parent.index)
        if self.array:
            if (isinstance(self.type[-1], str)
                    and self.type[-1].endswith('(&)')):
                self.type[-1] = self.type[-1][:-3]
            else:
                self.array = None

        self.args = docca.text_with_refs(
            element.find('argsstring'), parent.index)
        if self.args:
            if (isinstance(self.type[-1], str)
                    and isinstance(self.args[0], str)
                    and self.type[-1].endswith('(*')
                    and self.args[0].startswith(')(')):
                self.type[-1] = self.type[-1][:-2]
                self.args[0] = self.args[0][1:]
            else:
                self.args = None

    docca.Parameter.__init__ = parameter_init


def main():
    tools_docca = _tools_docca_path()
    if not os.path.isfile(tools_docca):
        sys.stderr.write(
            'accumulators_docca.py: could not find %s\n' % tools_docca)
        sys.exit(1)

    sys.path.insert(0, os.path.dirname(tools_docca))
    import docca  # noqa: E402

    _apply_patches(docca)
    docca.main(sys.argv, sys.stdin, sys.stdout, tools_docca)


if __name__ == '__main__':
    main()
