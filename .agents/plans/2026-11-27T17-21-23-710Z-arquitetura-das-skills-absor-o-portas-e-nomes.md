# Arquitetura das skills: absorção, portas e nomes

Estado: 2026-11-27. 51 ativas, 18 auto / 900 tokens, 241 parked (intocadas).
Substitui os dois planos anteriores. Decisões desta rodada estão na §0.

## 0. Decisões fechadas

1. **Absorver todas as ativas de `third-party/` para `personal/`.** `third-party/` deixa de existir como
   tier ativo; o que sobra é `parked/` (estante) e `personal/` (nosso).
2. **Renomear tudo pela gramática `<domínio>-<trabalho>`** (§2), inclusive as absorvidas.
3. **Manter o conceito delegation/worker**: `delegate` (skill, auto) + `~/.agents/worker.md` (contrato do
   filho). O `policy.md` fica com os 4 não-negociáveis e um ponteiro, para não duplicar.
4. **Cluster não é disciplina, é cadeia que dispara junto**; `engineering ⊃ frontend` declarado no mapa.
5. **Nenhum dispatcher existe**: auto = descrição no prompt; caminho específico = ponteiro no corpo.
6. **Auto é uma lista declarada de portas.** Skill fora da lista é folha, inclusive corpus absorvido.
   Isso substitui o gate "só personal pode ser auto" e substitui também o flag de maturidade.
7. **Frontend não aponta para `system-design`** (zero conteúdo de frontend); aponta para `code-audit`.
8. **`parked/` não é tocada.** `chrome-extensions` vai para parked.

## 1. Clusters e portas

| Cluster | Porta | Auto | Filhas |
|---|---|---|---|
| base | `repo-defaults` | sim | — |
| engineering | `backend` | sim | `module-design`, `domain-modeling`, `system-design`, `code-review`, `tdd` |
| engineering | `data-engineering` | sim | `references/*`, `domain-modeling`, `system-design`, `webscraping` |
| engineering | `infra` | sim | — |
| engineering | `security` | sim | — |
| engineering | `python` | sim | `module-design` (projeto novo), `code-audit` |
| engineering | `code-audit` | sim | `module-design`, `code-review`, `tdd`, `blast-radius`, `grilling`, `chaos-engineering` |
| engineering | `debug` | sim | `benchmark-check` |
| frontend | `frontend-build` | sim | `frontend-design-doc`, `frontend-direction`, `frontend-storybook`, `frontend-taste`, `frontend-platform-docs`, `code-audit` |
| frontend | `frontend-rules` | sim | — |
| frontend | `frontend-verify` | sim | — |
| frontend | `frontend-dashboard` | sim | `frontend-dashboard-charts`, `references/dashboard-spec.md` |
| motion | `motion-build` | não | `motion-sequence`, `motion-review`, `motion-improve`, `motion-remove`, `motion-find`, `motion-performance`, `motion-vocabulary` |
| motion | `frontend-stress` | não | `motion-*` |
| process | `delegate` | sim | `worker.md`, `olorin` |
| process | `pr` | não | `code-review`, `blast-radius` |
| process | `retro` | não | `agent-docs`, `unslop` |
| process | `research` | não | — |
| process | `prototype` | não | `grilling` |
| process | `tdd` | não | `module-design` |
| process | `grilling` | não | `code-review` |
| process | `wizard` | não | — |
| process | `agent-docs` | não | `unslop` |
| process | `unslop` | não | — |
| process | `chaos-engineering` | não | `code-review` |

Auto: **13** (12 anteriores + `delegate`). Índice ≈ 2.330 chars ≈ 580 tokens.
Manual: 34.

## 2. Gramática de nomes

`<domínio>-<trabalho>`, domínio ∈ `backend, data, infra, security, python, frontend, motion, process, repo`.
Trabalho = verbo ou substantivo concreto. **Proibido em nome**: workflow, craft, direction, contract,
spec, expert, sections, optimizer, taste, misc. Nenhum nome pode ser prefixo de outro sem trabalho distinto.

| Atual | Novo | Origem | Cluster |
|---|---|---|---|
| project-baseline | `repo-defaults` | personal | base |
| backend | `backend` | personal | engineering |
| data-engineering | `data-engineering` | personal | engineering |
| infra | `infra` | personal | engineering |
| security | `security` | personal | engineering |
| modern-python | `python` | personal | engineering |
| code-quality | `code-audit` | personal | engineering |
| diagnosing-bugs | `debug` | personal | engineering |
| codebase-design | `module-design` | matt | engineering |
| domain-modeling | `domain-modeling` | matt | engineering |
| dsa-system-design | `system-design` | vendor | engineering |
| code-review | `code-review` | matt | engineering |
| benchmark-checklist | `benchmark-check` | pstack | engineering |
| blast-radius | `blast-radius` | pstack | engineering |
| webscraping-expert | `webscraping` | vendor | engineering (data) |
| frontend-workflow | `frontend-build` | personal | frontend |
| ui-craft | `frontend-rules` | personal | frontend |
| design-direction | `frontend-direction` | personal | frontend |
| design-contract | `frontend-design-doc` | personal | frontend |
| storybook-workflow | `frontend-storybook` | personal | frontend |
| dashboard | `frontend-dashboard` | personal | frontend |
| dashboard-design | `frontend-dashboard-charts` | vendor | frontend |
| dashboard-spec | (dissolve) `frontend-dashboard/references/dashboard-spec.md` | vendor | frontend |
| design-taste-frontend | `frontend-taste` | vendor | frontend |
| modern-web-guidance | `frontend-platform-docs` | GoogleChrome | frontend |
| revenue-centric-design | `frontend-revenue-design` | vendor | frontend |
| diagram-sections | `frontend-diagrams` | personal | frontend |
| animate | `motion-build` | emil | motion |
| choreograph | `motion-sequence` | emil | motion |
| review-animations | `motion-review` | emil | motion |
| improve-animations | `motion-improve` | emil | motion |
| remove-animations | `motion-remove` | emil | motion |
| find-animation-opportunities | `motion-find` | emil | motion |
| animation-performance | `motion-performance` | emil | motion |
| animation-vocabulary | `motion-vocabulary` | emil | motion |
| break-ui | `frontend-stress` | emil | motion |
| pick-ui-library | `frontend-choose-library` | emil | motion |
| emil-design-eng | (dissolve) receitas para `motion-build/RECIPES.md` | emil | motion |
| delegation | `delegate` | pstack | process |
| pr | `pr` | matt+pstack | process |
| retro | `retro` | matt+pstack | process |
| research | `research` | matt | process |
| prototype | `prototype` | matt | process |
| tdd | `tdd` | matt | process |
| grilling | `grilling` | matt | process |
| wizard | `wizard` | matt | process |
| writing-for-agents | `agent-docs` | matt | process |
| unslop | `unslop` | pstack | process |
| chrome-extensions | — | GoogleChrome | **parked** |
| dashboard-spec | — | vendor | dissolvida |
| emil-design-eng | — | emil | dissolvida |

## 3. Absorção: como e com que honestidade

Absorver por cópia não é reescrever. Três classes, e a classe fica registrada:

| Classe | O que significa | Skills |
|---|---|---|
| **reescrita** | texto refeito por nós; vira nosso de fato | `module-design`, `domain-modeling`, `tdd`, `code-review`, `motion-build`, `motion-sequence`, `motion-remove`, `motion-performance`, `frontend-stress` |
| **corpus atribuído** | conteúdo grande que mantemos funcionando, sem reescrever | `frontend-taste`, `frontend-platform-docs`, `frontend-revenue-design`, `system-design` |
| **adaptada** | cópia com ajustes de caminho, harness e filler removido | `motion-review`, `motion-improve`, `motion-find`, `motion-vocabulary`, `frontend-choose-library`, `webscraping`, `prototype`, `research`, `wizard`, `grilling`, `frontend-dashboard-charts` |

Consequências obrigatórias:

1. **Licença.** MIT/Apache exigem manter copyright. `THIRD-PARTY-NOTICE.md` continua versionado e cada
   skill absorvida ganha `derived_from: {repo, commit, license}` no frontmatter. Quem tem `LICENSE` próprio
   mantém o arquivo ao lado do `SKILL.md`.
2. **`update-skills.sh`** perde a base de comparação por caminho; passa a ler `derived_from` e checar drift
   de forma opcional, contra o commit registrado.
3. **Nenhuma absorvida vira porta** sem decisão explícita: as 13 portas são lista fixa no repo.
4. `THIRD-PARTY-NOTICE.md` deixa de descrever "vendorado em third-party/" e passa a descrever "absorvido em
   personal/<x>", com a classe acima.

## 4. Papéis

| Papel | Contrato | Skill |
|---|---|---|
| Orquestração | `delegate` (skill, auto) + 4 não-negociáveis no `policy.md` | sim |
| Execução | `~/.agents/worker.md`, primeira linha do kickoff | não |
| Review | tabela em `code-audit`: diff → `code-review`, design contestado → `grilling`, prova rodando → verifier, quebra → `chaos-engineering` | folhas |
| Estado durável | `olorin` (externo, no lock) | já existe |

`delegate` herda o que hoje está em `personal/delegation` mais o template operacional. O `policy.md` perde
a duplicata e mantém: coordenador não implementa, paralelo quando possível, roteamento por dificuldade,
kickoff obrigatório.

## 5. Cadeias

Máximo três saltos: índice → corpo da porta → folha.

- **Projeto Python novo:** `python` → `module-design` (antes de escrever) + `repo-defaults` → código.
- **Refactor/review:** `code-audit` → tabela de quatro modos → `code-review` / `grilling` / rodar / `chaos-engineering`; e `module-design` antes de propor refactor.
- **Airflow/dbt/BigQuery:** `data-engineering` → `references/*`; modelagem e glossário → `domain-modeling`; arquitetura → `system-design`.
- **Frontend:** `frontend-build` → `frontend-design-doc` → `frontend-direction` (superfície nova) → `frontend-rules` → `frontend-verify`; estrutura de componente → `code-audit`.
- **Dashboard:** `frontend-dashboard` → `references/dashboard-spec.md` → `frontend-dashboard-charts` → `frontend-rules`.
- **Motion:** `motion-build` é a porta manual; `frontend-rules` e `frontend-direction` apontam para ela.

## 6. Enforcement

Frontmatter: `cluster`, `tier` (`root`/`leaf`), `derived_from` (quando absorvida).

`check-skills.sh` falha quando:

1. skill sem `cluster`/`tier`;
2. `tier: root` fora da lista de 13 portas, ou `tier: leaf` dentro dela;
3. folha sem aresta de entrada;
4. aresta folha→folha;
5. índice acima de 2.800 chars ou mais de 14 portas;
6. nome fora da gramática (domínio conhecido + trabalho, sem palavra proibida);
7. folha cuja palavra-gatilho não aparece na descrição da porta;
8. absorvida sem `derived_from` ou sem entrada no notice.

`scripts/skill-map.sh [--find <termo>]` gera `SKILL-MAP.md` (cluster, porta, tier, auto/manual, chars,
gatilho, arestas) e responde busca por termo em nome/descrição/gatilho, custo zero de contexto.

## 7. Harness

Fluxo: repo → `~/.agents/skills` → espelhos `claude`, `kiro`, `codex`, `gemini`; Pi lê o farm direto.

| Gap | Correção |
|---|---|
| Codex trata as 8 do matt como auto (`agents/openai.yaml` sem `policy.allow_implicit_invocation: false`) | reescrever/remover o bloco na absorção; linker garante o flag nas folhas |
| agy: `~/.gemini/antigravity-cli/skills` vazio, espelho em `~/.gemini/config/skills` | confirmar num `/skills`; senão incluir o dir |
| intenção por harness não checada | `check-skills.sh --strict` |
| `olorin` é link para repo de projeto | manter; documentar que editar edita o projeto |

## 8. Absorções adicionais aprovadas

- `revenue-centric-design` → `frontend-revenue-design` (frontend).
- `modern-web-guidance` → `frontend-platform-docs` (frontend), corpus + script de busca mantidos.
- `chrome-extensions` → parked.
- `tdd` → processo (folha), apontada por `code-audit` e `module-design`.
- `webscraping-expert` → `webscraping`, folha de `data-engineering`, com escopo de autorização explícito.
- `grilling` mantida, apontada por `code-audit` e `prototype`.
- `prototype` e `research` mantidas, manuais.

## 9. Referência nova: samsantosb/ship-it

7 skills de pipeline idea→PR (`groundwork`, `make-guidelines`, `create-product`, `create-tasks`,
`do-task`, `watch-pr`, `chaos-engineering`), ~600 linhas + 5 contratos em `shared/` + `evals/`.

Veredito: **não vendorar o pipeline** (duplica `pr`, `olorin`, thread do T3, `delegate`). Absorver três
ideias:

1. **`card-format.md`** — unidade de trabalho com critério de pronto verificável; candidata a referência de
   `delegate`.
2. **`chaos-engineering`** — adversário que escreve teste para quebrar a implementação; papel de review que
   não temos. Vira folha de `code-audit`.
3. **`evals/README.md`** — bateria: cada skill é um prompt para subagente novo em tier declarado; achado
   corrige o arquivo, não o eval. Adotar como formato da fase de governança, com nossos subagentes.

## 10. Fase de governança (fim, e agora com formato definido)

- `papercut`: skill sempre carregada que registra atrito em `papercuts/`.
- Lint de corpo no `check-skills.sh`: passo com critério de conclusão, comando concreto, tabela de erro.
- `link-skills.sh --without <skill>` para ablation com prompt real.
- `evals/` no repo com 3 a 5 prompts por porta, no formato do ship-it.

## 11. Migração

- **Fase 0** defeitos: 3 links mortos em `system-design` (`references/grilling.md`), `animate-expo` em
  `motion-build`/`motion-performance`, refs mortas em `dashboard-spec`, prologue roteirizado das 10 de
  motion, smell list duplicado em `code-review`.
- **Fase 1** `git mv` de `third-party/*` para `personal/*` com os nomes da §2, `derived_from` em cada uma,
  notice reescrito, `chrome-extensions` para parked, dissoluções (`emil`, `dashboard-spec`).
- **Fase 2** cadeias da §5 nos corpos das portas; `code-audit` ganha a tabela de quatro modos.
- **Fase 3** frontmatter `cluster`/`tier` + regras do `check-skills.sh` + `skill-map.sh`/`SKILL-MAP.md`.
- **Fase 4** harness: `openai.yaml`, agy, `--strict`.
- **Fase 5** governança da §10.

Nada toca `parked/`. Toda fase é reversível por git.
