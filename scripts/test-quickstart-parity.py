#!/usr/bin/env python3
"""Portable regression probes for the published quickstart contract."""

import html
import importlib.util
import os
import shutil
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "scripts/verify-quickstart-parity.py"
spec = importlib.util.spec_from_file_location("quickstart_parity", SCRIPT)
parity = importlib.util.module_from_spec(spec)
spec.loader.exec_module(parity)


def markdown(code):
    return f"{parity.START}\n```swift\n{code}\n```\n{parity.END}"


def landing(code):
    return f"{parity.START}\n<pre><code>{html.escape(code)}</code></pre>\n{parity.END}"


class QuickstartParityTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="quickstart-parity-")
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / "docs").mkdir()
        self.md_path = self.root / "docs/getting-started.md"
        self.html_path = self.root / "docs/index.html"
        self.code = 'import SwiftUI\n\nstruct Example {\n  let title = "Account"\n}'
        self.write(self.code, self.code)

    def write(self, md, web):
        self.md_path.write_text(markdown(md), encoding="utf-8")
        self.html_path.write_text(landing(web), encoding="utf-8")

    def test_repository_examples_agree(self):
        self.assertIn("struct AccountList", parity.verify(ROOT))

    def test_valid_example_returns_native_source(self):
        self.assertEqual(parity.verify(self.root), self.code + "\n")

    def test_drift_fails_with_source_diff(self):
        self.write(self.code, self.code.replace("Account", "Profile"))
        with self.assertRaisesRegex(parity.QuickstartError, "E_QUICKSTART_PARITY"):
            parity.verify(self.root)

    def test_indentation_is_not_collapsed(self):
        self.write(self.code, self.code.replace("  let", " let"))
        with self.assertRaisesRegex(parity.QuickstartError, "E_QUICKSTART_PARITY"):
            parity.verify(self.root)

    def test_internal_blank_lines_are_not_collapsed(self):
        self.write(self.code, self.code.replace("\n\n", "\n"))
        with self.assertRaisesRegex(parity.QuickstartError, "E_QUICKSTART_PARITY"):
            parity.verify(self.root)

    def test_html_entities_decode_once(self):
        code = 'let text = "<&> &amp; &#39;"\nlet generic: Array<String> = []'
        self.write(code, code)
        self.assertEqual(parity.verify(self.root), code + "\n")

    def test_numeric_html_entities(self):
        self.html_path.write_text(landing(self.code).replace("Account", "Acc&#111;unt"), encoding="utf-8")
        self.assertEqual(parity.verify(self.root), self.code + "\n")

    def test_line_endings_and_outer_newlines_normalize(self):
        self.md_path.write_bytes(markdown("\n" + self.code + "\n").replace("\n", "\r\n").encode())
        self.html_path.write_bytes(landing(self.code).replace("\n", "\r").encode())
        self.assertEqual(parity.verify(self.root), self.code + "\n")

    def test_missing_markers(self):
        for extractor, document in [(parity.markdown_source, markdown(self.code)), (parity.html_source, landing(self.code))]:
            for marker in [parity.START, parity.END]:
                with self.subTest(extractor=extractor.__name__, marker=marker):
                    with self.assertRaisesRegex(parity.QuickstartError, "E_QUICKSTART_MARKERS"):
                        extractor(document.replace(marker, ""), "fixture")

    def test_duplicate_markers(self):
        for extractor, document in [(parity.markdown_source, markdown(self.code)), (parity.html_source, landing(self.code))]:
            for marker in [parity.START, parity.END]:
                with self.subTest(extractor=extractor.__name__, marker=marker):
                    with self.assertRaisesRegex(parity.QuickstartError, "E_QUICKSTART_MARKERS"):
                        extractor(document + marker, "fixture")

    def test_reversed_markers(self):
        document = parity.END + "\n" + parity.START
        for extractor in [parity.markdown_source, parity.html_source]:
            with self.subTest(extractor=extractor.__name__):
                with self.assertRaisesRegex(parity.QuickstartError, "precedes"):
                    extractor(document, "fixture")

    def test_malformed_markdown_fences(self):
        for body in ["swift\ncode", "```python\ncode\n```", "```swift\ncode", "```swift\ncode\n```\nprose", "```swift\ncode\n```\n```swift\nother\n```"]:
            with self.subTest(body=body):
                with self.assertRaisesRegex(parity.QuickstartError, "E_QUICKSTART_EXTRACTION"):
                    parity.markdown_source(parity.START + "\n" + body + "\n" + parity.END, "fixture")

    def test_malformed_html(self):
        for body in ["<code>code</code>", "<pre><code>code</pre></code>", "<pre><code>code", "<pre><code><span>code</span></code></pre>", "<pre><code>code</code></pre>extra", "<pre><code>one</code></pre><pre><code>two</code></pre>", "<pre><code>code<br/></code></pre>", "<pre><code><!-- hidden -->code</code></pre>"]:
            with self.subTest(body=body):
                with self.assertRaisesRegex(parity.QuickstartError, "E_QUICKSTART_EXTRACTION"):
                    parity.html_source(parity.START + body + parity.END, "fixture")

    def test_empty_examples_fail(self):
        for extractor, document in [(parity.markdown_source, markdown("   ")), (parity.html_source, landing("   "))]:
            with self.subTest(extractor=extractor.__name__):
                with self.assertRaisesRegex(parity.QuickstartError, "E_QUICKSTART_EXTRACTION"):
                    extractor(document, "fixture")

    def test_cli_writes_verified_source(self):
        output = self.root / "verified.swift"
        result = subprocess.run([sys.executable, str(SCRIPT), "--root", str(self.root), "--output", str(output)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(output.read_text(), self.code + "\n")

    def test_cli_drift_does_not_write_output(self):
        self.write(self.code, self.code + "\ninvalidAPI()")
        output = self.root / "verified.swift"
        result = subprocess.run([sys.executable, str(SCRIPT), "--root", str(self.root), "--output", str(output)], capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_QUICKSTART_PARITY", result.stderr)
        self.assertFalse(output.exists())

    def run_stubbed_native_gate(self):
        if not shutil.which("zsh"):
            self.skipTest("zsh is unavailable; Python parity tests still run")
        scripts = self.root / "scripts"
        scripts.mkdir()
        shutil.copy2(SCRIPT, scripts / SCRIPT.name)
        gate = scripts / "verify-consumer-quickstart.sh"
        shutil.copy2(ROOT / "scripts/verify-consumer-quickstart.sh", gate)
        commands = self.root / "bin"
        commands.mkdir()
        for name in ["swift", "xcrun"]:
            command = commands / name
            command.write_text('#!/bin/sh\nprintf "%s\\n" "' + name + ' $*" >> "$QUICKSTART_CALL_LOG"\n'
                               'if [ "$2" = "--show-bin-path" ]; then printf "/unused-stub-modules\\n"; fi\n')
            command.chmod(0o755)
        log = self.root / "native-calls.txt"
        env = dict(os.environ, PATH=str(commands) + os.pathsep + os.environ["PATH"],
                   QUICKSTART_CALL_LOG=str(log))
        result = subprocess.run(["zsh", str(gate)], env=env, capture_output=True, text=True)
        return result, log.read_text().splitlines() if log.exists() else []

    def test_gate_stops_before_native_commands_on_drift(self):
        self.write(self.code, self.code + "\ninvalidAPI()")
        result, calls = self.run_stubbed_native_gate()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("E_QUICKSTART_PARITY", result.stderr)
        self.assertEqual(calls, [])

    def test_gate_preserves_native_build_then_typecheck(self):
        # These commands are stubs: this checks orchestration, not Swift compilation.
        result, calls = self.run_stubbed_native_gate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[:2], ["swift build --target DesignOSApple", "swift build --show-bin-path"])
        self.assertEqual(len(calls), 3)
        self.assertTrue(calls[2].startswith("xcrun swiftc -typecheck -parse-as-library -I "))

    def test_cli_missing_file_has_readable_failure(self):
        self.html_path.unlink()
        result = subprocess.run([sys.executable, str(SCRIPT), "--root", str(self.root)], capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("index.html", result.stderr)
        self.assertNotIn("Traceback", result.stderr)


if __name__ == "__main__":
    unittest.main()
