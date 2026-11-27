#!/usr/bin/env python3
"""Adversarial cases for prose_only() in check.sh.

The hygiene rules read prose only: a dash inside a code specimen is content, not a
style violation. That distinction decides whether check.sh reports a real problem or
demands an edit to code, so the cases below pin it.

Cases G and H are known limitations, asserted as they are. Both are Markdown shapes
that cannot be told apart cheaply: a four-space indented block is indistinguishable
from a list continuation, and a backtick span that wraps a line escapes a per-line
regex. If either is fixed, the expectation here changes with it.

Run: python3 scripts/check-selftest.py
"""
import importlib.util
import re
import sys
import tempfile
from pathlib import Path

DASH = re.compile(r"[\u2013\u2014]")

CASES = [
    ("a plain prose dash counts", "a — b\n", 1),
    ("a fenced block is skipped", "```\na — b\n```\n", 0),
    ("an inline span is skipped", "use `a — b` here\n", 0),
    ("a tilde fence is skipped", "~~~\na — b\n~~~\n", 0),
    ("a fence inside a fence is content", "~~~\n```\na — b\n```\n~~~\n", 0),
    ("an unclosed fence swallows the rest", "text\n\n```\na — b\n", 0),
    ("a close marker shorter than the open one does not close", "~~~~\n~~~\na — b\n~~~~\n", 0),
    # known limitation G: an indented block is read as prose
    ("LIMITATION: a four-space indented block counts", "x\n\n    a — b\n", 1),
    # known limitation H: a span that wraps a line is not recognised
    ("LIMITATION: a span across two lines counts", "use `a —\nb` here\n", 1),
]


def load_prose_only():
    src = (Path(__file__).resolve().parent / "check.sh").read_text(encoding="utf-8").splitlines()
    start = next(i for i, line in enumerate(src) if line.startswith("def prose_only"))
    end = start + 1
    while end < len(src) and (not src[end].strip() or src[end].startswith((" ", "\t"))):
        end += 1
    with tempfile.NamedTemporaryFile("w", suffix=".py", delete=False, encoding="utf-8") as fh:
        fh.write("import re\n" + "\n".join(src[start:end]) + "\n")
        path = fh.name
    spec = importlib.util.spec_from_file_location("prose_only", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.prose_only


def main() -> int:
    prose_only = load_prose_only()
    failures = 0
    for name, body, expected in CASES:
        got = len(DASH.findall(prose_only(body)))
        ok = got == expected
        failures += 0 if ok else 1
        print(f"{'ok  ' if ok else 'FAIL'} {name:56} expected {expected}, got {got}")
    total = len(CASES)
    print(f"\n{total - failures}/{total} cases hold")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
