"""
Scan modules/ROOT/pages (except deprecations.adoc) for labels marked
with `label--deprecated` or `label:deprecated` (and variants like
`label--deprecated-2025.05`) and check they appear in
modules/ROOT/pages/deprecations.adoc. Print the delta.
"""
from pathlib import Path
import re
import sys
from collections import defaultdict

PAGES_DIR = Path("modules/ROOT/pages")
DEPRECATIONS_FILE = PAGES_DIR / "deprecations.adoc"

# match tokens like: label--deprecated, label--deprecated-2025.05, label:deprecatedXYZ
LABEL_RE = re.compile(r'(label--deprecated[0-9A-Za-z._-]*|label:deprecated[0-9A-Za-z._-]*)')

def collect_labels_in_files(root: Path):
    uses = defaultdict(set)  # label -> set(filepaths)
    for p in root.rglob("*.adoc"):
        if p.resolve() == DEPRECATIONS_FILE.resolve():
            continue
        try:
            txt = p.read_text(encoding="utf-8")
        except Exception:
            continue
        for m in LABEL_RE.findall(txt):
            uses[m].add(str(p))
    return uses

def collect_labels_in_deprecations(path: Path):
    if not path.exists():
        return set()
    try:
        txt = path.read_text(encoding="utf-8")
    except Exception:
        return set()
    return set(LABEL_RE.findall(txt))

def main():
    if not PAGES_DIR.exists():
        print(f"Pages dir not found: {PAGES_DIR}", file=sys.stderr)
        return 2
    uses = collect_labels_in_files(PAGES_DIR)
    declared = collect_labels_in_deprecations(DEPRECATIONS_FILE)

    used_labels = set(uses.keys())
    only_used = sorted(used_labels - declared)
    only_declared = sorted(declared - used_labels)

    print(f"labels found in pages (excluding deprecations.adoc): {len(used_labels)}")
    print(f"labels declared in deprecations.adoc: {len(declared)}")
    print(f"labels used but NOT declared: {len(only_used)}")
    if only_used:
        print()
        for lbl in only_used:
            paths = sorted(uses[lbl])
            print(f"- {lbl}")
            for p in paths:
                print(f"    {p}")

    print()
    print(f"labels declared but NOT used in pages: {len(only_declared)}")
    if only_declared:
        for lbl in only_declared:
            print(f"- {lbl}")

    return 0

if __name__ == "__main__":
    sys.exit(main())