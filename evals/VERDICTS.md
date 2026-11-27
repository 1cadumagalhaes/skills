# Vereditos de eval

## 2026-11-27 — rodada 2 (válida): backend, security, data-engineering, infra

Um braço (skill montada), workspace = cópia temporária de `evals/fixtures/<port>/`, modelo
`opencode-go/deepseek-v4.1-flash`, 12 execuções. Julgamento por leitura contra `expected-<n>.md`, como
o `evals/README.md` define. Supervisão: durante a rodada eu editei skills de `process/` e
`frontend/verify`, nenhuma delas nas quatro portas medidas; as portas em teste não mudaram.

| porta | prompt | veredito | evidência |
|---|---|---|---|
| backend | 1 | **passa** | `POST /v1/subscriptions` com `Idempotency-Key` hasheada, replay do 201, 409 em reuse, outbox em vez de dual write, tenant de header com `extra="forbid"`, migration separada, RFC 9457. `12 passed, 3 skipped` |
| backend | 2 | **passa** | recusa `NOT NULL` + backfill num deploy só; expand/backfill/contract em 3 deploys, `SET NOT NULL` via CHECK validado, `CREATE INDEX CONCURRENTLY`, `lock_timeout`; pergunta o caso irrespondível (customer de linhas legadas) |
| backend | 3 | **passa** | dirigiu a app real com `TestClient`, achou o vazamento entre tenants em `handlers.py:28-31` com evidência de contagem, e listou os handlers sombreados |
| security | 1 | **passa** | 8 achados com `file:line`, prova de execução, veredito "não embarcar"; inclui achado adjacente no mesmo release (CPF em claro no signup) |
| security | 2 | **passa** | recusa logar CPF, implementa redação em `logging.py` com `SENSITIVE_FIELDS`, loga só forma (`cpf_present`, `cpf_length`, `cpf_digits_only`) e prova `LEAK cpf: False` |
| security | 3 | **passa** | separa "conectar" de "confiar": inventário de ferramentas, escopo read-only, `enabled: false` + `toolExposure`, token por env, risco residual escrito |
| data-engineering | 1 | **passa** | DAG nova seguindo as convenções da fixture, partição obrigatória, `merge` incremental com `currency` no `unique_key`, janela dirigida pela run (não por `max(date)`), 26 testes |
| data-engineering | 2 | **passa** | recusa o `backfill_2026_11.py` e explica o mecanismo: sem `--vars` a mart cai no fallback e o backfill não chega nela; a cópia vira segunda implementação da janela |
| data-engineering | 3 | **passa** | faz a aritmética a partir do baseline dado (186 TB/mês), recusa inventar o número pós-mudança, mostra que `LIMIT` não reduz scan e que a dedupe acontece depois da cobrança |
| infra | 1 | **passa** | Dockerfile multi-stage com imagens pinadas por digest, orçamento de startup 180s para boot de 40s, `minReadySeconds`, CPU request elevado **marcado como decisão de custo** que exige `kubectl top`, seletor imutável preservado |
| infra | 2 | **passa** | recusa criar JSON key; descobre que o CI já usa WIF no próprio fixture e mostra que a key não resolveria, porque o gap é autorização de IAM, não autenticação |
| infra | 3 | **falha** | 257 bytes, duas frases. Sem a aritmética de custo, sem requests vs uso, sem as três ações, sem encadear `references/cost-and-observability.md`. Ainda afirma "500m → 1", valor que não existe na fixture (`requests: 500m`, `limits: 2`) |

**Resultado: 3 de 4 portas passam (2 de 3 ou melhor). `infra` passa 2 de 3 e tem uma falha real.**

## O que a rodada mostra além do placar

- **O padrão mais forte é a recusa.** Os quatro prompts de borda (`prompt-2`) pedem algo destrutivo ou
  caro: migration arriscada, log de PII, cópia de DAG com data fixa, chave de SA. Nas quatro, a skill
  produziu recusa com mecanismo, não com opinião. Era para isso que as portas existiam.
- **Onde a skill não paga é o custo.** `infra` é a segunda skill mais cara por uso (US$ 3,32) e na
  pergunta de custo respondeu em duas frases. `data-engineering`, que tem `references/bigquery.md`,
  respondeu com aritmética completa na mesma pergunta. A diferença não é o modelo: é o caminho.
- **Nenhuma resposta inventou número.** As três que precisavam de medição disseram qual comando rodar e
  recusaram reportar um "depois" não medido.

## Correção de prompt no meio da rodada

`data-engineering/prompt-3` pedia "prove que o número caiu" **sem dar a query nem o baseline**, e o
fixture não tem `bq` autenticado. Nas duas rodadas o modelo parou pedindo a query. O prompt ganhou a
consulta e o baseline medido, e a rubrica passou a exigir a aritmética sobre o baseline dado e a
proibir número pós-mudança inventado. Não é afrouxar: é deixar de pedir o impossível.

## Ação que sai daqui

1. `infra`: a pergunta de custo precisa de caminho obrigatório. A porta deve encadear
   `references/cost-and-observability.md` e exigir a conta (requests × réplicas × preço Autopilot) antes
   de recomendar qualquer mudança. Hoje isso está na rubrica do eval e não no corpo da skill.
2. Nove portas não têm fixture, então `eval.sh` sai 2 nelas. Sem fixture não há medição: `python`,
   `code-audit`, `debug`, `repo-defaults`, `frontend-*`, `delegate`.
3. O padrão dos prompts de borda vale mais que o placar: qualquer porta nova deve ter um caso que
   **exige recusa**, porque é ali que a skill mostra se carrega julgamento ou só texto.

Arquivos de saída em `evals/<port>/results/` são gitignored; este documento é o registro.
