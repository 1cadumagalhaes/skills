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
