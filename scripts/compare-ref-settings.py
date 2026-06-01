import re
from pathlib import Path
import sys

REF_PATH = Path("modules/ROOT/pages/docker/ref-settings.adoc")
CFG_PATH = Path("modules/ROOT/pages/configuration/configuration-settings.adoc")

def extract_ref_keys(text: str):
    # find the ref table that has the "Neo4j format / Docker format" header
    h = re.search(r'\|===\s*\n\|\s*Neo4j format\s*\n\|\s*Docker format', text, re.I)
    if not h:
        # fallback: search for first table start
        start = text.find('|===')
    else:
        start = h.start()
    # find end of that table (next standalone "|===" after start+1)
    end_idx = text.find('\n|===', start + 1)
    block = text[start:end_idx] if end_idx != -1 else text[start:]
    # left-column entries are lines like: | `some.key.name`
    keys = []
    for m in re.finditer(r'^\|\s*`([^`]*\.[^`]*)`', block, re.M):
        keys.append(m.group(1).strip())
    return sorted(set(keys))

def extract_cfg_keys(text: str):
    return sorted(set(m.group(1).strip() for m in re.finditer(r'===\s*`([^`]+)`', text)))

def main():
    repo_root = Path.cwd()
    ref_file = repo_root / REF_PATH
    cfg_file = repo_root / CFG_PATH
    if not ref_file.exists():
        print(f"Ref file not found: {ref_file}", file=sys.stderr); return 1
    if not cfg_file.exists():
        print(f"Config file not found: {cfg_file}", file=sys.stderr); return 1

    ref_text = ref_file.read_text(encoding='utf-8')
    cfg_text = cfg_file.read_text(encoding='utf-8')

    ref_keys = extract_ref_keys(ref_text)
    cfg_keys = extract_cfg_keys(cfg_text)

    set_ref = set(ref_keys)
    set_cfg = set(cfg_keys)

    only_in_ref = sorted(set_ref - set_cfg)
    only_in_cfg = sorted(set_cfg - set_ref)
    common = sorted(set_ref & set_cfg)

    print(f"ref keys: {len(ref_keys)}  config keys: {len(cfg_keys)}  common: {len(common)}")
    if only_in_ref:
        print(f"\nOnly in ref ({len(only_in_ref)}):")
        for k in only_in_ref:
            print(f"  {k}")
    if only_in_cfg:
        print(f"\nOnly in config ({len(only_in_cfg)}):")
        for k in only_in_cfg:
            print(f"  {k}")
    if not only_in_ref and not only_in_cfg:
        print("\nNo differences found.")
    return 0

if __name__ == "__main__":
    sys.exit(main())