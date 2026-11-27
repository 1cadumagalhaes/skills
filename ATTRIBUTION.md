# Attribution

Upstream sources absorbed into this repo: repo, commit read, license, copyright
holder, and where the material now lives. This file is the attribution of record.

Verbatim license texts live in `licenses/`, and where a copy is not stored there
the upstream LICENSE at the pinned commit applies. Every absorbed skill carries
`derived_from` in its frontmatter (`repo`, `commit`, `license`).

Classes of absorption:

- **rewritten**: upstream material rewritten as our own skill body, provenance kept.
- **attributed corpus**: upstream files kept verbatim and attributed.
- **adapted**: upstream structure or text kept with named local changes.

## mattpocock/skills

MIT, Copyright (c) 2026 Matt Pocock
https://github.com/mattpocock/skills, commit `abeeaf95660b`

- rewritten: `engineering/module-design`, `engineering/domain-modeling`, `engineering/code-review`, `process/prototype`, `process/research`, `process/tdd`, `process/grilling`, `process/wizard`.
- adapted: `process/agent-docs` (from `writing-for-agents`), `engineering/debug` (from `diagnosing-bugs`).
- merged: `process/retro` (with pstack `correct`), `process/pr` (with pstack `worker.md` PR rules and the stacked-PR workflow).

`process/pr` keeps the summary visual guidance credited upstream to Dex Horthy's
`show-me` in `humanlayer/humanlayer`.

## emilkowalski/skills

MIT, Copyright (c) 2026 Emil Kowalski
https://github.com/emilkowalski/skills, commit `c8a79627b59d72d764d6ab6f2c87c09a48169833`

- rewritten: `motion/build`, `motion/sequence`, `motion/review`, `motion/improve`, `motion/remove`, `motion/find`, `motion/performance`, `motion/vocabulary`, `frontend/stress`, `frontend/choose-library`.
- dissolved: `emil-design-eng`; the six patterns no sister skill covers are kept in `motion/build/RECIPES.md`.

## backnotprop/pstack

MIT, Copyright (c) 2026 Lauren Tan (mirror of `cursor/plugins/pstack`)
https://github.com/backnotprop/pstack, commit `c3464c11c60b`

- adapted: `process/unslop` (PT-BR filler rules added), `engineering/blast-radius`, `engineering/benchmark-check`, `process/delegate`, and `~/.agents/worker.md` (from pstack's poteto-mode worker contract).
- merged: `process/retro` (pstack `correct` levels into mattpocock's `retro`).

## GoogleChrome/modern-web-guidance

Apache-2.0
https://github.com/GoogleChrome/modern-web-guidance, commit `4dd968349e54ca45a05dd5c818fb035c9054b022`

- attributed corpus: `frontend/platform-docs`, the guide set (18 categories) kept verbatim; its `SKILL.md` is rewritten locally and `frontend/platform-docs/scripts/mwg-search.mjs` is ours. Upstream `LICENSE` and `NOTICE.md` stay in place at `frontend/platform-docs/LICENSE` and `frontend/platform-docs/NOTICE.md`; copies at `licenses/Apache-2.0-GoogleChrome.txt` and `licenses/Apache-2.0-GoogleChrome-NOTICE.md`. Upstream is stewarded by the Chrome, Edge, Firefox and MDN teams, and portions derive from MDN Web Docs (Mozilla Contributors), W3C, WHATWG and IETF specifications.
- parked: `parked/web/chrome-extensions` (mount with `bash scripts/link.sh --pack web`).

## perfect7613/dsa-system-design-optimizer

MIT, Copyright (c) 2026 Amey Muke
https://github.com/perfect7613/dsa-system-design-optimizer, commit `555cb1a6b8befff83400f90845184b9186aef219`

- rewritten: `engineering/system-design`. License text: `licenses/MIT-Amey-Muke.txt`, `engineering/system-design/LICENSE`.

## abdiraimov-otabek/dashboard-design-skill

MIT, Copyright (c) 2026 Otabek Abdiraimov
https://github.com/abdiraimov-otabek/dashboard-design-skill, commit `b813324aea08dc19a82d2bd9ea73824dfdd0e844`

- rewritten: `frontend/dashboard-charts`. License text: `licenses/MIT-Otabek-Abdiraimov.txt`, `frontend/dashboard-charts/LICENSE`.

## sananthanarayan/skilldrop

MIT, Copyright (c) 2026 S. Ananthanarayan
https://github.com/sananthanarayan/skilldrop, commit `ae58fb288fef59063d6c8696777b034a88219f59`

- attributed corpus: `frontend/dashboard/references/dashboard-spec/`, kept verbatim (reference, templates, examples, manifest). License text: `licenses/MIT-S-Ananthanarayan.txt`.

## Leonxlnx/taste-skill

No license file upstream.
https://github.com/Leonxlnx/taste-skill, commit `844f3cf223d2`

- rewritten: `frontend/taste`. No license was found upstream, so this copy is
  local only: do not redistribute or publish it until the owner grants terms.

## heliocosta-dev/revenue-centric-design

Custom terms, Copyright (c) 2026 the curators of that repository.
https://github.com/heliocosta-dev/revenue-centric-design, commit `1942760c2242`

- rewritten, distilled and translated: `frontend/revenue-design`. Terms at `licenses/Revenue-Centric-Design-terms.txt` and `frontend/revenue-design/LICENSE`; they credit the underlying ideas to Richard (`@richardrx`), used with permission.

## gabrielgreco1/skills

No license file upstream, used with permission.
https://github.com/gabrielgreco1/skills, commit `a3c2be7a844ffe8b0aa39c20f82dcbe776692757`

- rewritten: `engineering/webscraping`.
- parked: `parked/media-misc/aula-interativa`, `parked/media-misc/motion-designer`, `parked/media-misc/diretor-de-edicao`, `parked/media-misc/ui-humanizer` (mount with `bash scripts/link.sh --pack media-misc`).

The upstream repository carries no license file. Cadu obtained the owner's
explicit permission on 2026-11-07 for these skills. Re-confirm that permission
before sharing or publishing any of them.

## davila7/claude-code-templates (senior-frontend)

MIT, Copyright (c) 2026 claude-code-templates
https://github.com/davila7/claude-code-templates, commit `30f72e1815455e0df7618e9edf3e9877fa6c24e3`

- attributed corpus: `frontend/verify/scripts/check_ui.mjs` and `frontend/verify/scripts/page-audit.mjs`, copied unmodified; `frontend/build/references/states.md` and `frontend/rules/references/platform-polish.md` (adapted).
- The license text, the credit line and the downstream notices this skill carries (Vercel Labs `web-interface-guidelines` and `agent-skills`, Addy Osmani `web-quality-skills`) stay at `frontend/verify/references/NOTICE.md`, referenced from `frontend/verify/SKILL.md`.

## Parked packs

`parked/` holds off-farm packs, and their attribution stays with them: the
upstream `LICENSE`/`NOTICE` files are kept inside the pack.

- `parked/marketing/aaron-marketing-skills/LICENSE`, `parked/marketing/startup-pressure-test/LICENSE`
- `parked/gamedev/awesome-gamedev-agent-skills/LICENSE` and `NOTICE`
- one `LICENSE` per skill under `parked/seo/`, e.g. `parked/seo/seo-agentic/LICENSE`

Upstream pins live under `parked:` in `skills.lock.yaml`. Nothing under `parked/`
is linked unless a pack is mounted explicitly.
