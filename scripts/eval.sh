#!/usr/bin/env bash
# Run one evaluation port (skill battery) in a fixture workspace.
#
# Layout: evals/<port>/prompt-<n>.md (input), expected-<n>.md (grading rubric),
# fixture/ (the workspace the model runs in). prompt-1 is the golden case and its
# expected-1.md is the reference for the with-arm output; prompts 2 and 3 are edge
# and chain cases, graded by reading expected-<n>.md. results/ holds the outputs.
#
# Single arm by default: one run per prompt, with the skill mounted (the farm as
# reconciled by scripts/link.sh), written to results/prompt-<n>-with.txt. Nothing
# is unmounted, so a default run never mutates the skill farm.
#
# --arms restores the two-arm ablation:
#   with     the farm as reconciled by scripts/link.sh (skill mounted)
#   without  scripts/link.sh --without <port> (skill absent from farm and mirrors)
# The farm is restored on exit, including on failure.
#
# Workspace: every nested pi runs from a fixture workspace, never from this repo.
#   --cwd <dir>            use that directory as-is
#   evals/fixtures/<port>/ copied to a fresh mktemp -d, removed on exit
#   neither                exit 2: a port needs a fixture or an explicit --cwd
# Why: with the cwd here the model reads evals/<port>/expected-*.md and the skill
# directory even when the skill is unmounted, which voids the run.
#
# Every nested pi call is `( cd "$work" && pi ... )` with
# `--no-session -p "$(cat <prompt>)" --mode text`, and gets </dev/null: without it
# the child inherits the prompt loop's here-string and eats the remaining prompts,
# so the loop exits after prompt-1.
#
# Without --run every command is printed instead of executed (no model quota spent).
#
# Usage: scripts/eval.sh <port> [--run] [--arms] [--cwd <dir>] [--model <provider/id>]
#        scripts/eval.sh --list
set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"
evals="$repo/evals"
linker="$repo/scripts/link.sh"

run=0
arms=0
list=0
port=""
cwd_opt=""
model=""

while [ $# -gt 0 ]; do
  case "$1" in
    --run) run=1; shift ;;
    --arms) arms=1; shift ;;
    --list) list=1; shift ;;
    --model)
      [ $# -ge 2 ] || { echo "eval.sh: --model needs a value" >&2; exit 1; }
      model="$2"; shift 2 ;;
    --cwd)
      [ $# -ge 2 ] || { echo "eval.sh: --cwd needs a value" >&2; exit 1; }
      cwd_opt="$2"; shift 2 ;;
    -h|--help) awk 'NR>1 && /^set -euo pipefail/{exit} NR>1{sub(/^# ?/,""); print}' "$0"; exit 0 ;;
    -*) echo "eval.sh: unknown flag '$1'" >&2; exit 1 ;;
    *)
      [ -z "$port" ] || { echo "eval.sh: one port at a time (got '$port' and '$1')" >&2; exit 1; }
      port="$1"; shift
      ;;
  esac
done

shopt -s nullglob

prompts_of() {
  # Sorted prompt files for a port directory; empty when the port has none.
  local dir="$1" files=()
  files=( "$dir"/prompt-*.md )
  [ ${#files[@]} -gt 0 ] || return 0
  printf '%s\n' "${files[@]}" | sort -V
}

if [ "$list" -eq 1 ]; then
  found=0
  for dir in "$evals"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    prompts="$(prompts_of "$dir")"
    [ -n "$prompts" ] || continue
    found=$((found + 1))
    count=$(printf '%s\n' "$prompts" | wc -l | tr -d ' ')
    goldens=0
    [ -f "$dir/expected-1.md" ] && goldens=1
    printf '%s: %s prompt(s), golden: %s\n' "$name" "$count" "$([ "$goldens" -eq 1 ] && echo 'expected-1.md (processed diff)' || echo 'none')"
  done
  if [ "$found" -eq 0 ]; then
    echo "no ports with prompts in evals/"
  fi
  exit 0
fi

[ -n "$port" ] || { echo "usage: scripts/eval.sh <port> [--run] [--arms] [--cwd <dir>] | --list" >&2; exit 1; }

dir="$evals/$port"
model_flag=""
if [ -n "$model" ]; then
  model_flag="--model $model"
fi
prompts="$(prompts_of "$dir")"
if [ -z "$prompts" ]; then
  echo "eval.sh: no prompts at evals/$port/prompt-*.md" >&2
  exit 2
fi

# Workspace: an explicit --cwd, or a throwaway copy of evals/fixtures/<port>/.
# Never this repo (see the header): the model would read expected-*.md and the
# skill directory even in the without-arm.
tmp_work=""
work=""
cwd_why=""
if [ -n "$cwd_opt" ]; then
  if [ ! -d "$cwd_opt" ]; then
    echo "eval.sh: --cwd '$cwd_opt' is not a directory" >&2
    exit 2
  fi
  work="$(cd "$cwd_opt" && pwd)"
  cwd_why="explicit --cwd"
elif [ -d "$repo/evals/fixtures/$port" ]; then
  tmp_work="$(mktemp -d "${TMPDIR:-/tmp}/skills-eval-$port.XXXXXX")"
  cp -a "$repo/evals/fixtures/$port/." "$tmp_work/"
  work="$tmp_work"
  cwd_why="copy of evals/fixtures/$port, temporary (removed on exit)"
else
  echo "eval.sh: evals/$port has no fixture and no --cwd was given" >&2
  echo "eval.sh: a port needs evals/fixtures/$port/ (copied to a temp workspace) or an explicit --cwd <dir>" >&2
  exit 2
fi

need_restore=0
on_exit() {
  status=$?
  if [ "$need_restore" -eq 1 ]; then
    "$linker" >/dev/null 2>&1 || echo "eval.sh: farm restore failed; run scripts/link.sh" >&2
  fi
  if [ -n "$tmp_work" ]; then
    rm -rf "$tmp_work"
  fi
  exit "$status"
}
trap on_exit EXIT INT TERM

if [ "$run" -eq 1 ]; then
  command -v pi >/dev/null 2>&1 || { echo "eval.sh: pi is not on PATH" >&2; exit 1; }
  if [ ! -x "$linker" ]; then
    echo "eval.sh: $linker is missing or not executable; the skill cannot be mounted" >&2
    exit 3
  fi
  if [ "$arms" -eq 1 ] && ! grep -q -- '--without' "$linker"; then
    echo "eval.sh: scripts/link.sh does not support --without; the without-arm cannot run" >&2
    exit 3
  fi
fi

# One nested pi per prompt, from the fixture workspace. </dev/null is load-bearing
# (see the header); $model_flag is intentionally unquoted so "--model x" splits.
run_pi() {  # $1 prompt file, $2 output file (absolute)
  ( cd "$work" && pi --no-session </dev/null -p "$(cat "$1")" --mode text $model_flag > "$2" )
}

ran=0
judged=0
diverged=0

if [ "$run" -eq 1 ]; then
  mkdir -p "$dir/results"
  "$linker" >/dev/null   # mount: the farm as reconciled, skill present
  if [ "$arms" -eq 1 ]; then
    need_restore=1
  fi
fi

while read -r prompt; do
  n="$(basename "$prompt" .md)"; n="${n#prompt-}"
  rel_prompt="evals/$port/prompt-$n.md"
  with_out="$dir/results/prompt-$n-with.txt"
  without_out="$dir/results/prompt-$n-without.txt"
  expected="$dir/expected-$n.md"

  echo "# $port / $rel_prompt"
  echo "# cwd: $work  ($cwd_why)"

  if [ "$run" -eq 0 ]; then
    echo "# arm 1: with the skill (default farm)"
    echo "( cd \"$work\" && pi --no-session </dev/null -p \"\$(cat $prompt)\" --mode text $model_flag > $with_out )"
    if [ "$arms" -eq 1 ]; then
      echo "# arm 2: without the skill"
      echo "scripts/link.sh --without $port"
      echo "( cd \"$work\" && pi --no-session </dev/null -p \"\$(cat $prompt)\" --mode text $model_flag > $without_out )"
      echo "scripts/link.sh   # restore the farm"
      echo "# diff the two arms"
      echo "diff -u $without_out $with_out"
    fi
    if [ -f "$expected" ]; then
      echo "# judge against $expected (rubric, not an exact diff)"
    fi
    echo ""
    continue
  fi

  if [ "$arms" -eq 0 ]; then
    run_pi "$prompt" "$with_out"
  else
    run_pi "$prompt" "$with_out"
    "$linker" --without "$port" >/dev/null
    run_pi "$prompt" "$without_out"
    "$linker" >/dev/null
  fi

  ran=$((ran + 1))
  if [ "$arms" -eq 1 ] && diff -q "$with_out" "$without_out" >/dev/null 2>&1; then
    echo "  arms identical (no visible skill effect)"
  elif [ "$arms" -eq 1 ]; then
    diverged=$((diverged + 1))
    echo "  arms differ (see diff -u $without_out $with_out)"
  else
    echo "  wrote $with_out"
  fi
  if [ -f "$expected" ]; then
    judged=$((judged + 1))
    echo "  judge against $expected (rubric)"
  fi
done <<< "$prompts"

if [ "$run" -eq 1 ]; then
  if [ "$arms" -eq 1 ]; then
    mode="two-arm ablation (with and without)"
    extra=", $diverged differ between arms"
  else
    mode="single-arm (skill mounted, nothing unmounted)"
    extra=""
  fi
  echo "$port: $mode; ran $ran prompt(s), $judged to judge$extra; outputs in $dir/results/ (workspace: $work)"
fi
