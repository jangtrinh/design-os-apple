#!/usr/bin/env python3
"""Check the published Swift quickstarts agree, without requiring an Apple SDK.

Only line endings and surrounding newline characters are normalized. Indentation,
spaces, and blank lines within the source remain part of the parity contract.
"""

import argparse
import difflib
from html.parser import HTMLParser
from pathlib import Path
import sys

START = "<!-- verify-swift-start -->"
END = "<!-- verify-swift-end -->"


class QuickstartError(ValueError):
    """A missing, malformed, or divergent published quickstart."""


def normalize(source):
    return source.replace("\r\n", "\n").replace("\r", "\n").strip("\n")


def bounded_example(document, name):
    if document.count(START) != 1 or document.count(END) != 1:
        raise QuickstartError(f"E_QUICKSTART_MARKERS: {name}: expected exactly one start and end marker")
    start = document.index(START) + len(START)
    end = document.index(END)
    if end < start:
        raise QuickstartError(f"E_QUICKSTART_MARKERS: {name}: end marker precedes start marker")
    return normalize(document[start:end])


def markdown_source(document, name):
    lines = bounded_example(document, name).split("\n")
    if len(lines) < 3 or lines[0] != "```swift" or lines[-1] != "```":
        raise QuickstartError(f"E_QUICKSTART_EXTRACTION: {name}: expected one fenced Swift example")
    if any(line.lstrip().startswith("```") for line in lines[1:-1]):
        raise QuickstartError(f"E_QUICKSTART_EXTRACTION: {name}: unexpected nested or extra code fence")
    source = normalize("\n".join(lines[1:-1]))
    if not source.strip():
        raise QuickstartError(f"E_QUICKSTART_EXTRACTION: {name}: Swift example is empty")
    return source


class SwiftHTMLParser(HTMLParser):
    """Require one complete pre/code pair; decode character references once."""

    def __init__(self, name):
        super().__init__(convert_charrefs=True)
        self.name = name
        self.state = 0
        self.parts = []

    def fail(self):
        raise QuickstartError(f"E_QUICKSTART_EXTRACTION: {self.name}: expected one complete <pre><code> example with text only")

    def handle_starttag(self, tag, attrs):
        expected = {0: "pre", 1: "code"}
        if expected.get(self.state) != tag:
            self.fail()
        self.state += 1

    def handle_endtag(self, tag):
        expected = {2: "code", 3: "pre"}
        if expected.get(self.state) != tag:
            self.fail()
        self.state += 1

    def handle_startendtag(self, tag, attrs):
        self.fail()

    def handle_data(self, data):
        if self.state == 2:
            self.parts.append(data)
        elif data.strip():
            self.fail()

    def handle_comment(self, data):
        self.fail()

    def handle_decl(self, decl):
        self.fail()

    def unknown_decl(self, data):
        self.fail()

    def handle_pi(self, data):
        self.fail()


def html_source(document, name):
    parser = SwiftHTMLParser(name)
    parser.feed(bounded_example(document, name))
    parser.close()
    source = normalize("".join(parser.parts))
    if parser.state != 4 or not source.strip():
        parser.fail()
    return source


def verify(root):
    markdown_path = root / "docs/getting-started.md"
    html_path = root / "docs/index.html"
    markdown = markdown_source(markdown_path.read_text(encoding="utf-8"), "docs/getting-started.md")
    html = html_source(html_path.read_text(encoding="utf-8"), "docs/index.html")
    if markdown != html:
        diff = "\n".join(difflib.unified_diff(
            markdown.splitlines(), html.splitlines(),
            fromfile="docs/getting-started.md", tofile="docs/index.html", lineterm=""))
        raise QuickstartError(f"E_QUICKSTART_PARITY: published Swift examples differ\n{diff}")
    return markdown + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent,
                        help="repository root (defaults to this script's repository)")
    parser.add_argument("--output", type=Path, help="write the verified Swift source for native typechecking")
    args = parser.parse_args()
    try:
        source = verify(args.root)
        if args.output:
            args.output.write_text(source, encoding="utf-8")
    except (OSError, UnicodeError, QuickstartError) as error:
        print(error, file=sys.stderr)
        return 1
    print("Published quickstart parity passed (native Swift typecheck is separate).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
