#!/usr/bin/env bash
# Report real skill usage from Pi session transcripts.
#
# A skill counts as invoked only when a tool call argument or a tool result body
# contains a path into that skill (skills/<name>/SKILL.md, references/, scripts/).
# System prompt lists are ignored: they mention every skill, they do not use it.
#
# Method (cost): every assistant message whose toolCall args (or whose following
# toolResult body) matched a skill opens a window; the window closes at the next
# user message. Cost is the sum of usage.cost.total over the assistant messages in
# that window. Missing usage fields count as 0.
#
# Usage: scripts/usage.sh [--dir <dir>] [--write]
#   --dir <dir>  scan this directory instead of ~/.pi/agent/sessions (+ archive)
#   --write      write USAGE.md in the repo root instead of stdout
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
dir=""
write=0

while [ $# -gt 0 ]; do
  case "$1" in
    --dir)
      [ $# -ge 2 ] || { echo "usage: --dir requires a directory" >&2; exit 1; }
      dir="$2"
      shift 2
      ;;
    --write) write=1; shift ;;
    -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "usage.sh: unknown argument '$1'" >&2; exit 1 ;;
  esac
done

python3 - "$repo" "$dir" "$write" "$HOME" <<'PY'
import glob
import json
import os
import re
import sys
import time

repo, dir_arg, write, home = sys.argv[1], sys.argv[2], sys.argv[3] == "1", sys.argv[4]
clusters = ("base", "engineering", "frontend", "motion", "process")

# 47 skill names and their repo directories, straight from the frontmatter.
skill_dir: dict[str, str] = {}
skill_cluster: dict[str, str] = {}
for cluster in clusters:
    for skill_md in sorted(glob.glob(os.path.join(repo, cluster, "*", "SKILL.md"))):
        name = None
        with open(skill_md, encoding="utf-8", errors="replace") as fh:
            for i, line in enumerate(fh):
                if i == 0 and line.strip() != "---":
                    break
                if i > 0 and line.strip() == "---":
                    break
                if line.startswith("name:"):
                    name = line.split(":", 1)[1].strip().strip("\"'")
                    break
        if not name:
            continue
        skill_dir[name] = os.path.dirname(skill_md)
        skill_cluster[name] = cluster

names = set(skill_dir)
path_re = re.compile(
    r"(?P<path>[~/.A-Za-z0-9_-]*skills/(?P<name>[A-Za-z0-9._-]+)/(?:SKILL\.md|references/|scripts/)[^\s\"'`)\]<>|,]*)"
)

if dir_arg:
    scan_dirs = [os.path.expanduser(dir_arg)]
else:
    scan_dirs = [os.path.join(home, ".pi", "agent", "sessions")]
    archive = os.path.join(home, ".pi", "agent", "archive")
    if os.path.isdir(archive):
        scan_dirs.append(archive)

files: list[str] = []
for d in scan_dirs:
    if not os.path.isdir(d):
        continue
    files.extend(sorted(glob.glob(os.path.join(d, "**", "*.jsonl"), recursive=True)))


def matched(text: str) -> list[tuple[str, str]]:
    """Skill name plus matched path for every path that points into a known skill."""
    out = []
    for m in path_re.finditer(text):
        if m.group("name") in names:
            out.append((m.group("name"), m.group("path")))
    return out


def flat_text(content) -> str:
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, dict):
                if block.get("type") == "text":
                    parts.append(str(block.get("text", "")))
                elif block.get("type") == "toolCall":
                    parts.append(json.dumps(block.get("arguments", ""), ensure_ascii=False))
            elif isinstance(block, str):
                parts.append(block)
        return "\n".join(parts)
    return ""


def file_chars(path: str, name: str) -> int | None:
    marker = "skills/%s/" % name
    tail = path.split(marker, 1)[1] if marker in path else ""
    candidates = []
    expanded = os.path.expanduser(path)
    if expanded.startswith("/"):
        candidates.append(expanded)
    elif expanded.startswith("skills/"):
        candidates.append(os.path.join(home, expanded))
        candidates.append(os.path.join(repo, expanded))
    if tail:
        candidates.append(os.path.join(skill_dir[name], tail))
    for cand in candidates:
        if os.path.isfile(cand):
            return os.path.getsize(cand)
    return None


invocations: dict[str, int] = {name: 0 for name in names}
sessions: dict[str, set] = {name: set() for name in names}
last_used: dict[str, str] = {name: "" for name in names}
chars: dict[str, int] = {name: 0 for name in names}
chars_known: dict[str, int] = {name: 0 for name in names}
unknown_chars = 0
cost: dict[str, float] = {name: 0.0 for name in names}
missing_usage = 0
lines_read = 0
bad_lines = 0

started = time.time()
for path in files:
    session_id = os.path.basename(path)
    # events: ("u",) closes a cost window, ("a", cost, skills) opens/continues one.
    events: list[tuple] = []
    pending: list[dict] = []
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            lines_read += 1
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except ValueError:
                bad_lines += 1
                continue
            if entry.get("type") != "message":
                continue
            msg = entry.get("message")
            if not isinstance(msg, dict):
                continue
            role = msg.get("role")
            stamp = entry.get("timestamp") or msg.get("timestamp") or ""
            if role == "user":
                events.append(("u",))
                continue
            if role == "system":
                continue
            if role == "assistant":
                usage = msg.get("usage") if isinstance(msg.get("usage"), dict) else None
                value = 0.0
                if usage is None:
                    missing_usage += 1
                else:
                    money = usage.get("cost")
                    if isinstance(money, dict) and isinstance(money.get("total"), (int, float)):
                        value = float(money["total"])
                    else:
                        missing_usage += 1
                hits = matched(flat_text(msg.get("content")))
                events.append(("a", value, hits, stamp))
                continue
            # toolResult (and any other non-user, non-assistant body)
            hits = matched(flat_text(msg.get("content")))
            if hits and events and events[-1][0] == "a":
                last = events[-1]
                merged = list(last[2])
                seen = {h[0] for h in merged}
                for h in hits:
                    if h[0] not in seen:
                        merged.append(h)
                        seen.add(h[0])
                events[-1] = ("a", last[1], merged, last[3])
            elif hits:
                events.append(("a", 0.0, hits, stamp))

    # Close each invocation window at the next user message.
    for i, ev in enumerate(events):
        if ev[0] != "a" or not ev[2]:
            continue
        window_cost = ev[1]
        for j in range(i + 1, len(events)):
            nxt = events[j]
            if nxt[0] == "u":
                break
            window_cost += nxt[1]
        date = str(ev[3])[:10]
        for name, ref in ev[2]:
            invocations[name] += 1
            sessions[name].add(session_id)
            cost[name] += window_cost
            if date > last_used[name]:
                last_used[name] = date
            size = file_chars(ref, name)
            if size is None:
                unknown_chars += 1
            else:
                chars[name] += size
                chars_known[name] += 1

elapsed = time.time() - started

rows = sorted(names, key=lambda n: (-invocations[n], n))
used = [n for n in rows if invocations[n] > 0]
never = [n for n in rows if invocations[n] == 0]

out = []
out.append("# Skill usage")
out.append("")
out.append(
    "Generated from Pi session transcripts by `scripts/usage.sh`. "
    "A skill counts as invoked only when a tool call argument or a tool result body "
    "contains `skills/<name>/SKILL.md`, `.../references/`, or `.../scripts/`; "
    "system prompt lists are ignored."
)
out.append("")
out.append(
    "Cost method: each matching assistant message opens a window that closes at the next "
    "user message; cost is the sum of `usage.cost.total` over the assistant messages in that "
    "window (missing usage counts as 0). Chars are the on-disk size of the first file matched "
    "per invocation (`-` when the path is not a local file)."
)
out.append("")
out.append(
    f"Scanned {len(files)} session files, {lines_read} lines, in {elapsed:.1f}s. "
    f"{sum(invocations.values())} invocations across {len(used)}/{len(names)} skills."
)
if bad_lines:
    out.append(f"Unparseable lines skipped: {bad_lines}.")
if missing_usage:
    out.append(f"Assistant messages without usage.cost.total: {missing_usage}.")
if unknown_chars:
    out.append(f"Invocations whose file size could not be resolved: {unknown_chars}.")
out.append("")
out.append("| skill | cluster | invocations | sessions | last used | chars | cost (USD) |")
out.append("|---|---|---:|---:|---|---:|---:|")
for name in used:
    out.append(
        f"| `{name}` | {skill_cluster[name]} | {invocations[name]} | {len(sessions[name])} | "
        f"{last_used[name] or '-'} | {chars[name] if chars_known[name] else '-'} | {cost[name]:.4f} |"
    )
out.append("")
if never:
    out.append(f"Never invoked ({len(never)}):")
    out.append("")
    for name in never:
        out.append(f"- `{name}` ({skill_cluster[name]})")
else:
    out.append("Never invoked (0): every skill appears at least once.")
out.append("")

text = "\n".join(out)
if write:
    target = os.path.join(repo, "USAGE.md")
    with open(target, "w", encoding="utf-8") as fh:
        fh.write(text)
    print(f"wrote {target} ({len(used)} skills used, {len(never)} never invoked)")
else:
    sys.stdout.write(text)
PY
