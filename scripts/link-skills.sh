#!/usr/bin/env bash
# Reconcile ~/.agents/skills with this repo: one symlink per skill directory.
#
# personal/*    -> linked (first-party skills)
# third-party/* -> linked only if the skill is pinned in skills.lock.yaml
#
# Dangling links that point into this repo are removed, so a deleted skill
# does not keep loading. Links pointing anywhere else are left alone.
#
# Usage: scripts/link-skills.sh [--dry-run]
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
farm="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
dry=0
[ "${1:-}" = "--dry-run" ] && dry=1

mkdir -p "$farm"

pinned=""
if [ -f "$repo/skills.lock.yaml" ]; then
  # every 4-space-indented "name:" key under a source block
  pinned="$(grep -E '^    [A-Za-z0-9_.-]+:$' "$repo/skills.lock.yaml" | sed 's/^ *//; s/:$//')"
fi

# Every SKILL.md under personal/ or third-party/ is a candidate, and a skill's name
# is the directory holding it. Nested trees are covered by the find: a vendored
# multi-skill repo keeps upstream's discipline/phase/skill layout so that the
# relative references inside its skills ("../../../references/...") still resolve.
# That is why `wanted` carries the path, not just the name.
wanted=""
while IFS= read -r skill_md; do
  rel="$(dirname "${skill_md#"$repo"/}")"
  name="$(basename "$rel")"
  case "$rel" in
    third-party/*) grep -qx "$name" <<<"$pinned" || continue ;;
  esac
  wanted+="$name"$'\t'"$rel"$'\n'
done < <(find "$repo/personal" "$repo/third-party" -name SKILL.md -print | sort)

linked=0 removed=0
while IFS=$'\t' read -r name rel; do
  [ -n "$name" ] || continue
  target="$repo/$rel"
  link="$farm/$name"
  if [ -L "$link" ] && [ "$(readlink -f "$link")" = "$(readlink -f "$target")" ]; then
    continue
  fi
  if [ $dry -eq 1 ]; then echo "would link   $name"; else ln -sfn "$target" "$link"; fi
  linked=$((linked + 1))
done <<<"$wanted"

for link in "$farm"/*; do
  [ -L "$link" ] || continue
  dest="$(readlink "$link")"
  case "$dest" in "$repo"/*) ;; *) continue ;; esac
  [ -e "$link" ] && continue
  if [ $dry -eq 1 ]; then echo "would remove $link (dangling)"; else rm -f "$link"; fi
  removed=$((removed + 1))
done

total=$(find "$farm" -maxdepth 1 -name '*' -type l | wc -l)
[ $dry -eq 1 ] && echo "dry run: $linked to link, $removed dangling" || echo "linked $linked, removed $removed dangling; $total links in $farm"
