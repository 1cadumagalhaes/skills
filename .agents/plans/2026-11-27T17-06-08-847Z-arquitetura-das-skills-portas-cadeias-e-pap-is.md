# Arquitetura das skills: portas, cadeias e papéis

Substitui o plano anterior. Estado em 2026-11-27: 51 ativas, 18 auto / 900 tokens de índice,
241 parked (intocadas). Revisão de conteúdo nas seções 6 e 7.

## 0. Decisões tomadas nesta conversa

1. **Cluster não é disciplina, é cadeia que dispara junto.** Backend/data/infra/security se chamam
   entre si; frontend é cadeia fechada em si; motion e processo idem. `engineering ⊃ frontend` fica
   declarado no mapa, mas são clusters separados.
2. **Não existe dispatcher.** Auto = descrição no system prompt e escolha semântica do modelo.
   O caminho específico vem de **ponteiro no corpo**, que custa zero no índice.
3. **Gate de proveniência removido.** Auto exige `tier: root`, gatilho na descrição, teste do no-op
   e um dono capaz de corrigir (vendor com pin registrado conta). "Só personal" deixa de existir.
4. **Doutrina de orquestração mora no `policy.md`** (sempre no prompt). Não nasce skill `orchestrate`.
5. **Papel não é skill.** Orquestração, execução, review e estado são papéis; o mapa aponta onde cada
   contrato vive.
6. **Frontend não aponta para `dsa-system-design`** (zero conteúdo de frontend). Aponta para
   `code-quality`, que hoje falta.

## 1. Clusters e portas

Porta = skill que dispara sozinha e a partir da qual o caminho desce. Folha = manual, custo zero,
alcançada por ponteiro.

| Cluster | Porta | Auto | Gatilho na descrição |
|---|---|---|---|
| base | `project-baseline` | sim | começar trabalho em repo, sem skill mais específica |
| engineering | `backend` | sim | endpoint, tabela, migration, transação, fila, job |
| engineering | `data-engineering` | sim | Airflow, dbt, BigQuery, Postgres, dlt, pipeline, qualidade de dados |
| engineering | `infra` | sim | Dockerfile, Kubernetes/GKE, IAM, Terraform, CI/CD, custo |
| engineering | `security` | sim | auth, tenancy, PII, segredo, dependência, MCP |
| engineering | `modern-python` | sim | projeto Python, uv, Ruff, ty, pytest, Makefile |
| engineering | `code-quality` | sim | auditar módulo, revisar código existente, refactor |
| engineering | `diagnosing-bugs` | sim | bug difícil, regressão, lentidão |
| frontend | `frontend-workflow` | sim | construir/mudar página ou componente |
| frontend | `ui-craft` | sim | a11y, semântica, CSS, contraste, teclado, números tabulares |
| frontend | `frontend-verify` | sim | verificar UI no browser, overflow, console, axe |
| frontend | `dashboard` | sim | dashboard, painel, Grafana, métrica, filtro |
| motion | `animate` | não | construir animação (você nomeia; `ui-craft` aponta) |
| process | `pr` | não | abrir PR, stack de PRs |
| process | `retro` | não | retrospectiva, erro repetido |
| process | `grilling` | não | interrogar design antes de decidir |
| process | `research` | não | pesquisar em fonte primária |
| process | `writing-for-agents` | não | escrever/revisar skill, AGENTS.md, agente |
| process | `unslop` | não | cortar tell de IA em texto |
| process | `wizard` | não | fluxo guiado por etapas |

Auto proposto: **12** (≈ 2.150 chars, ≈ 540 tokens). Debatível: `design-direction` (hoje auto).
Recomendo manual: `frontend-workflow` já roteia para ela em superfície nova.

## 2. Folhas e quem as alcança

Nenhuma folha aparece no índice. Toda folha precisa de pelo menos uma aresta de entrada, senão é
biblioteca que só existe se você lembrar o nome.

| Folha | Alcançada por |
|---|---|
| `dsa-system-design` | backend, code-quality, data-engineering |
| `codebase-design` | modern-python (projeto novo/refactor), code-quality (antes de propor refactor), code-review |
| `domain-modeling` | data-engineering (modelagem), backend (schema), codebase-design |
| `tdd` | codebase-design, code-quality |
| `prototype` | code-quality (provar viabilidade), design-direction |
| `code-review` | code-quality (modo diff), pr |
| `benchmark-checklist` | diagnosing-bugs (regressão de perf) |
| `blast-radius` | pr, code-quality (mudança fora do diff) |
| `webscraping-expert` | data-engineering (ingestão) |
| `design-contract` | frontend-workflow (passo 1), design-direction |
| `design-direction` | frontend-workflow (superfície nova) |
| `storybook-workflow` | frontend-workflow (componente isolado) |
| `design-taste-frontend` | frontend-workflow (página pública), design-direction |
| `dashboard-design`, `dashboard-spec` | dashboard |
| `modern-web-guidance`, `chrome-extensions` | frontend-workflow |
| `diagram-sections` | design-direction |
| `choreograph`, `review-animations`, `improve-animations`, `remove-animations`, `find-animation-opportunities`, `animation-performance`, `animation-vocabulary`, `break-ui`, `pick-ui-library` | animate (router do motion, substitui emil) |

Folhas hoje órfãs que ganham aresta nesta migração: `codebase-design`, `domain-modeling`, `tdd`,
`prototype`, `benchmark-checklist`, `blast-radius`, `code-review`, `design-contract`, `wizard`,
`research`, `chrome-extensions`, `modern-web-guidance`.

## 3. Cadeias concretas (o que você pediu)

Máximo três saltos: índice → corpo da porta → folha.

**Projeto novo em Python:** `modern-python` casa ("creating any Python project") → corpo abre com
"novo projeto: leia `codebase-design` antes de escrever código; defaults de repo em
`project-baseline`" → `codebase-design` define módulo profundo/seam → implementação.

**Refactor ou review de módulo:** `code-quality` casa → corpo ganha a tabela de três modos
(diff → `code-review`, design contestado → `grilling`, prova de execução → rodar) + "antes de propor
refactor, `codebase-design`". O papel de review não vira skill: vira essa tabela.

**Airflow / modelagem de dados:** `data-engineering` casa → tabela atual manda `references/airflow.md`,
`references/dbt-and-quality.md`; ganha duas linhas: modelagem/ADR → `domain-modeling`, arquitetura
distribuída → `dsa-system-design`.

**Frontend:** `frontend-workflow` casa → passo 1 manda `design-contract` e, em superfície nova,
`design-direction` → `ui-craft` para `[req]` → `frontend-verify` no browser. Ganha linha nova:
estrutura de componente/página → `code-quality`.

## 4. Papéis (processo)

| Papel | Contrato vive em | Skill? |
|---|---|---|
| Orquestração | `~/.agents/policy.md` (renderizado em todo harness) | não |
| Execução (worker) | `~/.agents/worker.md`, entregue na 1ª linha do kickoff | não |
| Review | tabela dentro de `code-quality` + folhas `code-review`/`grilling` | não |
| Estado durável | `olorin` (externo, no lock) | já existe |
| Playbooks humanos | `pr`, `retro`, `research`, `wizard` | manuais |

`personal/delegation` sai: é duplicata literal do policy. `personal/writing-for-agents` ganha a seção
"revisar uma skill existente" (checklist que o `check-skills.sh` não mede) e aresta vinda do `retro`.

## 5. Frontmatter e enforcement

```yaml
cluster: base | engineering | frontend | motion | process
tier: root | leaf
```

`check-skills.sh` passa a falhar quando:

1. skill ativa sem `cluster`/`tier`;
2. `tier: root` sem `disable-model-invocation` ausente (root é auto por definição) ou folha auto;
3. folha sem aresta de entrada;
4. aresta folha→folha (o mesh do emil volta);
5. mais de 14 auto ou índice acima de 2.800 chars;
6. folha cuja palavra-gatilho não aparece na descrição da sua porta (skill inalcançável por vocabulário).

`scripts/skill-map.sh` gera `SKILL-MAP.md`: cluster, porta, tier, auto/manual, chars, gatilho, arestas.
É o documento para você abrir e saber o que existe e por onde entrar.

## 6. Revisão de conteúdo: defeitos a corrigir (fase 0)

Verificados por mim, arquivo e linha:

| Onde | Defeito |
|---|---|
| `dsa-system-design/SKILL.md:51,63,96` | 3 links para `references/grilling.md`, que não existe |
| `animate:17`, `animation-performance:17` | apontam para `animate-expo`, inexistente |
| `dashboard-spec:71-72` | `success-metrics` e `observability-plan` inexistentes |
| `code-review:44-52` | repete o smell list da dimensão 5 de `code-quality:36` |
| 10 skills de motion | prologue roteirizado ("Do not provide any other information") = 1 turno perdido por uso |
| `emil-design-eng` | 3ª cópia das mesmas tabelas + referências invertidas para skills que ele contém; 685 linhas atrás de um gatilho manual |
| `webscraping-expert` | 944 linhas; anti-bot/stealth é área de política, precisa de escopo de autorização explícito |
| `design-taste-frontend` | 533 linhas, gates 1440/768/390 vs 1280/375 do `frontend-verify` — dois padrões de verificação |

## 7. Fila de absorção (deixar de depender de terceiro)

Reescrever em `personal/` e remover o vendor no mesmo commit: `choreograph` (172),
`remove-animations` (167), `animation-performance` (223), `break-ui` (176), `codebase-design` (115),
`domain-modeling` (75), `tdd` (39), `code-review` (90).

Fica como estante manual, sem absorção: `design-taste-frontend`, `modern-web-guidance`,
`chrome-extensions`, `dsa-system-design`, `revenue-centric-design`, `wizard`, `research`, `prototype`.
`emil-design-eng` é dissolvido (duas receitas resgatadas para `animate/RECIPES.md`).

## 8. Sincronização entre harnesses

Fluxo: repo → `~/.agents/skills` → espelhos `claude`, `kiro`, `codex`, `gemini`. Pi lê o farm direto.

| Gap | Evidência | Correção |
|---|---|---|
| Codex ignora o flag manual nas 8 do matt | `agents/openai.yaml` com `interface:` e sem `policy.allow_implicit_invocation: false` | linker escreve o bloco nas manuais, ou removemos os `openai.yaml` |
| agy não provado | `~/.gemini/antigravity-cli/skills` vazio; espelho em `~/.gemini/config/skills` | confirmar num `/skills` do agy; senão incluir o dir nos espelhos |
| intenção por harness não checada | só paridade de symlink | `check-skills.sh --strict` |
| `olorin` é link para repo de projeto | `external:` no lock | manter; documentar que editar edita o projeto |

## 9. Orçamento

12 portas ≈ 540 tokens de índice (hoje 18 / 900). Folha: 0. Trigger de folha: ~1 linha na tabela da
porta. O ganho real não é token, é colisão e legibilidade: hoje 18 descrições competem e nada diz
qual vem antes.

## 10. Migração

- **Fase 0** defeitos da §6; cadeias novas da §3 (linhas de roteamento nos corpos das portas).
- **Fase 1** frontmatter `cluster`/`tier` + regras do `check-skills.sh` + `skill-map.sh`/`SKILL-MAP.md`.
- **Fase 2** tiers: 12 auto, retirada de `delegation`, dissolução do `emil`, `animate` como router do motion.
- **Fase 3** absorção da §7, uma por commit.
- **Fase 4** harness: `openai.yaml`, agy, `--strict`.
- **Fase 5** governança: `papercut`, lint de corpo, `--without` para ablation.

Destrutivo só na fase 3, e nada toca `parked/`.
