# Third-party notices

## gabrielgreco1/skills — used with permission

Four skills under `third-party/` come from https://github.com/gabrielgreco1/skills
(pinned in `skills.lock.yaml`): `aula-interativa`, `motion-designer`,
`diretor-de-edicao`, `ui-humanizer`.

The upstream repository carries **no license file**. Cadu obtained the owner's
explicit permission on 2026-11-07 to copy these skills into this repository.
If the set is ever shared or published, re-confirm that permission first.

## Kappaemme-git/codex-startup-pressure-test-skill — MIT

`startup-pressure-test`, from
https://github.com/Kappaemme-git/codex-startup-pressure-test-skill (MIT).
Pinned in `skills.lock.yaml`. Local change: the Codex-only
`agents/openai.yaml` was dropped and `disable-model-invocation: true` added, so
the skill loads on request only.

## zubair-trabzada/geo-seo-claude — MIT

Eight of the repository's fifteen skills, from
https://github.com/zubair-trabzada/geo-seo-claude (MIT), pinned in
`skills.lock.yaml`: `geo-audit`, `geo-citability`, `geo-technical`, `geo-schema`,
`geo-crawlers`, `geo-llmstxt`, `geo-content`, `geo-platform-optimizer`.

Not vendored: the author's agency-sales half (`geo-prospect`, `geo-proposal`,
`geo-report-pdf`, `geo-compare`, `geo-brand-mentions`, `geo-update`,
`crm_dashboard.py`, the Flask webapp). Local changes: `disable-model-invocation:
true` on every skill; `scripts/fetch_page.py` copied into `geo-schema/` because
that skill calls it; `scripts/` requirements are **not** installed — the skills
work as instructions, and any script step needs `beautifulsoup4 lxml requests`
(plus `playwright` for JS-rendered pages).

## AgriciDaniel/claude-seo — MIT

The 26 core skills under `skills/`, plus the toolchain they call, from
https://github.com/AgriciDaniel/claude-seo (MIT), pinned in `skills.lock.yaml`.
This is the classic-SEO half of the farm: technical audits, on-page, sitemaps,
schema, hreflang, semantic clustering, drift, programmatic, images, local,
e-commerce, SXO, Search Console/GA plumbing, backlinks.

**Local changes.** The upstream repo ships as a Claude *plugin*, so every
`${CLAUDE_PLUGIN_ROOT}` reference was rewritten to this repo's absolute path
(118 launcher calls, 6 other path references across 32 files). `seo` (the
orchestrator) is the only one that auto-loads; the other 25 carry
`disable-model-invocation: true`. Each skill got a `LICENSE` copy.

The runtime — `scripts/`, `schema/`, `data/` — lives unflattened in
`third-party/claude-seo-runtime/`, because the skills call it by absolute path.
`bin/claude-seo` is ours: it forces `CLAUDE_SEO_DATA_DIR` outside the git tree.
Without that, upstream's launcher treats this directory as a *manual* install and
writes ~1.5 GB of Playwright browsers into the repo (that is how the data-dir
override was found).

**Machine-level state, not in the repo:** `~/.local/share/claude-seo-data`
(~1.4 GB: managed venv + Chromium + runtime-state.json), created by
`bin/claude-seo setup`. Re-run `setup` after a `pi update`-style refresh of this
directory, and `doctor` to check it. Rendered-page audits need that Chromium.

**Not vendored:** `extensions/` (nine provider add-ons — ahrefs, dataforseo,
bing-webmaster, matomo, firecrawl, seranking, profound, unlighthouse, banana —
each needs its own API key), `agents/` (18 Claude sub-agent files; only
`agents/seo-image-gen.md` is referenced by a skill), `hooks/` (Claude Code
hooks, which pi does not run), `docs/`, `screenshots/`, `assets/`, `tests/`.

## aaron-he-zhu/aaron-marketing-skills — Apache-2.0

104 of the repository's 120 skills, from
https://github.com/aaron-he-zhu/aaron-marketing-skills (Apache-2.0, see
`third-party/aaron-marketing-skills/LICENSE`), pinned in `skills.lock.yaml`.
Disciplines: `ad`, `email`, `influencer`, `launch`, `narrative`, `social`, plus
the survey/evaluate half of `seo-geo`.

**Structure is upstream's, not flattened.** This pack is a tree —
`discipline/phase/skill/SKILL.md` — and its skills cross-reference each other and
the shared `references/`, `CONNECTORS.md` and `scripts/connectors/` with relative
paths (`../../../references/measurement-protocol.md`). Flattening would have
required rewriting ~2500 of them, so the tree is vendored intact at
`third-party/aaron-marketing-skills/` and `scripts/link-skills.sh` now finds
`SKILL.md` anywhere under `personal/` or `third-party/` instead of only one level
deep. Verified after linking: 1102 relative references across the 104 skills
resolve, 0 missing.

**Local changes.** `${CLAUDE_PLUGIN_ROOT}` (including the
`${CLAUDE_PLUGIN_ROOT:-$(git rev-parse --show-toplevel)}` idiom) rewritten to this
repo's absolute vendored path across 55 files — there is no plugin root and no git
top level to fall back on from a skills farm. Every linked skill carries
`disable-model-invocation: true`, so all 104 are invoke-only. All 120 skills are linked, including `protocol/` (8, the
skill-contract and registry rules that 319 references point into) and
`seo-geo/implement/` + `seo-geo/tune/` (8, which overlap the AgriciDaniel port —
kept because they are the *checker* half of the same process and cheap to hold).

**Data caveat.** 14-16 of every 16 skills expect connected tools or user-supplied
exports (`CONNECTORS.md`, `scripts/connectors/*.py` — ledger, youtube, resend,
tavily, firecrawl, gdelt, experiment, pageviews). Without a feed they degrade to a
checklist that asks for the export; nothing here requires a key to *run*, but most
of them are weaker without one.

## gamedev-skills/awesome-gamedev-agent-skills — Apache-2.0

45 of the repository's 78 skills, from
https://github.com/gamedev-skills/awesome-gamedev-agent-skills (Apache-2.0; the
upstream `NOTICE` file is vendored alongside `LICENSE`), pinned in
`skills.lock.yaml`. Linked: `router`, the 15 engine-neutral `disciplines/`, the 9
`genres/`, the 16 `godot/` skills, and 4 `workflows/` (game-jam, prototype-fast,
itch-publish, steam-publish).

**Structure is upstream's** (`skills/<group>/<name>/SKILL.md`, each skill owning
its own `references/`), so nothing needed rewriting — verified: the only
`../`-relative reference in the linked set is `../content` inside
`workflows/steam-publish`, which points at a *game project's* content folder, not
at this pack. `docs/`, `scripts/` and `templates/` are vendored because skills
cite them.

`router` is the one skill here that auto-loads: it fingerprints the project,
picks one engine and names the minimal skill set, so "make a game" reaches it
without a slash command. It costs ~180 characters of index; the other 44 are
`disable-model-invocation: true`.

**Vendored but not linked (33):** `unity/` 8, `unreal/` 6, `web-engines/` 6,
`other-engines/` 12, `ebitengine/` 1 — engine-specific packs for engines not
chosen yet. Enabling one is: add its pin to `skills.lock.yaml`, run
`scripts/link-skills.sh`.
