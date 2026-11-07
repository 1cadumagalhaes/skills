#!/usr/bin/env bash
# Compare the vendored skills against their pinned upstream commits.
#
# Read-only: it clones into a temp dir, never writes to the repo. For every
# source in skills.lock.yaml it reports
#   drift     the vendored SKILL.md differs from upstream at the pin
#             (expected for modified_by_user entries — this says which files)
#   moved     upstream HEAD is no longer the pinned commit
#   missing   the pinned skill no longer exists upstream
#
# Usage: scripts/update-skills.sh [--source <name>] [--fetch] [--quiet]
#   --source  only this source (substring match)
#   --fetch   also ask upstream for its current HEAD (extra network round trip)
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
only=""
fetch_head=0
quiet=0
while [ $# -gt 0 ]; do
  case "$1" in
    --source) only="${2:-}"; shift 2 ;;
    --fetch) fetch_head=1; shift ;;
    --quiet) quiet=1; shift ;;
    *) echo "unknown flag: $1" >&2; exit 2 ;;
  esac
done

python3 - "$repo" "$only" "$fetch_head" "$quiet" <<'PY'
import os, subprocess, sys, tempfile, shutil, glob

repo, only, fetch_head, quiet = sys.argv[1], sys.argv[2], sys.argv[3] == "1", sys.argv[4] == "1"

try:
    import yaml
except ImportError:
    sys.exit("update-skills: PyYAML is required (python3 -m pip install --user pyyaml)")

lock = yaml.safe_load(open(os.path.join(repo, "skills.lock.yaml"), encoding="utf-8")) or {}
sources = lock.get("sources") or {}

def run(args, cwd=None):
    return subprocess.run(args, cwd=cwd, capture_output=True, text=True)

def index_vendor():
    """Every vendored skill by directory name, at any depth (flat, nested, personal)."""
    found = {}
    for base in ("personal", "third-party"):
        for path in glob.glob(os.path.join(repo, base, "**", "SKILL.md"), recursive=True):
            found.setdefault(os.path.basename(os.path.dirname(path)), path)
    return found

VENDOR = index_vendor()

def vendor_path(name):
    return VENDOR.get(name)

def find_upstream(root, name):
    matches = glob.glob(os.path.join(root, "**", name, "SKILL.md"), recursive=True)
    return matches[0] if matches else None

total = {"drift": 0, "same": 0, "missing": 0, "moved": 0, "skipped": 0}

for source, body in sorted(sources.items()):
    if only and only not in source:
        continue
    url = body.get("url")
    pinned = {k: v for k, v in body.items() if k != "url" and isinstance(v, dict)}
    if not url or not pinned:
        total["skipped"] += 1
        continue
    pins = {spec.get("pin") for spec in pinned.values() if spec.get("pin")}
    if len(pins) != 1:
        print(f"{source}: {len(pins)} distinct pins — check manually")
    pin = sorted(p for p in pins if p)[0]

    tmp = tempfile.mkdtemp(prefix="skills-update-")
    try:
        init = run(["git", "clone", "-q", "--filter=blob:none", "--no-checkout", url, tmp])
        if init.returncode: raise RuntimeError(init.stderr.strip())
        # Pins are abbreviated SHAs, which cannot be fetched as refs; a blobless
        # clone keeps full history cheaply so git can resolve them, and pulls
        # file contents on demand at checkout.
        got = run(["git", "checkout", "-q", pin], cwd=tmp)
        if got.returncode:
            print(f"{source}: cannot resolve pin {pin}: {got.stderr.strip().splitlines()[-1]}")
            total["skipped"] += 1
            continue

        drift, same, missing = [], 0, []
        for name in sorted(pinned):
            local = vendor_path(name)
            if not local:
                missing.append(name)
                continue
            upstream = find_upstream(tmp, name)
            if not upstream:
                missing.append(name)
                continue
            a = open(local, "rb").read()
            b = open(upstream, "rb").read()
            if a == b: same += 1
            else: drift.append(name)

        moved = ""
        if fetch_head:
            head = run(["git", "ls-remote", "origin", "HEAD"])
            current = head.stdout.split()[0][:len(pin)] if head.returncode == 0 and head.stdout else ""
            if current and not current.startswith(pin):
                moved = current
                total["moved"] += 1

        total["drift"] += len(drift); total["same"] += same; total["missing"] += len(missing)
        line = f"{source}: {same} identical, {len(drift)} drifted, {len(missing)} missing"
        if moved: line += f", upstream moved to {moved}"
        print(line)
        if not quiet:
            for name in drift: print(f"    drifted: {name}")
            for name in missing: print(f"    missing: {name}")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

print(f"\ntotals: {total['same']} identical, {total['drift']} drifted, {total['missing']} missing, "
      f"{total['moved']} source(s) with newer upstream, {total['skipped']} skipped")
print("read-only: nothing was written to the repo")
PY
