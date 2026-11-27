# Pesquisa: observabilidade e feature flags

Duas lacunas medidas no farm em 2026-11-27: `observability` não existe como skill (o termo aparece em 17
arquivos, mas o único conteúdo real é `infra/references/cost-and-observability.md`, sobre custo de nuvem), e
`feature-flags` não aparece nenhuma vez, só dois conselhos soltos em `backend/references/`.

Fontes primárias lidas, não resumos:

- Google SRE Workbook, capítulo 5, "Alerting on SLOs" (sre.google/workbook/alerting-on-slos)
- OpenTelemetry, "Observability primer" e "Signals" (opentelemetry.io/docs/concepts)
- Prometheus, "Metric and label naming" (prometheus.io/docs/practices/naming)
- Martin Fowler / Pete Hodgson, "Feature Toggles (aka Feature Flags)", 9 de outubro de 2017
- OpenFeature, "Introduction" (openfeature.dev/docs/reference/intro)

## Observabilidade: as regras que valem virar skill

| Regra | Origem |
|---|---|
| Observabilidade é responder "por que isso está acontecendo" em produção **sem embarcar código novo**. O critério de instrumentação suficiente: o time não precisa adicionar instrumentação para investigar. | OTel primer |
| Quatro sinais, não três: traces, metrics, logs e **baggage** (contexto que atravessa os outros). Profiles ainda em proposta. | OTel signals |
| SLI parte da experiência do usuário ("a página carrega"), SLO é o SLI com valor de negócio. Sistema 100% no ar pode ser inconfiável: se o botão de comprar não compra, está fora. | OTel primer |
| Alerta de SLO se avalia por quatro propriedades: precisão, recall, tempo de detecção e tempo de reset. | SRE Workbook §Alerting Considerations |
| `for: 1h` **não** substitui janela: a duração não escala com a severidade, então um outage de 100% e um de 0,2% alertam no mesmo tempo, e um SLI que oscila pode nunca alertar. | SRE Workbook, tabela 5-3 |
| Burn rate com múltiplas janelas (multi-window, multi-burn-rate) é a recomendação; a janela curta pega o outage, a longa evita ruído. | SRE Workbook §4 e §6 |
| Nome de métrica: prefixo da aplicação, **uma unidade e uma grandeza** por métrica, unidade base (segundos, bytes), sufixo de unidade no plural, `_total` para contador acumulativo. | Prometheus naming |
| Label diferencia característica; **cada combinação única é uma série nova**. Nunca user id, e-mail ou conjunto ilimitado como label. | Prometheus naming §Labels (o próprio doc marca como CAUTION) |
| `sum()` ou `avg()` sobre todas as dimensões tem que fazer sentido. Se não faz, é sinal de que são duas métricas misturadas. | Prometheus naming |
| Alerta que acorda alguém responde a sintoma do usuário; alerta de causa vai para ticket. | SRE Workbook, cap. 5 |

## Feature flags: as regras que valem virar skill

| Regra | Origem |
|---|---|
| Quatro categorias com vidas diferentes: **release** (dias, some depois do rollout), **experiment** (dura o experimento), **ops** (longa, é kill switch), **permissioning** (longa, é autorização). Tratar todas igual é o erro de origem. | Fowler/Hodgson §Categories |
| **Off = comportamento antigo, On = comportamento novo**, como convenção. Sem isso, testar combinações vira explosão combinatória. | Fowler/Hodgson §Working with flagged systems |
| Se um toggle não suporta configuração em runtime, o teste exige restart ou redeploy: considere um endpoint de override em memória, **restrito a teste automatizado e exploração manual**, nunca a produção compartilhada. | Fowler/Hodgson, mesma seção |
| Testar três configurações, não todas: a de produção, a de fallback (flags que vão sair viradas Off) e all-on para pegar regressão futura. | Fowler/Hodgson |
| Separe o ponto de decisão da lógica de decisão (toggle router), em vez de espalhar `if` pelo código; prefira configuração estática e escale para configuração distribuída só quando precisar. | Fowler/Hodgson §Implementation e §Toggle Configuration |
| Toggle tem **carrying cost**: cada um é dívida a ser removida depois do rollout, não configuração permanente. | Fowler/Hodgson §Managing the carrying cost |
| Use uma API de avaliação vendor-neutral (OpenFeature) para que a escolha do fornecedor não entre no código. | OpenFeature intro |
| Regra que já temos e continua valendo: faça flag de tudo que **não** dá para reverter redeployando a imagem anterior. | `backend/references/service-contract.md:53` |

## Mecanismo: env var, arquivo, banco ou serviço de verdade

O artigo do Fowler lista cinco degraus de configuração, e a regra é subir só quando uma necessidade
concreta empurra:

| Degrau | Serve quando | Custa |
|---|---|---|
| Constante no código | a flag é temporária e sai com o próximo deploy | um build por mudança |
| Variável de ambiente | a mudança é por ambiente, não por usuário | restart ou redeploy para mudar |
| Arquivo de configuração | precisa mudar sem build, mas com versionamento e review | deploy de config, sem targeting |
| Tabela no banco da aplicação | precisa de admin em runtime e de histórico | mais uma dependência no caminho crítico |
| Serviço de flags distribuído | precisa de targeting por contexto, auditoria de quem virou o quê, ambientes, kill switch durante incidente, experimento com exposição | fornecedor, latência de avaliação, mais um ponto de falha |

"Prefira configuração estática" é a recomendação explícita do Fowler, e o OpenFeature confirma o motivo do
último degrau: um sistema completo de flags precisa de admin, trilha de auditoria e gestão de ambientes, e
isso é software, não um arquivo. **Adotar serviço de flags é decisão de operação, não de elegância.**

Três coisas que o mecanismo decide e que precisam estar escritas antes de ligar a primeira flag:

1. **Quem vira a chave em produção**, em quanto tempo, e o que acontece se essa pessoa estiver dormindo. Flag
   de ops sem esse parágrafo é um botão sem dono.
2. **Rollout e rollback são perguntas diferentes.** Rollout é como a novidade chega (canary, percentual,
   targeting); rollback é a garantia de voltar. Flag de release permite rollback em segundos; deploy
   anterior permite rollback em minutos. Se a flag existe só para evitar deploy ruim, o problema é o deploy.
3. **Estado da flag é estado de produção.** Entra no runbook, no monitoramento (erro de provider, latência de
   avaliação) e na resposta a incidente. Flag avaliada no cliente com provider fora do ar é o default
   silencioso, e ninguém descobre isso durante o incidente.

## Flags no cliente: o que só existe no browser

Frontend não é "o mesmo assunto com outro SDK". As fontes acima mostram quatro propriedades que mudam o
desenho:

| Regra | Origem |
|---|---|
| Toda avaliação **exige um valor default**, e é ele que sai em qualquer erro. Sem provider configurado, o SDK entra em no-op e devolve o default. O default é o que o usuário vê quando a flag falha, então default = comportamento seguro e antigo. | OpenFeature Evaluation API e Providers |
| O provider tem estado: pronto, erro e configuração alterada. Sem esperar a prontidão, o primeiro render acontece com o default e a tela troca depois. Escolher entre bloquear o render ou aceitar a troca é decisão explícita, não acidente. | OpenFeature Events |
| Flag no cliente é **visível**: chave, default e valor estão no bundle. Flag de cliente nunca é controle de segurança; quem autoriza é o servidor. | consequência do modelo, não de fornecedor |
| Em renderização no servidor, servidor e cliente precisam avaliar com o mesmo contexto, ou a hidratação diverge. | consequência do modelo |
| Evento de exposição de experimento dispara uma vez por exposição, não a cada render. | prática; o SDK entrega o evento de configuração, o app é que conta | 

## O que entra em cada skill proposta

**`observability`** (folha, cluster engineering; apontada por `infra`, `backend`, `code-audit`):
quais sinais existem e quando cada um resolve; começar pela pergunta do usuário e derivar SLI → SLO → error
budget; instrumentação suficiente como critério de pronto; nome e unidade de métrica; orçamento de
cardinalidade de label; o que nunca vai para log; propagação de contexto; alerta por burn rate com duas
janelas, e a distinção sintoma/causa.

**`feature-flags`** (folha, cluster engineering; apontada por `backend`, `frontend-build` e `infra`): a
categoria decide a vida e o dono; a convenção Off-antigo/On-novo; as três configurações de teste; decisão
separada da lógica; configuração estática antes de distribuída; expiração e remoção como parte da entrega;
API vendor-neutral. E uma seção de superfície: **servidor** (autoriza, decide antes do efeito) e
**cliente** (default obrigatório, provider pronto, hidratação, flag nunca é segurança, exposição uma vez
por render). A mesma skill serve os dois porque a taxonomia e a dívida são as mesmas; só o mecanismo muda.

## O que fica de fora, de propósito

- Estatística de experimento (poder, tamanho de amostra, teste A/B): é assunto próprio, não cabe de carona.
- Preço e UI de fornecedor (LaunchDarkly, Unleash, GrowthBook): muda toda hora e não é conhecimento.
- Custo de observabilidade em si (retenção, sampling caro): já mora em `infra/references/cost-and-observability.md`.
- Dogma de "três pilares": o OTel hoje lista quatro sinais com baggage, e logs não são cidadão de segunda classe.
