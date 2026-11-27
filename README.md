# skills

Personal and curated agent skills for this machine. One tree here, mounted into
`~/.agents/skills` and mirrored into the Claude, Codex, Kiro and Gemini skill
farms.

Inventory, tiers and edges per skill: `SKILL-MAP.md` (generated, never edited by
hand).

## Clusters

| cluster | purpose |
|---|---|
| `base/` | repo defaults: reading order, scope, verification bar, commits |
| `engineering/` | backend, data, infra, security, python, debugging, audits |
| `frontend/` | component build, browser verification, dashboards, taste, platform docs |
| `motion/` | animation build, sequencing, review, performance |
| `process/` | planning, delegation, writing for agents, PRs, prototypes, retros |

## Layout

```
base/ engineering/ frontend/ motion/ process/   one SKILL.md per <cluster>/<domain>/
parked/         off-farm packs, mounted on demand
licenses/       verbatim upstream license texts
evals/          prompt batteries, one per evaluated root
scripts/        link, check, map, usage, eval
ATTRIBUTION.md  upstream sources, commits, licenses, new homes
SKILL-MAP.md    generated index
skills.lock.yaml  external mounts and parked pins
```

## Commands

Reconcile `~/.agents/skills` and every harness mirror with this tree:

```sh
bash scripts/link.sh              # apply
bash scripts/link.sh --dry-run    # print the plan
bash scripts/link.sh --check      # report drift only, exit 1 on any drift
bash scripts/link.sh --without motion-build   # keep one skill off the farm (repeatable)
```

Parked packs:

```sh
bash scripts/link.sh --list-packs          # packs and their SKILL.md counts
bash scripts/link.sh --pack seo            # mount a pack (repeatable, or --pack all)
bash scripts/link.sh                       # plain run drops the mounted packs again
```

Validate the tree:

```sh
bash scripts/check.sh             # frontmatter, tiers, edges, budget, mirror parity
bash scripts/check.sh --quiet     # summary only
bash scripts/check.sh --strict    # lint warnings fail too
```

Other tools:

```sh
bash scripts/map.sh               # regenerate SKILL-MAP.md
bash scripts/map.sh --find motion # search name and description
bash scripts/usage.sh             # skill usage and cost from Pi sessions
bash scripts/usage.sh --write     # write USAGE.md instead of stdout
bash scripts/usage.sh --dir <dir> # scan another session directory
bash scripts/eval.sh --list       # evaluation ports
bash scripts/eval.sh <port>       # print the run command for a port
bash scripts/eval.sh <port> --run # one arm, with the skill, in its fixture
bash scripts/eval.sh <port> --run --arms  # ablation, with and without the skill
```

## Naming

- Directory is `<cluster>/<domain>/`. The skill name lives in frontmatter `name`,
  and that name is what `scripts/link.sh` links, never the directory basename.
- `frontend/` and `motion/` carry the cluster prefix: `frontend/build` is
  `frontend-build`, `motion/build` is `motion-build`. `base/`, `engineering/` and
  `process/` use the bare domain: `engineering/backend` is `backend`. The
  directory never repeats the domain.
- `tier: root` is an entry point and may be model-invocable. `tier: leaf` is
  manual only and always carries `disable-model-invocation: true`.
- Budget: at most 14 model-invocable roots, auto index at most 2800 characters.

## Attribution

`ATTRIBUTION.md` is the attribution of record: every upstream source with repo,
commit, license, copyright holder and the skills it became. Absorbed skills also
carry `derived_from` in frontmatter. Verbatim license texts are in `licenses/`,
and corpora that ship their own license keep it in place.

## Parked packs

`parked/` holds packs kept off the farm (`marketing/`, `seo/`, `gamedev/`,
`media-misc/`, `ml-legacy/`, `web/`). Nothing there is linked by default, and
`scripts/check.sh` and `scripts/map.sh` ignore it. Mount one with
`bash scripts/link.sh --pack <name>`, unmount by running `bash scripts/link.sh`
with no packs. Pins live under `parked:` in `skills.lock.yaml`.
