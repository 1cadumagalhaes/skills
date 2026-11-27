#!/usr/bin/env bash
# Reconcile the ~/.agents/skills farm and every harness mirror with this repo.
#
# The link name comes from each SKILL.md frontmatter `name` (never the directory
# basename), so frontend/build/SKILL.md is linked as `frontend-build`.
#
# Sources:
# - clusters: base/ engineering/ frontend/ motion/ process/ (any <cluster>/<dir>/SKILL.md)
# - external: paths listed under `external:` in skills.lock.yaml
# - parked/<pack> via --pack <name> (repeatable; --pack all)
#
# Each farm entry is then mirrored into ~/.claude/skills, ~/.codex/skills,
# ~/.kiro/skills and ~/.gemini/config/skills as a link to the farm path.
# Reconciliation only removes links that point into this repo or into the farm;
# real directories are never deleted and foreign links are never touched.
#
# Flags:
#   --dry-run          print the plan, write nothing
#   --check            report drift only, exit 1 on any drift, write nothing
#   --without <name>   keep <name> off the farm and mirrors (repeatable; ablation)
#   --pack <name>      mount parked pack(s) (repeatable; `--pack all`)
#   --list-packs       list parked packs with SKILL.md counts
#
# Usage:
#   scripts/link.sh [--dry-run] [--check] [--without <name>]... [--pack <name>]... [--list-packs]
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
farm="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"

python3 - "$repo" "$farm" "$HOME" "$@" <<'PY'
import glob
import os
import signal
import sys

signal.signal(signal.SIGPIPE, signal.SIG_DFL)

try:
    import yaml
except ImportError:
    sys.exit("link.sh: PyYAML is required (python3 -m pip install --user pyyaml)")

repo, farm, home, *argv = sys.argv[1:]
farm = os.path.abspath(os.path.expanduser(farm))

USAGE = "usage: scripts/link.sh [--dry-run] [--check] [--without <name>]... [--pack <name>]... [--list-packs]"

dry = False
check = False
list_packs = False
without: list[str] = []
requested_packs: list[str] = []

i = 0
while i < len(argv):
    arg = argv[i]
    if arg == "--dry-run":
        dry = True
        i += 1
    elif arg == "--check":
        check = True
        dry = True
        i += 1
    elif arg == "--list-packs":
        list_packs = True
        i += 1
    elif arg in ("--without", "--pack"):
        if i + 1 >= len(argv):
            sys.exit(f"link.sh: {arg} requires a value\n{USAGE}")
        (without if arg == "--without" else requested_packs).append(argv[i + 1])
        i += 2
    elif arg in ("-h", "--help"):
        print(USAGE)
        sys.exit(0)
    else:
        sys.exit(f"link.sh: unknown option: {arg}\n{USAGE}")

lock_path = os.path.join(repo, "skills.lock.yaml")
lock = (yaml.safe_load(open(lock_path, encoding="utf-8")) or {}) if os.path.exists(lock_path) else {}
external_skills = lock.get("external") or {}

parked_root = os.path.join(repo, "parked")
available_packs = sorted(
    d for d in os.listdir(parked_root)
    if os.path.isdir(os.path.join(parked_root, d)) and not d.startswith(".")
) if os.path.isdir(parked_root) else []

def pack_skills(pack: str) -> list[str]:
    return sorted(glob.glob(os.path.join(parked_root, pack, "**", "SKILL.md"), recursive=True))

if list_packs:
    for pack in available_packs:
        print(f"{pack}\t({len(pack_skills(pack))} SKILL.md directories)")
    sys.exit(0)

if "all" in requested_packs:
    requested_packs = list(available_packs)
else:
    unknown = [p for p in requested_packs if p not in available_packs]
    if unknown:
        sys.exit(f"link.sh: unknown pack(s): {', '.join(unknown)} (available: {', '.join(available_packs)})")

def frontmatter(path: str) -> dict:
    lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
    if not lines or lines[0].strip() != "---":
        return {}
    for end in range(1, len(lines)):
        if lines[end].strip() == "---":
            data = yaml.safe_load("\n".join(lines[1:end])) or {}
            return data if isinstance(data, dict) else {}
    return {}

def skill_name(md_path: str) -> str:
    name = frontmatter(md_path).get("name")
    if not isinstance(name, str) or not name.strip():
        sys.exit(f"link.sh: {md_path}: frontmatter is missing a string `name`")
    return name.strip()

wanted: dict[str, str] = {}

def add(name: str, skill_dir: str) -> None:
    skill_dir = os.path.abspath(skill_dir)
    if name in wanted:
        if wanted[name] != skill_dir:
            print(f"link.sh: duplicate skill name {name!r}: keeping {wanted[name]}, ignoring {skill_dir}",
                  file=sys.stderr)
        return
    wanted[name] = skill_dir

# Cluster skills, ordered by the canonical cluster list first.
CLUSTERS = ("base", "engineering", "frontend", "motion", "process")
cluster_dirs: dict[str, list[str]] = {}
for entry in sorted(os.listdir(repo)):
    path = os.path.join(repo, entry)
    if entry.startswith(".") or entry in ("parked", "scripts", "licenses") or not os.path.isdir(path):
        continue
    mds = sorted(glob.glob(os.path.join(path, "*", "SKILL.md")))
    if mds:
        cluster_dirs[entry] = mds
ordered = [c for c in CLUSTERS if c in cluster_dirs] + sorted(c for c in cluster_dirs if c not in CLUSTERS)
for cluster in ordered:
    for md in cluster_dirs[cluster]:
        add(skill_name(md), os.path.dirname(md))

# External local project skills (e.g. olorin).
for name, path in sorted(external_skills.items()):
    if not isinstance(path, str):
        continue
    skill_dir = os.path.expanduser(path)
    if not os.path.exists(os.path.join(skill_dir, "SKILL.md")):
        print(f"link.sh: external skill {name!r} not found at {skill_dir}", file=sys.stderr)
        continue
    add(name, skill_dir)

# Requested parked packs: every SKILL.md under parked/<pack>.
for pack in requested_packs:
    for md in pack_skills(pack):
        add(skill_name(md), os.path.dirname(md))

excluded: list[str] = []
for name in without:
    if name in excluded:
        continue
    excluded.append(name)
    if name in wanted:
        del wanted[name]
    else:
        print(f"link.sh: --without {name}: no active skill with that name", file=sys.stderr)
excluded_set = set(excluded)

repo_n = os.path.normpath(repo)
farm_n = os.path.normpath(farm)

def is_managed_target(*paths: str) -> bool:
    """True when a link target lives inside this repo or inside the farm."""
    for raw in paths:
        if not raw:
            continue
        norm_path = os.path.normpath(raw)
        for root in (repo_n, farm_n):
            if norm_path == root or norm_path.startswith(root + os.sep):
                return True
    return False

def link_target(link_path: str) -> tuple[str, str]:
    raw = os.readlink(link_path)
    resolved = raw if os.path.isabs(raw) else os.path.join(os.path.dirname(link_path), raw)
    return raw, os.path.normpath(resolved)

def reconcile(target_dir: str, desired: dict[str, str], label: str) -> dict[str, int]:
    counts = {"linked": 0, "removed": 0, "excluded": 0, "drift": 0}
    if not dry:
        os.makedirs(target_dir, exist_ok=True)
    entries = sorted(os.listdir(target_dir)) if os.path.isdir(target_dir) else []

    for entry in entries:
        link_path = os.path.join(target_dir, entry)
        if not os.path.islink(link_path):
            continue  # real directory/file: never touched
        raw, resolved = link_target(link_path)
        if entry in desired:
            if os.path.realpath(link_path) == os.path.realpath(desired[entry]):
                continue
            if check:
                print(f"[{label}] drift: {entry} -> {resolved}, want {desired[entry]}")
                counts["drift"] += 1
            elif dry:
                print(f"[{label}] would relink {entry} -> {desired[entry]}")
                counts["linked"] += 1
            else:
                os.unlink(link_path)
                os.symlink(desired[entry], link_path)
                counts["linked"] += 1
            continue
        if entry in excluded_set:
            # Ablation exclusions: reported by name only in --check, where the line
            # is drift evidence; a plan (--dry-run) counts them so the printed plan
            # lists exactly the active set. Real runs drop the link.
            counts["excluded"] += 1
            if check:
                print(f"[{label}] drift: {entry} is linked but excluded by --without")
                counts["drift"] += 1
            elif not dry:
                os.unlink(link_path)
            continue
        if not is_managed_target(resolved, raw):
            continue  # foreign link: points outside this repo and the farm, never touched
        if check:
            print(f"[{label}] drift: {entry} -> {resolved} is no longer wanted")
            counts["drift"] += 1
        elif dry:
            print(f"[{label}] would remove {entry} (unwanted)")
            counts["removed"] += 1
        else:
            os.unlink(link_path)
            counts["removed"] += 1

    for name, src in sorted(desired.items()):
        link_path = os.path.join(target_dir, name)
        if os.path.islink(link_path):
            continue  # already handled above
        if os.path.lexists(link_path):
            print(f"link.sh: [{label}] skip {name}: real path exists at {link_path}", file=sys.stderr)
            continue
        if check:
            print(f"[{label}] drift: missing {name} -> {src}")
            counts["drift"] += 1
        elif dry:
            print(f"[{label}] would link   {name} -> {src}")
            counts["linked"] += 1
        else:
            os.symlink(src, link_path)
            counts["linked"] += 1

    return counts

def active_links(target_dir: str, fallback: int) -> int:
    if os.path.isdir(target_dir):
        return sum(1 for e in os.listdir(target_dir) if os.path.islink(os.path.join(target_dir, e)))
    return fallback

def report(label: str, target_dir: str, counts: dict[str, int]) -> None:
    if check:
        print(f"{label:6s} ({target_dir}): {counts['drift']} drift")
    elif dry:
        print(f"{label:6s} ({target_dir}): dry run: {counts['linked']} to link, "
              f"{counts['removed']} to remove, {counts['excluded']} excluded")
    else:
        print(f"{label:6s} ({target_dir}): linked {counts['linked']}, removed {counts['removed']}, "
              f"excluded {counts['excluded']}; {active_links(target_dir, len(wanted))} active links")

# 1. Farm: real skill directories.
farm_counts = reconcile(farm, wanted, "farm")
report("farm", farm, farm_counts)

# 2. Mirrors: link every farm entry to the farm path, plus farm links that live
# outside this repo (they are not ours to remove, but harnesses expect them).
mirror_desired = {name: os.path.join(farm, name) for name in wanted}
# A real directory in the farm is a skill too: instabox on the fleet and a couple of dozen
# personal skills on the MacBook live here rather than linking from this repo, and every
# harness expects them. A real directory wins over a link and is never overwritten.
if os.path.isdir(farm):
    for entry in sorted(os.listdir(farm)):
        path = os.path.join(farm, entry)
        if entry in wanted or entry in excluded_set:
            continue
        if os.path.isdir(path) and not os.path.islink(path):
            mirror_desired[entry] = path
            continue
        if not os.path.islink(path):
            continue
        raw, resolved = link_target(path)
        if os.path.exists(path) and not is_managed_target(resolved, raw):
            mirror_desired[entry] = path

MIRRORS = (
    ("claude", os.path.join(home, ".claude", "skills")),
    ("codex", os.path.join(home, ".codex", "skills")),
    ("kiro", os.path.join(home, ".kiro", "skills")),
    ("gemini", os.path.join(home, ".gemini", "config", "skills")),
    ("opencode", os.path.join(home, ".config", "opencode", "skills")),
)

drift = farm_counts["drift"]
for label, mirror_dir in MIRRORS:
    counts = reconcile(mirror_dir, mirror_desired, label)
    report(label, mirror_dir, counts)
    drift += counts["drift"]

if check:
    if drift:
        print(f"check: {drift} drift(s) in farm/mirrors")
        sys.exit(1)
    print("check: no drift")
PY
