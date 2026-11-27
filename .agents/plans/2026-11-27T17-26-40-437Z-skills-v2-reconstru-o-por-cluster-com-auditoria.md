# Skills v2: reconstrução por cluster, com auditoria desde o início

Não é migração. É a versão nova do repo. Nada precisa ser preservado, ponteiro quebrado não é
problema, e `check-skills.sh` é reescrito do zero. `parked/` fica intocada até a fase 4.

## 0. Premissas

1. **Cluster é a estrutura de disco.** Não existe `personal/` nem `third-party/`. Existe
   `base/ engineering/ frontend/ motion/ process/`.
2. **Proveniência é metadado**, não pasta: `derived_from: {repo, commit, license}` no frontmatter.
3. **Nome carrega o domínio**, diretório não repete: `frontend/build/` com `name: frontend-build`.
4. **Porta é tier declarado no frontmatter** (`tier: root`), não lista paralela. Só porta pode ser auto.
5. **O corpo herda, a estrutura nasce nova.** Reescrever 48 corpos não é a tarefa de hoje; o que nasce
   novo é árvore, nomes, tiers, scripts, evals e o mapa.
6. **Auditoria é parte da entrega**, não fase futura: uso, custo, eval, lint e papercut entram junto.

## 1. Árvore

```
skills/
  base/
    repo-defaults/
  engineering/
    backend/  data-engineering/  infra/  security/  python/  code-audit/  debug/
    module-design/  domain-modeling/  system-design/  code-review/
    benchmark-check/  blast-radius/  webscraping/  chaos-engineering/
  frontend/
    build/  rules/  verify/  dashboard/
    direction/  design-doc/  storybook/  dashboard-charts/  taste/
    platform-docs/  revenue-design/  diagrams/  stress/  choose-library/
  motion/
    build/  sequence/  review/  improve/  remove/  find/  performance/  vocabulary/
  process/
    delegate/  pr/  retro/  research/  prototype/  tdd/  grilling/
    wizard/  agent-docs/  unslop/
  parked/            (intocada até a fase 4)
  evals/             (uma pasta por porta)
  papercuts/         (registros de atrito)
  scripts/
  SKILL-MAP.md       (gerado)
  README.md
  ATTRIBUTION.md
```

48 skills, 5 clusters, 13 portas, 35 folhas. `olorin` continua externo, linkado por `external:`.

Nota aceita: `motion` é o cluster mais frágil (um `motion-build` carrega a rota de sete irmãs). Fica como
está; se encolher depois, o corte é `build` + `review` + `performance`.

## 2. Nomes

`name: <domínio>-<trabalho>`; diretório = última parte do nome quando o cluster já dá o domínio.

| Cluster | Nome | Dir | Tier | Modo |
|---|---|---|---|---|
| base | `repo-defaults` | `base/repo-defaults` | root | auto |
| engineering | `backend` | `engineering/backend` | root | auto |
| engineering | `data-engineering` | `engineering/data-engineering` | root | auto |
| engineering | `infra` | `engineering/infra` | root | auto |
| engineering | `security` | `engineering/security` | root | auto |
| engineering | `python` | `engineering/python` | root | auto |
| engineering | `code-audit` | `engineering/code-audit` | root | auto |
| engineering | `debug` | `engineering/debug` | root | auto |
| engineering | `module-design` | `engineering/module-design` | leaf | manual |
| engineering | `domain-modeling` | `engineering/domain-modeling` | leaf | manual |
| engineering | `system-design` | `engineering/system-design` | leaf | manual |
| engineering | `code-review` | `engineering/code-review` | leaf | manual |
| engineering | `benchmark-check` | `engineering/benchmark-check` | leaf | manual |
| engineering | `blast-radius` | `engineering/blast-radius` | leaf | manual |
| engineering | `webscraping` | `engineering/webscraping` | leaf | manual |
| engineering | `chaos-engineering` | `engineering/chaos-engineering` | leaf | manual |
| frontend | `frontend-build` | `frontend/build` | root | auto |
| frontend | `frontend-rules` | `frontend/rules` | root | auto |
| frontend | `frontend-verify` | `frontend/verify` | root | auto |
| frontend | `frontend-dashboard` | `frontend/dashboard` | root | auto |
| frontend | `frontend-direction` | `frontend/direction` | leaf | manual |
| frontend | `frontend-design-doc` | `frontend/design-doc` | leaf | manual |
| frontend | `frontend-storybook` | `frontend/storybook` | leaf | manual |
| frontend | `frontend-dashboard-charts` | `frontend/dashboard-charts` | leaf | manual |
| frontend | `frontend-taste` | `frontend/taste` | leaf | manual |
| frontend | `frontend-platform-docs` | `frontend/platform-docs` | leaf | manual |
| frontend | `frontend-revenue-design` | `frontend/revenue-design` | leaf | manual |
| frontend | `frontend-diagrams` | `frontend/diagrams` | leaf | manual |
| frontend | `frontend-stress` | `frontend/stress` | leaf | manual |
| frontend | `frontend-choose-library` | `frontend/choose-library` | leaf | manual |
| motion | `motion-build` | `motion/build` | root | manual |
| motion | `motion-sequence` | `motion/sequence` | leaf | manual |
| motion | `motion-review` | `motion/review` | leaf | manual |
| motion | `motion-improve` | `motion/improve` | leaf | manual |
| motion | `motion-remove` | `motion/remove` | leaf | manual |
| motion | `motion-find` | `motion/find` | leaf | manual |
| motion | `motion-performance` | `motion/performance` | leaf | manual |
| motion | `motion-vocabulary` | `motion/vocabulary` | leaf | manual |
| process | `delegate` | `process/delegate` | root | auto |
| process | `pr` | `process/pr` | root | manual |
| process | `retro` | `process/retro` | root | manual |
| process | `research` | `process/research` | root | manual |
| process | `prototype` | `process/prototype` | root | manual |
| process | `grilling` | `process/grilling` | root | manual |
| process | `tdd` | `process/tdd` | root | manual |
| process | `wizard` | `process/wizard` | root | manual |
| process | `agent-docs` | `process/agent-docs` | root | manual |
| process | `unslop` | `process/unslop` | root | manual |

Auto: 13 (todos `tier: root` do base/engineering/frontend + `delegate`). Índice ≈ 2.300 chars ≈ 575 tokens.
`motion-build` e os playbooks de processo são `root` mas manuais: porta de navegação, não de gatilho.

## 3. Duplicatas: o que a medição mostrou

- **Arquivo inteiro:** um único par acima do corte, `motion-find` ↔ `motion-remove` (8,7% de shingles de
  8 palavras, herdando a tabela de frequência).
- **Seção repetida:** easing `cubic-bezier(0.23, 1, 0.32, 1)` em 5 arquivos; gate de frequência em 6;
  smell list em `code-review` e `code-audit`; frase de kickoff de subagente em 3.

Consequência de projeto, não de limpeza: **cada tabela repetida vira um único arquivo canônico**, e quem
precisa dela aponta. Candidatos: `motion/reference-easing.md`, `motion/reference-frequency.md`,
`engineering/reference-smells.md`, e o kickoff passa a viver só em `process/delegate`.

## 4. Auditoria (fase 2, entrega junto com a estrutura)

Cinco mecanismos, todos medindo algo concreto, nenhum inventando infraestrutura.

| Mecanismo | O que mede | Onde escreve |
|---|---|---|
| `scripts/usage.sh` | invocações por skill, sessões, último uso, custo médio da invocação e chars carregados, lidos dos JSONL (`usage.cost.total` antes/depois da leitura). Escopo inicial: só Pi; OpenCode/Claude/agy entram depois da revisão do conjunto | `USAGE.md` |
| `scripts/eval.sh <porta>` | roda os prompts de `evals/<porta>/` num subagente novo, com e sem a skill; grava veredito e custo | `evals/<porta>/results/` |
| lint de corpo (dentro de `check.sh`) | passo numerado com critério de conclusão, comando concreto por passo, tabela de erro; no-op contra o default | saída do check |
| `papercut` (skill always-on) | atrito encontrado durante o trabalho: skill, tentativa, esperado, aconteceu, correção | `papercuts/AAAA-MM-DD-<skill>.md` |
| `link.sh --without <skill>` | ablation: monta o farm sem uma skill para o braço de comparação | farm temporário |

Formato de eval, adaptado do ship-it e do artigo: por porta, 3 prompts — 1 caso dourado com saída
esperada, 2 prompts reais tirados do histórico. Julgamento: o próprio autor lê a saída e o diff, sem
juiz LLM no início. Barra: passou em 2 de 3 e o caso dourado sempre.

## 5. Papéis

| Papel | Contrato | Onde |
|---|---|---|
| Orquestração | `process/delegate` (auto) | skill |
| Execução | `~/.agents/worker.md` | arquivo, primeira linha do kickoff |
| Review | tabela em `code-audit`: diff → `code-review`, design → `grilling`, prova rodando → verifier, quebra → `chaos-engineering` | folhas |
| Estado durável | `olorin` | externo |

## 6. Cadeias (máximo 3 saltos)

- Python novo: `python` → `module-design` → código; defaults em `repo-defaults`.
- Refactor/review: `code-audit` → tabela de 4 modos → `code-review` / `grilling` / rodar / `chaos-engineering`.
- Airflow/dbt: `data-engineering` → `references/*`; modelagem → `domain-modeling`; arquitetura → `system-design`.
- Frontend: `frontend-build` → `frontend-design-doc` → `frontend-direction` → `frontend-rules` → `frontend-verify`; estrutura → `code-audit`.
- Dashboard: `frontend-dashboard` → `references/spec.md` → `frontend-dashboard-charts` → `frontend-rules`.
- Motion: `frontend-rules`/`frontend-direction` → `motion-build` → irmãs.

## 7. Scripts, do zero

| Script | Contrato |
|---|---|
| `link.sh` | lê `name:` do frontmatter, linka `cluster/<dir>` → `~/.agents/skills/<name>` e espelha em claude/codex/kiro/gemini; `--without <name>`, `--dry-run`, `--check` |
| `check.sh` | estrutura (cluster/tier válidos), nomes (gramática, unicidade), arestas (folha órfã, folha→folha), orçamento (≤14 portas, ≤2.800 chars), frontmatter, lint de corpo, paridade de espelhos, `--strict` |
| `map.sh` | gera `SKILL-MAP.md`; `--find <termo>` busca em nome/descrição/gatilho |
| `usage.sh` | métricas de uso e custo a partir das sessões |
| `eval.sh` | bateria por porta |

## 8. Multi-harness

**Fica na fase 1 (uso diário):** repo → `~/.agents/skills` → espelhos claude, codex, kiro, gemini; Pi lê o
farm direto. `link.sh` continua reconciliando todos eles a cada mudança, senão agy e claude quebram no
meio da reconstrução. `link.sh --check` compara paridade de espelho.

**Fica para depois da revisão do conjunto:** medir uso fora do Pi, e a política de invocação por harness
(Codex `agents/openai.yaml` com `policy.allow_implicit_invocation: false` nas folhas; confirmar se agy lê
`~/.gemini/config/skills` ou `~/.gemini/antigravity-cli/skills`).

## 9. Fases

1. **Estrutura.** Árvore da §1, `git mv` dos corpos, `name`/`cluster`/`tier`/`derived_from` no
   frontmatter, `ATTRIBUTION.md`, `chrome-extensions` e `dashboard-spec` e `emil` resolvidos
   (parked / reference / receitas), scripts novos, cadeias da §6 nos corpos.
2. **Auditoria.** `usage.sh`, `eval.sh` com as 13 portas, lint de corpo, `papercut`, `--without`.
3. **Gaps.** Só depois de 1 e 2: quais skills faltam, a partir de uso real e dos papercuts.
4. **Parked.** Só depois de você aprovar o conjunto ativo.

## 10. Fora de escopo agora

`parked/` (241 skills), refazer corpos que não sejam porta, e qualquer skill nova. Fase 3 e 4.

## 11. Estado de execução (2026-11-27)

Feito e verificado:

- Árvore da §1 no disco: `base/ engineering/ frontend/ motion/ process/`, 47 skills, 13 portas,
  34 folhas. `personal/`, `third-party/`, `retize/` removidos.
- Frontmatter reescrito nas 47: `name`, `cluster`, `tier`, `disable-model-invocation` conforme o tier,
  `derived_from` nas absorvidas.
- Scripts novos: `link.sh` (lê `name` do frontmatter, `--without`, `--pack`, `--check`, `--dry-run`),
  `check.sh`, `map.sh` (gera `SKILL-MAP.md`, `--find`), `usage.sh`, `eval.sh`. `link-skills.sh`,
  `check-skills.sh` e `update-skills.sh` removidos.
- `licenses/` com os 7 textos de licença; `chrome-extensions` em `parked/web/`;
  `dashboard-spec` em `frontend/dashboard/references/dashboard-spec/`; `emil-design-eng` dissolvido em
  `motion/build/RECIPES.md`.

Desvios em relação ao plano, com motivo:

1. **`mv` em vez de `git mv`.** Parte dos arquivos estava untracked, então `git mv` falharia. O git vê
   delete + add.
2. **47 skills, não 48.** `chaos-engineering` não existe hoje: era ideia do ship-it, não conteúdo.
   Vira gap da fase 3.
3. **`direction` e `taste` saíram da lista de nomes proibidos.** `frontend-direction` e `frontend-taste`
   foram escolhidos por você e o prefixo já desambigua; a regra cumpriu o papel dela.
4. **`RECIPES.md` levou 6 receitas, não 2.** Lido o arquivo, o valor único do emil eram seis padrões
   (tooltip sem atraso, dispensa por velocidade, damping, hold-to-delete, tabs com clip, reveal/slider).
5. **`usage.sh` mede só Pi**, como acordado: 461 invocações em 12 das 47 skills, 35 nunca invocadas.
6. **`eval.sh` imprime os braços por padrão** e só executa com `--run`, para não gastar quota sem
   decisão explícita.

### Correções posteriores à execução

- **Regra de aresta refinada.** `leaf → leaf` continua proibido, mas só quando o ponteiro é para a
  entrada da skill (`.../SKILL.md` ou o diretório). Apontar para `.../references/<arquivo>.md` de outra
  skill não carrega o corpo dela e não é rota, então não conta como aresta. Foi o caso de
  `frontend-direction` → `frontend-taste/references/tells.md`.
- **Ponteiro relativo agora é checado.** `check.sh` falha em `](references/....md)` e `](../....md)` que
  não existem no disco. Testado com link falso: acusou e voltou a verde ao remover.
- **Renomear em prosa estragou 4 lugares, corrigidos:** `derived_from` de `frontend-platform-docs` e de
  `frontend-revenue-design` viraram slugs inexistentes, a URL upstream e o comando `npx` do corpus
  também, e um link relativo de `revenue-design` passou a apontar para arquivo que não existe. Rename
  lexical não distingue nome de skill de nome de projeto upstream; a checagem de link relativo agora
  pega esse caso.
- **`system-design` tinha 3 links mortos para `references/grilling.md`**, defeito que vinha do repo
  antigo e nenhum check pegava. Agora apontam para a skill `grilling`.
- **`map.sh --find` passou a mostrar auto/manual**, além de tier.
- 25 arquivos tiveram nomes antigos trocados em prosa (inclusive dentro de `description`), com o verbo
  "animate" preservado: só `` `animate` `` entre crases era referência a skill.

### Bateria de eval: rodada 1 invalidada e o desenho corrigido

A primeira rodada (4 portas caras, 24 execuções) mediu a coisa errada, por três motivos, todos
registrados em `evals/VERDICTS.md`:

1. O laço do runner morria no primeiro prompt: o `pi` filho herdava o here-string e comia as linhas
   seguintes. Corrigido com `</dev/null` nas chamadas.
2. O braço "sem skill" lia a skill de qualquer jeito, porque o cwd era este repo. O diretório existe
   independente do link.
3. O modelo leu o próprio gabarito em `evals/<port>/expected-*.md` e deduziu que estava sendo avaliado.

Decisão: **um braço só**, com a skill, contra a rubrica, rodando num fixture copiado para um diretório
temporário. `--arms` continua disponível para ablation pontual, quando o custo do isolamento se
justifica. Fixtures em `evals/fixtures/<port>/`. O veredito de qualquer porta é `não medido` até uma
rodada válida.

### Card format: recusado, e o motivo

O card format do ship-it é o contrato entre `create-tasks`, `do-task` e `chaos-engineering`. Aqui não
existe produtor nem consumidor de card, então o documento não teria função. As duas partes que faltavam
de verdade no nosso `delegate` entraram nele: aceite escrito como comportamento verificável com valores
concretos, e ponto de atenção obrigatório (silêncio proibido). A terceira, `file:line` lido nesta
sessão, também.

### Sync de harness: Codex resolvido, agy pendente de uma medição

Codex decide invocação implícita por `agents/openai.yaml`, não pelo nosso frontmatter. As 37 skills
manuais passaram a carregar `policy.allow_implicit_invocation: false` (29 arquivos novos, 8 completados),
e o `check.sh` reprova qualquer divergência entre o frontmatter e o que o Codex enxerga. Testado
removendo a política de uma skill.

agy: provado que o CLI do shell lê `~/.gemini/config/skills` (ele respondeu com nomes do farm). Não
provado dentro do T3, porque o T3 inicializa o agy com um perfil privado em
`~/.t3/userdata/providers/antigravity/<hash>/antigravity-acp`, cujo `settings.json` só tem `auth` e cuja
única pasta de skills é `builtin/skills`. Antes de espelhar para lá, é preciso confirmar o caminho com uma
medição real dentro de uma thread do T3.
