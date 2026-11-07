#!/usr/bin/env bash
# Audit every skill and agent definition pi will load.
#
# Catches the failure mode that costs real debugging time: a frontmatter block
# that does not parse. pi warns on stderr (invisible over the TUI) and then
# silently drops the skill, or falls back to general-purpose with a different
# toolset. An agent with `Not diff-scoped: reports` in an unquoted description
# did exactly that.
#
# Reports: per-file problems, auto/manual counts, and the auto index size in
# tokens (what every request pays for descriptions).
#
# Usage: scripts/check-skills.sh [--quiet]
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
farm="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
agent_dir="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
quiet=0
[ "${1:-}" = "--quiet" ] && quiet=1

python3 - "$repo" "$farm" "$agent_dir" "$quiet" <<'PY'
import os, sys, glob

repo, farm, agent_dir, quiet = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] == "1"

try:
    import yaml
except ImportError:
    sys.exit("check-skills: PyYAML is required (python3 -m pip install --user pyyaml)")

problems = []
skills = []

def frontmatter(path):
    text = open(path, encoding="utf-8").read()
    if text.startswith("\ufeff"):
        text = text[1:]
    if not text.startswith("---"):
        raise ValueError("no frontmatter fence")
    parts = text.split("---", 2)
    if len(parts) < 3:
        raise ValueError("unterminated frontmatter")
    return yaml.safe_load(parts[1]) or {}

# --- skills: the linked farm is the source of truth (one symlink per skill) ---
for entry in sorted(os.listdir(farm)) if os.path.isdir(farm) else []:
    path = os.path.join(farm, entry, "SKILL.md")
    if not os.path.exists(path):
        problems.append((entry, "no SKILL.md"))
        continue
    try:
        fm = frontmatter(path)
    except Exception as error:
        problems.append((entry, str(error).splitlines()[0]))
        continue
    name = fm.get("name")
    if name and name != entry:
        problems.append((entry, f"name mismatch: {name!r}"))
    if not fm.get("description"):
        problems.append((entry, "no description"))
    skills.append((entry, bool(fm.get("disable-model-invocation")), str(fm.get("description") or "")))

# --- agents: same rules, plus pi-subagents' filename fallback ---
agents = []
for path in sorted(glob.glob(os.path.join(agent_dir, "agents", "*.md"))):
    stem = os.path.basename(path)[:-3]
    try:
        fm = frontmatter(path)
    except Exception as error:
        problems.append((f"agent:{stem}", str(error).splitlines()[0]))
        continue
    if fm.get("name") and ":" in str(fm.get("name")):
        problems.append((f"agent:{stem}", "name contains ':' (reserved)"))
    if not fm.get("description"):
        problems.append((f"agent:{stem}", "no description"))
    agents.append(stem)

auto = [s for s in skills if not s[1]]
manual = [s for s in skills if s[1]]
index_chars = sum(len(name) + len(desc) for name, _, desc in auto)

if not quiet:
    print(f"skills   {len(skills):4d}  auto {len(auto)}  manual {len(manual)}  (farm {farm})")
    print(f"agents   {len(agents):4d}  {', '.join(agents) if len(agents) <= 8 else str(len(agents)) + ' defined'}")
    print(f"auto index  {index_chars} chars \u2248 {index_chars // 4} tokens")

if problems:
    print(f"\n{len(problems)} problem(s):")
    for name, reason in problems:
        print(f"  {name}: {reason}")
    sys.exit(1)
if not quiet:
    print("ok")
PY
