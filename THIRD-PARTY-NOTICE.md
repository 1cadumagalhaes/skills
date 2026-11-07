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
`disable-model-invocation: true`, so all 104 are invoke-only. `protocol/` (8
skills) is vendored because 319 references point into it, but it is **not linked**:
its skill-contract rules are ours already, in `~/.pi/agent/AGENTS.md`.
`seo-geo/implement/` and `seo-geo/tune/` (8 skills) are vendored but not linked —
they duplicate the AgriciDaniel port.

**Data caveat.** 14-16 of every 16 skills expect connected tools or user-supplied
exports (`CONNECTORS.md`, `scripts/connectors/*.py` — ledger, youtube, resend,
tavily, firecrawl, gdelt, experiment, pageviews). Without a feed they degrade to a
checklist that asks for the export; nothing here requires a key to *run*, but most
of them are weaker without one.
