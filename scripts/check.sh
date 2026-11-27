#!/usr/bin/env bash
# Structural check for the cluster skill tree (<cluster>/<dir>/SKILL.md).
#
# Exit 1 only on structural problems; lint findings are warnings unless --strict.
#
# Checks:
# 1. Frontmatter: name, cluster (one of five), tier (root|leaf); name matches
#    ^[a-z][a-z0-9-]*$; names unique.
# 2. Forbidden words in name: workflow, craft, contract, spec, expert, sections,
#    optimizer, misc, checklist. `direction` and `taste` are allowed because the
#    cluster prefix already disambiguates them (frontend-direction, frontend-taste).
#    sections, optimizer, taste, misc, checklist.
# 3. Roots are model-invocable except the manual navigation ports; every leaf
#    carries disable-model-invocation: true.
# 4. Budget: at most 14 model-invocable roots; auto index (sum of
#    len(name)+len(description) over model-invocable skills) <= 2800 chars.
# 5. Edges: ~/.agents/skills/<name>/ refs in active SKILL.md. Every leaf needs
#    >=1 incoming edge; leaves may only point at roots.
# 6. Every ~/.agents/skills/<name>/ ref resolves to a known skill.
# 7. Body lint (warnings only, for model-invocable roots).
# 8. Mirror parity: ~/.agents/skills vs claude, codex, kiro, gemini.
#
# Usage: scripts/check.sh [--quiet] [--strict]
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
farm="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
home="${HOME}"
quiet=0
strict=0
audit_flag=0

for arg in "$@"; do
  case "$arg" in
    --quiet) quiet=1 ;;
    --strict) strict=1 ;;
    --audit) audit_flag=1 ;;
    -h|--help)
      sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "check: unknown option: $arg (usage: check.sh [--quiet] [--strict] [--audit])" >&2
      exit 2
      ;;
  esac
done

python3 - "$repo" "$farm" "$home" "$quiet" "$strict" "$audit_flag" <<'PY'
import glob
import os
import re
import sys

try:
    import yaml
except ImportError:
    sys.exit("check: PyYAML is required (python3 -m pip install --user pyyaml)")

repo, farm, home, quiet, strict = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] == "1", sys.argv[5] == "1"
audit = sys.argv[6] == "1"

CLUSTERS = ("base", "engineering", "frontend", "motion", "process")
FORBIDDEN = (
    "workflow", "craft", "contract", "spec", "expert",
    "sections", "optimizer", "misc", "checklist",
)
# Roots that are deliberately manual navigation ports.
MANUAL_ROOTS = {
    "motion-build", "pr", "retro", "research", "prototype",
    "tdd", "grilling", "wizard", "agent-docs", "unslop", "commit",
    "frontend-dashboard-charts",
}
MAX_AUTO_ROOTS = 14
MAX_INDEX = 2800
NAME_RE = re.compile(r"^[a-z][a-z0-9-]*$")
REF_RE = re.compile(r"~/\.agents/skills/([A-Za-z0-9._-]+)/([^\s`)\"'\]]*)")
REL_RE = re.compile(r"\]\(([^)#:]+?\.md)\)")
STEP_RE = re.compile(r"^\s*\d+[.)]\s+(.*)$")
HEADING_RE = re.compile(r"^#{1,6}\s+(.*)$")
FENCE_RE = re.compile(r"^\s*(```+|~~~+)\s*(\S*)")
STEP_PAYOFF_RE = re.compile(r"`[^`]+`|\b(done|verify|expect|check)\b", re.IGNORECASE)
RECOVERY_RE = re.compile(r"fail|error|recover|troubleshoot", re.IGNORECASE)
BASH_INFOS = {"", "bash", "sh", "shell", "console"}

problems: list[str] = []
lint: list[str] = []
skills: dict[str, dict] = {}

# --- discovery -------------------------------------------------------------
for cluster in CLUSTERS:
    for path in sorted(glob.glob(os.path.join(repo, cluster, "*", "SKILL.md"))):
        dir_name = os.path.basename(os.path.dirname(path))
        rel = os.path.relpath(path, repo)
        text = open(path, encoding="utf-8").read()
        if text.startswith("\ufeff"):
            text = text[1:]
        parts = text.split("---", 2)
        fm: dict = {}
        body = ""
        if not text.startswith("---") or len(parts) < 3:
            problems.append(f"{rel}: no frontmatter fence")
        else:
            try:
                fm = yaml.safe_load(parts[1]) or {}
            except yaml.YAMLError as error:
                problems.append(f"{rel}: bad frontmatter ({str(error).splitlines()[0]})")
                fm = {}
            body = parts[2]
        if not isinstance(fm, dict):
            problems.append(f"{rel}: frontmatter is not a mapping")
            fm = {}
        name = fm.get("name")
        label = str(name) if isinstance(name, str) and name else rel
        skills[label] = {
            "name": str(name) if isinstance(name, str) else "",
            "dir": dir_name,
            "rel": rel,
            "cluster": fm.get("cluster"),
            "tier": fm.get("tier"),
            "manual": fm.get("disable-model-invocation") is True,
            "desc": str(fm.get("description") or ""),
            "body": body,
            "path": path,
            "refs": [],
        }

# --- 1. required frontmatter, name shape, uniqueness -----------------------
seen: dict[str, str] = {}
for label, s in sorted(skills.items(), key=lambda kv: kv[1]["rel"]):
    rel = s["rel"]
    name = s["name"]
    if not name:
        problems.append(f"{rel}: missing name")
    elif not NAME_RE.match(name):
        problems.append(f"{rel}: name {name!r} does not match ^[a-z][a-z0-9-]*$")
    elif name in seen:
        problems.append(f"{rel}: duplicate name {name!r} (also {seen[name]})")
    else:
        seen[name] = rel
    cluster = s["cluster"]
    if cluster is None:
        problems.append(f"{rel}: missing cluster")
    elif cluster not in CLUSTERS:
        problems.append(f"{rel}: cluster {cluster!r} not one of {', '.join(CLUSTERS)}")
    tier = s["tier"]
    if tier is None:
        problems.append(f"{rel}: missing tier")
    elif tier not in ("root", "leaf"):
        problems.append(f"{rel}: tier {tier!r} is not root or leaf")

# --- 2. forbidden words in name -------------------------------------------
for label, s in sorted(skills.items(), key=lambda kv: kv[1]["rel"]):
    tokens = [t for t in re.split(r"[-_]", s["name"]) if t]
    bad = sorted({t for t in tokens if t in FORBIDDEN})
    for word in bad:
        problems.append(f"{s['rel']}: forbidden word {word!r} in name {s['name']!r}")

# --- 3. root/leaf invocation flags ---------------------------------------
auto_roots: list[dict] = []
for label, s in sorted(skills.items(), key=lambda kv: kv[1]["rel"]):
    name, tier, manual = s["name"], s["tier"], s["manual"]
    if tier == "root":
        if manual and name not in MANUAL_ROOTS:
            problems.append(f"{s['rel']}: root carries disable-model-invocation: true (only ports may: {', '.join(sorted(MANUAL_ROOTS))})")
        if not manual:
            auto_roots.append(s)
    elif tier == "leaf" and not manual:
        problems.append(f"{s['rel']}: leaf must carry disable-model-invocation: true")

roots = [s for s in skills.values() if s["tier"] == "root"]
leaves = [s for s in skills.values() if s["tier"] == "leaf"]

# --- 4. budget ------------------------------------------------------------
index_chars = sum(len(s["name"]) + len(s["desc"]) for s in skills.values() if not s["manual"])
if len(auto_roots) > MAX_AUTO_ROOTS:
    problems.append(f"tree: {len(auto_roots)} model-invocable roots exceeds cap {MAX_AUTO_ROOTS}")
if index_chars > MAX_INDEX:
    problems.append(f"tree: auto index {index_chars} chars exceeds cap {MAX_INDEX}")

# --- 5/6. edges and ref resolution ---------------------------------------
farm_entries: dict[str, bool] = {}
farm_links: set[str] = set()
if os.path.isdir(farm):
    for entry in sorted(os.listdir(farm)):
        entry_path = os.path.join(farm, entry)
        farm_entries[entry] = os.path.exists(entry_path)
        if os.path.islink(entry_path):
            farm_links.add(entry)
# Real skill directories that live in the farm instead of being linked from the repo.
farm_real = {e for e in farm_entries if os.path.isdir(os.path.join(farm, e))
             and not os.path.islink(os.path.join(farm, e)) and e.startswith("instabox")}
farm_skills = farm_links | farm_real

known = {s["name"] for s in skills.values() if s["name"]}
known |= {s["dir"] for s in skills.values()}
external_ok = {e for e, ok in farm_entries.items() if ok} - known

by_name = {s["name"]: s for s in skills.values() if s["name"]}
by_dir = {s["dir"]: s for s in skills.values()}

edges: dict[str, set[str]] = {s["name"]: set() for s in skills.values()}
incoming: dict[str, set[str]] = {s["name"]: set() for s in skills.values()}

for label, s in sorted(skills.items(), key=lambda kv: kv[1]["rel"]):
    targets = []
    for match in REF_RE.finditer(s["body"]):
        target = match.group(1)
        tail = match.group(2)
        # A ref to another skill's reference file is a pointer, not a route: it does
        # not load that skill's body and it must not count as an edge (or as
        # reachability). Only the skill entry point counts.
        is_entry = tail == "" or tail.startswith("SKILL.md")
        if target not in targets:
            targets.append((target, is_entry))
    s["refs"] = [t for t, _ in targets]
    for target, is_entry in targets:
        hit = by_name.get(target) or by_dir.get(target)
        if hit is None:
            if target not in external_ok:
                problems.append(f"{s['rel']}: broken ref ~/.agents/skills/{target}/ (no such skill)")
            continue
        if hit["name"] == s["name"] or not is_entry:
            continue
        edges[s["name"]].add(hit["name"])
        incoming.setdefault(hit["name"], set()).add(s["name"])

for s in sorted(skills.values(), key=lambda x: x["rel"]):
    name, tier = s["name"], s["tier"]
    if tier == "leaf":
        if not incoming.get(name):
            problems.append(f"{s['rel']}: leaf has no incoming edge")
        for target in sorted(edges[name]):
            if by_name[target]["tier"] == "leaf":
                problems.append(f"{s['rel']}: leaf points at leaf {target!r} (leaves may point only at roots)")

for s in sorted(skills.values(), key=lambda x: x["rel"]):
    for m in REL_RE.finditer(s["body"]):
        target = m.group(1)
        if not target.startswith(("references/", "../")):
            continue
        base = os.path.dirname(s["path"])
        if not os.path.exists(os.path.normpath(os.path.join(base, target))):
            problems.append(f"{s['rel']}: broken relative link {target}")

# --- 7. body lint for model-invocable roots (warnings only) --------------
def lint_root(s: dict) -> list[str]:
    found = []
    body = s["body"]
    in_fence = False
    steps: list[list[str]] = []
    headings: list[str] = []
    fence_infos: list[str] = []
    current: list[str] | None = None
    for line in body.splitlines():
        fence = FENCE_RE.match(line)
        if fence:
            if not in_fence:
                in_fence = True
                fence_infos.append(fence.group(2).lower())
            else:
                in_fence = False
            current = None
            continue
        if in_fence:
            if current is not None and line.strip():
                current.append(line)
            continue
        step = STEP_RE.match(line)
        heading = HEADING_RE.match(line)
        if step:
            current = [step.group(1)]
            steps.append(current)
            continue
        if heading:
            headings.append(heading.group(1))
            current = None
            continue
        if current is not None:
            if line.strip():
                current.append(line)
            else:
                current = None
    if len(steps) >= 3 and not any(STEP_PAYOFF_RE.search(" ".join(step)) for step in steps):
        found.append(f"{len(steps)} numbered steps, none with a backticked command or done/verify/expect/check")
    if any(info in BASH_INFOS - {""} for info in fence_infos) and not any(RECOVERY_RE.search(h) for h in headings):
        found.append("has a bash block but no fail/error/recover/troubleshoot heading")
    return found

for s in sorted(auto_roots, key=lambda x: x["rel"]):
    for reason in lint_root(s):
        lint.append(f"lint: {s['name']}: {reason}")

# A skill that watches, polls or babysits without naming the native primitive
# teaches the agent to burn turns the harness would spend for free.
POLL_RE = re.compile(r"(--watch\b|\bpoll(?:ing|s)?\b|\bbabysit\w*\b|gh pr checks)", re.I)
NATIVE_RE = re.compile(r"(watch_pull_request|t3_thread_|schedule_task|delegate_task|preview_|task_status)")
for s in sorted(skills.values(), key=lambda x: x["rel"]):
    if POLL_RE.search(s["body"]) and not NATIVE_RE.search(s["body"]):
        lint.append(f"lint: {s['name']}: watches or polls without naming the native primitive")

# A T3-only instruction without a non-T3 path strands every other harness.
NATIVE_ANY_RE = re.compile(r"(watch_pull_request|t3_thread_\w+|schedule_task|delegate_task|preview_\w+|task_status|pull_request_\w+|link_pull_request|ci_logs)")
FALLBACK_RE = re.compile(r"(outside t3|non-t3|fallback|elsewhere|without t3|native mechanism|harness's own|other harness)", re.I)
for s in sorted(skills.values(), key=lambda x: x["rel"]):
    if NATIVE_ANY_RE.search(s["body"]) and not FALLBACK_RE.search(s["body"]):
        lint.append(f"lint: {s['name']}: gives a T3-only path with no non-T3 fallback")

# A body above 12 KB is worth a look: it is loaded in full every time the skill is
# read, and large bodies usually hold reference material that belongs in references/.
BODY_WARN = 12000
# Bodies above the threshold that were looked at and kept, with the reason. A new
# oversized body warns; an accepted one is still listed, so the debt stays visible.
BODY_ACCEPTED = {
    "webscraping": "kept by decision; 16 invocations",
    "frontend-taste": "page run split into references/run-*; body is branch, index and house rules",
    "frontend-stress": "every phase ends on a completion criterion",
    "motion-sequence": "canonical tables moved to references; the rest is sequencing rules",
    "motion-performance": "canonical tables moved to references; per-frame diagnostics remain",
    "motion-vocabulary": "glossary entries; split into references pending",
}
accepted_bodies = []
for s in sorted(skills.values(), key=lambda x: x["rel"]):
    if len(s["body"]) <= BODY_WARN:
        continue
    if s["name"] in BODY_ACCEPTED:
        accepted_bodies.append(f"{s['name']} {len(s['body'])} ({BODY_ACCEPTED[s['name']]})")
    else:
        lint.append(f"lint: {s['name']}: body is {len(s['body'])} chars, consider moving detail to references/")

# Hygiene. Enforced on the clusters we author (base, process); reported as a count
# for absorbed vendor prose, where a mechanical rewrite of hundreds of em dashes
# would change inherited documentation without a reason. Fix those file by file as
# they are touched.
HYGIENE = (
    ("em dash", re.compile(r"[\u2013\u2014]")),
    ("curly quote", re.compile(r"[\u201c\u201d\u2018\u2019]")),
    ("banned word", re.compile(r"\b(delve|leverage|utilize|foster|tapestry|vibrant|testament|underscore|pivotal|showcase|additionally|crucial|enhance)\b", re.I)),
    ("not just X but Y", re.compile(r"\bnot just\b[^.;]{3,60}\bbut\b", re.I)),
    ("chatbot phrase", re.compile(r"\b(I hope this helps|let me know if|feel free to|happy to help)\b", re.I)),
    ("praise opener", re.compile(r"^(great|absolutely|sure|certainly|of course|perfect)[,.!]", re.I | re.M)),
    ("serves as", re.compile(r"\b(serves as|stands as|boasts)\b", re.I)),
    ("bold restates its line", re.compile(r"\*\*([^*:\n]{3,40}):\*\*\s+\1", re.I)),
    ("ing tail", re.compile(r",\s+(highlighting|ensuring|showcasing|enabling|allowing|providing|creating|making)\b", re.I)),
)
def prose_only(body: str) -> str:
    """Drop fenced blocks and inline code spans: a dash or a glyph inside a code
    specimen is part of the specimen, not prose that unslop governs.

    A fence closes only on its own marker character, so a ``` inside a ~~~ block is
    content. Two shapes stay out of reach by design, and scripts/check-selftest.py
    pins them: a four-space indented block (indistinguishable from a list continuation
    in Markdown), and a backtick span that wraps a line.
    """
    out: list[str] = []
    fence: tuple[str, int] | None = None
    for line in body.splitlines():
        marker = re.match(r"^\s*(`{3,}|~{3,})", line)
        if marker:
            token = marker.group(1)
            if fence is None:
                fence = (token[0], len(token))
            elif token[0] == fence[0] and len(token) >= fence[1]:
                fence = None
            continue
        if fence:
            continue
        out.append(re.sub(r"`[^`]*`", " ", line))
    return "\n".join(out)


# A defined term that collides with a banned vowel-word stays, with a reason.
BANNED_ALLOW = {"module-design": {"leverage"}, "tdd": {"leverage"}}
# A banned word that is a literal value of a tool's enum stays, by exact file.
BANNED_ALLOW_PATH = {"frontend/taste/references/run-2-direction.md": {"showcase"}}

hygiene_debt = []
for s in sorted(skills.values(), key=lambda x: x["rel"]):
    counts = []
    prose = prose_only(s["body"])
    for label, pat in HYGIENE:
        # unslop lists the banned words as patterns, so the rule would always fire.
        # unslop quotes the patterns it bans, so every pattern-shaped rule fires on it.
        if s["name"] == "unslop" and label in (
            "banned word", "not just X but Y", "chatbot phrase", "serves as", "bold restates its line"
        ):
            continue
        hits = pat.findall(prose)
        if label == "banned word":
            hits = [h for h in hits if h.lower() not in BANNED_ALLOW.get(s["name"], set())]
        n = len(hits)
        if n:
            counts.append(f"{n} {label}")
    if not counts:
        continue
    line = f"{s['name']} ({', '.join(counts)})"
    if s["cluster"] in ("base", "process"):
        problems.append(f"{s['rel']}: " + ", ".join(counts))
    else:
        hygiene_debt.append(line)

# --- 7c. hygiene across references ---------------------------------------
# A reference is read by an agent too, so the same prose rules apply. Vendored corpora
# are exempt: rewriting hundreds of inherited dashes in Apache-2.0 material that its own
# notice calls unmodified changes someone else's text without authority.
VENDORED = ("frontend/revenue-design/", "frontend/platform-docs/guides/", "frontend/platform-docs/NOTICE.md")
ref_debt = []
ref_paths: list[str] = []
for cluster in CLUSTERS:
    ref_paths += glob.glob(os.path.join(repo, cluster, "**", "*.md"), recursive=True)
for path in sorted(ref_paths):
    rel_path = os.path.relpath(path, repo)
    if rel_path.endswith("/SKILL.md") or any(rel_path.startswith(v) for v in VENDORED):
        continue
    owner = rel_path.split("/")[1]
    prose = prose_only(open(path, encoding="utf-8", errors="replace").read())
    counts = []
    for label, pat in HYGIENE:
        if owner == "unslop" and label in (
            "banned word", "not just X but Y", "chatbot phrase", "serves as", "bold restates its line"
        ):
            continue
        hits = pat.findall(prose)
        if label == "banned word":
            allowed = BANNED_ALLOW.get(owner, set()) | BANNED_ALLOW_PATH.get(rel_path, set())
            hits = [h for h in hits if h.lower() not in allowed]
        if hits:
            counts.append(f"{len(hits)} {label}")
    if counts:
        ref_debt.append(f"{rel_path} ({', '.join(counts)})")

# One table, one home. A skill that lists three or more harness mechanisms inline
# has copied process/delegate's table and will drift from it.
HARNESS_RE = re.compile(r"(\bsubagent\b|invoke_subagent|spawn_agent|`Agent`|use_subagent|@agent)", re.I)
for s in sorted(skills.values(), key=lambda x: x["rel"]):
    if s["name"] == "delegate":
        continue
    if len(set(HARNESS_RE.findall(s["body"]))) >= 3:
        lint.append(f"lint: {s['name']}: repeats the harness table; point to process/delegate")

# --- 7b. agent-docs audit (only with --audit) ----------------------------
# Every phase ends on a completion criterion, and a pointer names the condition that
# opens it. Both are judgement calls, but their absence is visible: a phase with no
# verifiable end, or a read instruction with no "when".
CRITERION_RE = re.compile(
    r"(done when|completion criterion|complete when|must show|pass bar|pass when|"
    r"stop if|fail if|exit code|expect|verify|assert|green|0 fail)", re.I)
POINTER_RE = re.compile(r"(~/\.agents/skills/[a-z0-9-]+/(?:SKILL\.md|references/)|\(references/[^)]+\)|`[a-z-]+/SKILL\.md`)")
WHEN_RE = re.compile(r"(\bwhen\b|\bbefore\b|\bafter\b|\bif\b|\bfor\b|\buse\b|read)", re.I)
# A line that already tells the agent to act carries its condition in the verb:
# "Run all prose through unslop", "Classify candidates using X". A bare link, or a
# label followed by a link, states neither, so the agent has no trigger to open it.
VERB_RE = re.compile(r"\b(run|read|open|use|classify|present|build|verify|apply|follow|check|write|cite|study|keep|route|split|send|dispatch|load)\b", re.I)

def phases_of(body: str) -> list[tuple[str, str]]:
    out, cur = [], None
    for line in body.splitlines():
        h = re.match(r"^#{2,3}\s+(.+)$", line)
        if h:
            if cur is not None:
                out.append(cur)
            cur = (h.group(1).strip(), "")
            continue
        if cur is not None:
            cur = (cur[0], cur[1] + line + "\n")
    if cur is not None:
        out.append(cur)
    return out

audit_rows = []
for s in sorted(skills.values(), key=lambda x: x["rel"]):
    body = s["body"]
    ph = phases_of(body)
    stepped = [x for x in ph if re.match(r"(\d|phase|step|stage|pass \d)", x[0], re.I)]
    missing = [x[0] for x in stepped if not CRITERION_RE.search(x[1])]
    ptrs = [ln for ln in body.splitlines() if POINTER_RE.search(ln) and not ln.lstrip().startswith("|")]
    weak = [ln for ln in ptrs if not WHEN_RE.search(ln) and not VERB_RE.search(ln)]
    if stepped or ptrs:
        audit_rows.append((s["name"], len(stepped), len(missing), len(ptrs), len(weak), missing[:2]))

if audit:
    print(f"\naudit: {len(audit_rows)} skills with phases or pointers")
    print(f"{'skill':26}{'fases':>6}{'sem criterio':>14}{'ponteiros':>11}{'sem quando':>12}")
    for name, n, miss, np_, weak, sample in sorted(audit_rows, key=lambda r: (-r[2], -r[4])):
        flag = "" if (miss == 0 and weak == 0) else ("  <-- " + ", ".join(f"{s[:34]}" for s in sample))
        print(f"{name:26}{n:6}{miss:14}{np_:11}{weak:12}{flag}")
    total_miss = sum(r[2] for r in audit_rows)
    total_weak = sum(r[4] for r in audit_rows)
    print(f"totals: {total_miss} phase(s) without a completion criterion, {total_weak} pointer(s) without a condition")

# --- 7d. Codex invocation policy -----------------------------------------
# Codex decides implicit invocation from `agents/openai.yaml`, not from our
# frontmatter. A manual skill without the policy line is auto-invocable there, which is
# the one place the farm's intent and the harness disagree.
codex_bad = []
for s in sorted(skills.values(), key=lambda x: x["rel"]):
    yaml_path = os.path.join(os.path.dirname(s["path"]), "agents", "openai.yaml")
    has = os.path.exists(yaml_path)
    disabled = False
    if has:
        body_yaml = open(yaml_path, encoding="utf-8").read()
        disabled = bool(re.search(r"allow_implicit_invocation:\s*false", body_yaml))
    if s["manual"] and not disabled:
        codex_bad.append(f"{s['name']} (manual here, auto in Codex)")
    elif not s["manual"] and has and disabled:
        codex_bad.append(f"{s['name']} (auto here, manual in Codex)")
problems += [f"codex policy: {line}" for line in codex_bad]

# --- 8. mirror parity ----------------------------------------------------
mirrors = {
    "claude": os.path.join(home, ".claude", "skills"),
    "codex": os.path.join(home, ".codex", "skills"),
    "kiro": os.path.join(home, ".kiro", "skills"),
    "gemini": os.path.join(home, ".gemini", "config", "skills"),
    "opencode": os.path.join(home, ".config", "opencode", "skills"),
}
mirror_report: list[str] = []
farm_broken = sorted(e for e, ok in farm_entries.items() if not ok)
if not os.path.isdir(farm):
    problems.append(f"farm: missing directory {farm}")
elif farm_broken:
    problems.append(f"farm: {len(farm_broken)} broken symlink(s) in {farm}: {', '.join(farm_broken[:5])}"
                    + (f" (+{len(farm_broken) - 5} more)" if len(farm_broken) > 5 else ""))

for label, mdir in mirrors.items():
    if not os.path.isdir(mdir):
        mirror_report.append(f"{label}: skipped (no {mdir})")
        continue
    all_entries = sorted(os.listdir(mdir))
    entries = [e for e in all_entries if os.path.islink(os.path.join(mdir, e))]
    unmanaged = sorted(set(all_entries) - set(entries))
    broken = [e for e in entries if not os.path.exists(os.path.join(mdir, e))]
    # A real directory of the same name satisfies the mirror: graphify installs itself
    # into each harness, and that copy is not a link into the farm.
    missing = sorted(farm_skills - set(entries) - set(unmanaged))
    # A mirror may carry a skill of its own that the farm does not have: graphify is
    # linked into the gemini farm from the Pi skill directory on purpose.
    extra = sorted(set(entries) - farm_skills)
    bits = [f"{len(entries)} link(s)"]
    if unmanaged:
        bits.append(f"{len(unmanaged)} non-link entr{'y' if len(unmanaged) == 1 else 'ies'} ({', '.join(unmanaged[:3])})")
    if broken:
        bits.append(f"{len(broken)} broken")
        problems.append(f"mirror:{label}: {len(broken)} broken symlink(s): {', '.join(broken[:5])}"
                        + (f" (+{len(broken) - 5} more)" if len(broken) > 5 else ""))
    if missing:
        bits.append(f"missing {len(missing)}")
        problems.append(f"mirror:{label}: missing {len(missing)} farm link(s): {', '.join(missing[:5])}"
                        + (f" (+{len(missing) - 5} more)" if len(missing) > 5 else ""))
    if extra:
        bits.append(f"extra {len(extra)}")
        problems.append(f"mirror:{label}: extra {len(extra)} link(s) not in farm: {', '.join(extra[:5])}"
                        + (f" (+{len(extra) - 5} more)" if len(extra) > 5 else ""))
    mirror_report.append(f"{label}: {', '.join(bits)}")

# Real directories can live in the farm: instabox* are another project's skills, tracked
# in dotfiles rather than linked from this repo. Anything else that is not a link is drift.
FARM_REAL_DIRS = ("instabox",)
if farm_links:
    no_link = sorted(e for e in set(farm_entries) - farm_links
                     if not e.startswith(FARM_REAL_DIRS))
    if no_link:
        problems.append(f"farm: {len(no_link)} non-link entr{'y' if len(no_link) == 1 else 'ies'} in {farm}: {', '.join(no_link[:5])}")

# --- report --------------------------------------------------------------
edge_count = sum(len(v) for v in edges.values())
deprived = sorted(s["name"] for s in leaves if not incoming.get(s["name"]))

if not quiet:
    manual_roots = len(roots) - len(auto_roots)
    print(f"skills   {len(skills)}  roots {len(roots)} (auto {len(auto_roots)} / manual {manual_roots})  leaves {len(leaves)}")
    print(f"edges    {edge_count}  leaves with no incoming {len(deprived)}/{len(leaves)}")
    print(f"auto index  {index_chars} chars (cap {MAX_INDEX}, {MAX_INDEX - index_chars} left)")
    print(f"mirrors  {len(mirror_report)} checked")
    for line in mirror_report:
        print(f"  {line}")
    print(f"lint     {len(lint)} warning(s)")
    if hygiene_debt:
        print(f"hygiene  {len(hygiene_debt)} absorbed skill(s) carry inherited dashes or banned words: " + "; ".join(hygiene_debt))
    if ref_debt:
        print(f"refs     {len(ref_debt)} reference file(s) carry the same violations: " + "; ".join(ref_debt[:6]) + (" ..." if len(ref_debt) > 6 else ""))
    if accepted_bodies:
        print(f"bodies   {len(accepted_bodies)} accepted over {BODY_WARN} chars: " + "; ".join(accepted_bodies))

if not quiet and deprived:
    print(f"orphan leaves  {', '.join(deprived)}")

if lint and not quiet:
    print()
    for line in lint:
        print(line)

failures = list(problems)
if strict:
    failures += lint

if failures:
    if quiet:
        for line in failures:
            print(line)
    else:
        print(f"\n{len(failures)} problem(s):")
        for line in failures:
            print(f"  {line}")
    sys.exit(1)
if not quiet:
    print("ok")
PY
