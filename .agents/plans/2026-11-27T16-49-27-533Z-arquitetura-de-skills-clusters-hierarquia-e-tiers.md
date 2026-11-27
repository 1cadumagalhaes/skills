# Arquitetura das skills: clusters, hierarquia e tiers

Estado em 2026-11-27. Base: 51 ativas (23 `personal/`, 27 `third-party/`, 1 `external/olorin`),
18 auto / 33 manual, índice automático 3.603 chars ≈ 900 tokens, 241 skills parked intocadas.

## 1. Cinco regras que decidem tudo

1. **Só skill de primeira pessoa pode ser auto.** `third-party/` é sempre manual. Nada entra no
   índice automático por vendor; para virar auto, precisa ser reescrita em `personal/`.
2. **Um cluster tem uma porta de entrada, e ela é a única que fala com o irmão.** Folha aponta para
   folha é o que criou o mesh do motion hoje (10 arestas saindo do `emil-design-eng`).
3. **Auto só passa no teste do no-op:** a skill muda o comportamento em relação ao default do modelo.
   Se o texto já está no AGENTS.md/policy, ela paga contexto para dizer nada.
4. **Folha custa zero contexto:** `disable-model-invocation: true` tira a linha do índice, e o
   caminho `~/.agents/skills/<x>/SKILL.md` continua funcionando como ponteiro. Biblioteca não é custo,
   é índice mental — por isso o mapa gerado.
5. **Orçamento de contexto é regra do repo, não intenção:** `check-skills.sh` falha acima de 14 auto
   ou 2.800 chars de índice.

## 2. Clusters

| Cluster | Porta de entrada | Modo | Filhas |
|---|---|---|---|
| **base** | `project-baseline` | auto | — |
| **engineering** | `backend`, `data-engineering`, `infra`, `security`, `modern-python`, `code-quality`, `diagnosing-bugs` (sete portas de domínio, sem router) | auto | `webscraping-expert` (sob data-engineering), `code-review`, `codebase-design`, `domain-modeling`, `tdd`, `prototype`, `benchmark-checklist`, `blast-radius`, `dsa-system-design` |
| **frontend** | `frontend-workflow` | auto | `ui-craft`, `frontend-verify`, `design-direction`, `design-contract`, `storybook-workflow`, `dashboard` (→ `dashboard-design`, `dashboard-spec`), `modern-web-guidance`, `chrome-extensions`, `design-taste-frontend`, `diagram-sections` |
| **motion** | `motion` (novo router) | manual | `animate`, `choreograph`, `review-animations`, `improve-animations`, `remove-animations`, `find-animation-opportunities`, `animation-performance`, `animation-vocabulary`, `break-ui`, `pick-ui-library` |
| **process** | `workflow` (novo router) | manual | `pr`, `retro`, `grilling`, `research`, `writing-for-agents`, `unslop`, `wizard`, e o que vier: issues, commits, releases |

Sem router em engineering de propósito: os sete domínios têm gatilho próprio e não colidem; um router
ali só gastaria uma linha do índice para não economizar nada.

## 3. Mapa medido do estado atual

Grafo de ponteiros entre as 51 (arestas `~/.agents/skills/<x>/`):

- **Hubs:** `unslop` recebe de 5 (`benchmark-checklist`, `blast-radius`, `pr`, `retro`, `writing-for-agents`); `dsa-system-design` recebe de 3 (`backend`, `code-quality`, `data-engineering`); `design-taste-frontend` recebe de 2.
- **Router de fato do motion:** `emil-design-eng` → 10 alvos. É a única entrada daquele cluster.
- **16 isoladas** (nenhuma aresta entra ou sai): `modern-python`, `security`, `infra`, `project-baseline`, `delegation`, `design-contract`, `domain-modeling`, `grilling`, `prototype`, `research`, `wizard`, `webscraping-expert`, `modern-web-guidance`, `revenue-centric-design`, `chrome-extensions`, `olorin`.
  Raiz isolada é normal; folha isolada é biblioteca que só existe se você lembrar do nome.

## 4. Proveniência: o que veio do pstack e do matt

Registro em `THIRD-PARTY-NOTICE.md` §mattpocock/§pstack, conferido contra o histórico.

**Ficou em `third-party/`, manual (8) — mattpocock/skills, pin `abeeaf95660b`:**
`code-review`, `codebase-design`, `domain-modeling`, `grilling`, `prototype`, `research`, `tdd`, `wizard`.

**Foi reescrito para `personal/` (9):**

| Skill | Origem | O que mudou |
|---|---|---|
| `unslop` | pstack | regras de filler PT-BR somadas |
| `blast-radius` | pstack | seams de data/API/infra/UI + `delegate_task` |
| `benchmark-checklist` | pstack | vettings de Python/SQL/CV/BigQuery |
| `retro` | pstack `correct` + matt `retro` | fundidos: erro repetido vira lint/tipo/teste |
| `pr` | matt `pr` + pstack `worker.md` | regras de PR + stack PR nativo |
| `diagnosing-bugs` | matt | adaptado a Python/Airflow/DB/Rust |
| `writing-for-agents` | matt | layout multi-harness + `unslop` |
| `delegation` | pstack `poteto-mode` | contrato de subagente cross-harness |
| — (`~/.agents/worker.md`) | pstack `poteto-mode/worker.md` | contrato do worker |

**Recusado de propósito:** `statechart` + 2 de verificação formal (TLA+, 3,9 MB de toolchain, uso zero),
`swarm`/`arena`/`interrogate` (cobertos por `subagent`/`delegate_task` + `code-review` + `grilling`),
os 24 `principle-*` (folhas que só existem dentro do `poteto-mode`), `show-me-your-work` (é o que
`olorin` + thread do T3 fazem), a spec chain do matt (`grill-with-docs → to-spec → to-tickets →
implement`; nosso processo é thread + olorin).

Conclusão: **não há nada a restaurar**. O rendimento já foi absorvido; o que sobrou do matt é
biblioteca manual e vai para a fila de absorção (§9).

## 5. Auto vs manual: teste de quatro perguntas

1. Muda o comportamento em relação ao default? Não → não é skill, é documento.
2. O modelo deve alcançar sozinho, com gatilho inequívoco? Sim → auto.
3. É playbook que **você** inicia (gates, relatório, PR)? → manual.
4. É folha alcançada por ponteiro da porta de entrada? → manual, sempre.

Aplicado às 18 auto de hoje:

| Skill | chars | Veredito | Por quê |
|---|---:|---|---|
| project-baseline | 165 | auto | defaults de repo, vale em todo projeto |
| backend | 197 | auto | gatilho "endpoint/tabela/job" |
| data-engineering | 200 | auto | gatilho "pipeline/dbt/Airflow" |
| infra | 202 | auto | gatilho "Dockerfile/k8s/IAM" |
| security | 188 | auto | gatilho "auth/PII/secret" |
| modern-python | 177 | auto | convenção de toda tarefa Python (com guarda de repo) |
| code-quality | 176 | auto | auditoria de código existente |
| diagnosing-bugs | 153 | auto | bug difícil / regressão |
| frontend-workflow | 178 | auto | construção de UI |
| ui-craft | 183 | auto | `[req]` de a11y vale também sem construir |
| frontend-verify | 150 | auto | gate depois de UI |
| dashboard | 183 | auto | gatilho "dashboard/painel" |
| design-direction | 174 | **manual** | `frontend-workflow` já roteia em superfície nova |
| design-contract | 172 | **manual** | `frontend-workflow` passo 1 manda ler `DESIGN.md` |
| delegation | 177 | **retirar** | duplicata literal do `~/.agents/policy.md`, já no prompt |
| writing-for-agents | 110 | manual | só ao escrever skill/AGENTS.md |
| webscraping-expert | 193 | **manual** | raro + 944 linhas + regra "third-party nunca auto" |
| unslop etc. | — | manual | já são |

Resultado: **12 auto, ~2.150 chars ≈ 540 tokens** (de 18 / 900).

## 6. Enforcement no repo

Frontmatter ganha dois campos validados:

```yaml
cluster: base | engineering | frontend | motion | process
tier: root | leaf
```

`scripts/check-skills.sh` passa a falhar quando:

1. skill ativa sem `cluster`/`tier`;
2. cluster sem porta de entrada, ou mais de uma porta;
3. folha sem nenhuma aresta de entrada (órfã);
4. aresta folha→folha (o mesh volta);
5. mais de 14 auto ou índice acima de 2.800 chars;
6. skill `third-party` sem `disable-model-invocation`.

`scripts/skill-map.sh` gera `SKILL-MAP.md` a partir do frontmatter + arestas: cluster, porta, tier,
modo, custo em chars, e "quando usar". É o documento que você abre para saber o que existe.

## 7. Sincronização entre harnesses

Fluxo único: repo → `~/.agents/skills` (farm) → espelhos `claude`, `kiro`, `codex`, `gemini`.
Pi lê o farm direto. `link-skills.sh` reconcilia; `check-skills.sh` compara paridade.

Gaps reais:

| Gap | Evidência | Correção |
|---|---|---|
| Codex ignora o flag manual nas 8 do matt | `agents/openai.yaml` com `interface:` e sem `policy.allow_implicit_invocation: false` | o linker escreve esse bloco para toda skill manual, ou removemos os `openai.yaml` e deixamos o default do Codex |
| agy não provado | `~/.gemini/antigravity-cli/skills` vazio, espelho em `~/.gemini/config/skills` | confirmar com um `/skills` no agy; se não achar, incluir o dir na lista de espelhos |
| sem checagem de intenção por harness | só paridade de symlink é verificada | `check-skills.sh --strict` compara o flag do frontmatter com o que cada harness enxerga |
| `olorin` é link para repo de projeto | `external:` no lock | manter, mas documentar que editar a skill edita o projeto |

## 8. Clusters físicos

Não mover diretório. `link-skills.sh` acha `**/SKILL.md` e usa o basename, então mover pasta
funcionaria, mas quebraria `update-skills.sh` (usa caminho do vendor) e a pinagem por nome. O cluster
vive em frontmatter + `SKILL-MAP.md`; o disco continua plano.

## 9. Fila de absorção do third-party

Objetivo declarado: não depender de terceiro. Cada item abaixo é reescrito em `personal/` e o vendor sai.

| Absorver | Linhas | Por que | Destino |
|---|---:|---|---|
| `choreograph` | 172 | regras de sequência (Together/Overlap/Sequence/Carry) não existem em outro lugar | `motion` |
| `remove-animations` | 167 | hazards de remoção (`fill-mode`, `onExitComplete`) | `motion` |
| `animation-performance` | 223 | orçamento de frame, main-thread vs WAAPI | `motion` |
| `break-ui` | 176 | catálogo de pior caso plausível | `motion` |
| `codebase-design` | 115 | vocabulário seam/depth/adapter que `tdd` e `code-review` importam | `engineering` |
| `domain-modeling` | 75 | teste de 3 condições para ADR | `engineering` |
| `tdd` | 39 | seams + anti-padrão tautologia | `engineering` |
| `code-review` | 90 | revisão de diff (o `code-quality` já declara que não é isso) | `engineering` |

Fica como estante, sem absorção: `design-taste-frontend` (533), `modern-web-guidance` (64 + corpus),
`chrome-extensions`, `emil-design-eng` (685, dissolve em `animate/RECIPES.md`), `dsa-system-design`
(97 + 4 refs), `revenue-centric-design`, `wizard`, `research`, `prototype`, `grilling`.

## 10. Migração, em ordem

- **Fase 0 — defeitos (não destrutivo).** `dsa-system-design:51,63,96` → `~/.agents/skills/grilling/SKILL.md`; `animate:17`/`animation-performance:17` → remover `animate-expo`; `dashboard-spec:71-72` → remover refs mortas; prologue roteirizado das 10 de motion.
- **Fase 1 — metadata.** `cluster`/`tier` nas 51, regras novas do `check-skills.sh`, `skill-map.sh` + `SKILL-MAP.md`. Nenhuma mudança de comportamento.
- **Fase 2 — tiers.** As 5 demissões/retiradas de §5; `motion` e `workflow` como routers manuais.
- **Fase 3 — absorção.** §9, uma skill por vez, cada uma saindo do vendor no mesmo commit.
- **Fase 4 — harness.** `openai.yaml` das manuais, verificação do agy, `--strict`.
- **Fase 5 — governança.** `papercut`, lint de corpo, `--without` para ablation.

Destrutivo só na fase 3 (sai vendor) e nada toca `parked/`.

## 11. Decisões que são suas

1. Conjunto auto: 12 (recomendado), 14 (mantém design-direction + design-contract) ou 16.
2. `delegation` sai de vez, ou vira manual como ponteiro para `policy.md`?
3. Absorver as 8 da §9, ou só as 4 de motion e manter o resto como estante?
