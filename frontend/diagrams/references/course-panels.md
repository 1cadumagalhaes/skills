# Course panels

A teaching page is not a marketing page with more words. The section that carries a
technical course is a **worked example you can operate**: a process, a state you can
advance, and the artifact changing in front of you. Five panels do almost all of it,
and they share one skeleton.

The timings that make these panels feel considered come from frame-by-frame
measurements in the clips. Read `references/motion-craft.md` before picking any
duration.

Working examples, both self-contained:

- `examples/stepper.html`: the stepper with a simulated clock, node-click
  explanations and a scenario tab (panels 1 and 3 of this file).
- `examples/panels.html`: the other five panels include a learner-driven walkthrough
  with a terminal, pipeline scenarios and atomic transformations, one artifact in N
  representations, the robot demo, and the highlight/notes shell.

Everything below comes from watching real lesson panels frame by frame and writing the
mechanism from scratch: no source was read, no code copied.

## The shared frame

Every one of these panels is built from the same five parts:

```
┌──────────────────────────────────────────────────────────┐
│ Título: o que este painel mostra                          │
│ ⌐ Instrução: "Aperte o botão e acompanhe…"                │
│ ┌──────────────────────────────────────────────────────┐ │
│ │                    o palco                            │ │
│ │  (diagrama · artefato · terminal · planilha)          │ │
│ └──────────────────────────────────────────────────────┘ │
│  mensagem do passo atual                                  │
│ ─────────────────────────────────────────────────────────│
│  [ Pausar ]  [ Próximo passo ]  [ Reiniciar ]   4 de 7   │
│  Nota de rodapé: o que é ilustrativo e o que é real       │
└──────────────────────────────────────────────────────────┘
```

Four rules that come straight from that frame:

1. **The instruction is part of the component.** "Aperte o botão e acompanhe o robô
   passando de card em card na loja", "Você também pode clicar em qualquer etapa".
   A panel nobody knows how to operate teaches nothing.
2. **Progress is always visible.** `passo 4 de 8`, a pager of numbered circles, or a
   segmented bar, never just "next".
3. **One footnote of honesty.** "Os tempos são ilustrativos… O que vale é a ordem dos
   passos e o tamanho de cada um perto dos outros." Say what is real and what is
   illustrative, in the component, not in a comment.
4. **Colour is semantic and consistent.** Neutral = untouched, amber = working now,
   green = already done, yellow marker = "read this bit / this is the emphasis",
   one extra hue per meaning (purple for TLS, say). A legend sits under the stage
   whenever two colours coexist.

## Panel 1: the stepper with a simulated clock

The strongest one: a system diagram where each step names who is working, which hop
carries the packet, and how much simulated time has passed.

State is a single index into an array of steps:

```js
const steps = [
  { title: 'O visitante digita o endereço e aperta Enter',
    at: ['visitante'], hops: ['v-dns'], ms: 0,
    note: 'O navegador só tem um nome: comparador.example. Máquinas se acham por número…' },
  { title: 'O DNS responde com o endereço',
    at: ['dns'], hops: ['dns-v'], ms: 14,
    note: 'O DNS é a lista de contatos da internet…' },
  // …
];
```

Everything on screen is derived from `i`, never stored per element:

- **node status**: `steps.slice(0, i+1)` mentioning the node → if it is in
  `steps[i].at`, it is *working* now (amber); if it appeared earlier, *done* (green);
  otherwise *untouched* (neutral). One pass over the array rebuilds the whole picture,
  so "restart" is `i = 0`.
- **the active hop**: `steps[i].hops` → that edge goes black and gets a small dot
  travelling along it; every other edge is grey.
- **the clock**: `steps.slice(0, i+1).reduce(sum of ms)`; the bar is
  `total / finalTotal`, so the bar's *jumps* are the lesson. A 15 ms CPU step looks
  cheap next to a 40 ms round trip.
- **the message**: `steps[i].note`, one or two sentences, no scrollbar.

```js
function render(i) {
  const acc = steps.slice(0, i + 1).reduce((s, x) => s + x.ms, 0);
  el.title.textContent = steps[i].title;
  el.note.textContent = steps[i].note;
  el.ms.textContent = acc + ' ms';
  el.bar.style.transform = `scaleX(${acc / total})`;
  el.pager.forEach((p, k) => p.setAttribute('aria-current', k === i ? 'step' : 'false'));
  for (const node of nodes) node.dataset.state = stateOf(node, i);   // idle | active | done
}
```

CSS does the rest; the only transitions are `stroke`/`border-color`/`transform` at
200-300 ms. No timeline library or per-step keyframes. The panel is a
**pure function of an index**, which is also why clicking a numbered circle to jump
to step 6 is free.

Controls: `Pausar` (auto-advance every ~2.5 s; the label flips to `Continuar`),
`Próximo passo`, `Reiniciar` (disabled at 0). Auto-advance stops for good on the
first manual interaction.

**Click any node** → its own explanation in the message area ("toque numa peça do
desenho para ver o que ela é"). That is what turns the diagram into a glossary the
learner can interrogate instead of watch.

## Panel 2: learner-driven walkthrough

The same skeleton, but the trigger is the learner's action rather than a button:
a URL field, "aperte Enter", and the stages light up one after another. Each row has
a label, a one-line description, a mini bar and its cost: `DNS 14 ms`, `TCP 21 ms`,
`TLS 49 ms`, `Request HTTP`, and `Resposta HTTP`.

Two things make it better than a stepper:

- **The terminal is the ground truth.** Beside the stages, a `curl -v` transcript
  scrolls with the same events, so "the lesson" and "the real tool" are the same
  screen. Code output as authority, not as decoration.
- **The learner's own input is the data.** They type the domain; the panel walks
  *their* request. Personalisation without a login.

Build it as: `stages[]` (same `{title, note, ms}` shape) + an input + a `run()` that
walks the array on a timer, appending terminal lines from the same array
(`stage.terminal` strings). ~120 lines.

## Panel 3: pipeline stepper with scenarios

Five stage cards in a row (`Onde o dado nasce → Ingestão → Transformação →
Armazenamento → Uso`), each with an icon, a status chip (`pronto` / `rodando` /
`esperando`), a done check and an index badge. Below, the selected stage's detail
plus the *work being done*: "O preço em texto vira número", `"R$ 3.499,00"` →
`3499.00`.

Three additions over Panel 1, all worth copying:

- **Atomic transformation rows.** A stage is not explained by prose but by the exact
  before → after of the data it touches. Rows accumulate ("três regras de limpeza,
  uma de cada vez"), each with its own check.
- **Scenarios as tabs.** "Um dia normal" and "Um dia em que quebra (a ingestão falha
  de madrugada)" swap the *data*, not the diagram. Failure becomes a story you can
  play, which is the single most useful thing a course can do.
- **The last stage renders the product.** When the pipeline reaches `Uso`, the panel
  shows the manager's dashboard with `R$ 812.400 em 2.344 vendas ontem` and a bar
  chart with "ontem" highlighted. The learner sees the thing they are building at the end
  of the path they just walked.

Progress is a segmented bar (past dark, current amber, future light) plus `6 de 7`.

## Panel 4: one artifact, N representations

A segmented control across the top (`Arquivo CSV · Planilha · Banco de dados`), the
selected one outlined in ink, the others muted. Under it: one line of what this
representation *is*, then the artifact itself rendered in its own idiom. Show a
spreadsheet with A/B/C/D columns and row numbers, a table of
rows for the database, or a monospace file for the CSV.

Then the second row shows **who touches the data**: a person icon, an arrow with a
travelling dot, and the file (`precos.xlsx · o arquivo`). Repeat for the next variant.

The mechanic is "same data, three shapes", and it works because the artifact is
*drawn as itself* rather than described. Keep the switcher to 2-4 options; it is a
comparison, not a menu.

Variant seen for architectures: the same `coleta.jsonl` traced through
`Lake` / `Warehouse` / `Lakehouse`, stepped through one at a time (2/4), the inactive
architectures dimmed to ~40 %, the active one annotated inline (`~US$ 0,023 por GB ao
mês`, `esquema na leitura`). Same panel, branches instead of representations.

## Panel 5: the robot demo

A fake browser (traffic lights, URL bar with the query string) showing a product
grid, a scripted robot cursor moving card to card, each card outlined as it is read
with its title and price highlighted, and on the right a table growing one row per
card. The button reads `Copiando…` while it runs, then resets.

Rules:

- the cursor path is authored, not simulated. It animates a *process*, so the order
  is the content;
- the highlight must show *what is being read*, not that something happened;
- the output table is the punchline: same columns, real numbers, growing;
- it must be legible as a still frame, because that is how people share a course.

## Panel 6: the study shell

The layer around the lesson, not a lesson panel: select text → it becomes a
highlight → it lands in a card with the quote, a note field, the date, a link back
to the lesson and a delete. A page collects them with tabs `Tudo · Grifos · Notas`,
a search field, and an `Exportar`.

Two details worth keeping: every saved item is anchored to its lesson
(`Extrair · E08 · Bloqueios, limites e proxies`), and the top bar always has the way
back (`Voltar para a aula`). A note you cannot find again is not a feature.

## Prose and panel interleave

The layout of a lesson, from the frames:

```
h1  O que um engenheiro de dados faz
h2  Dado é como água
p   …a metáfora, concreta, três frases…
p   …"Aperte Começar e siga uma venda"… (a instrução precede o painel)
PANEL
p   …o que acabou de acontecer, nomeando as partes…
h2  O nome desse caminho é pipeline
p   …
```

The paragraph after the panel is not a repeat: it names what the learner just saw
("esse caminho tem cinco etapas: onde o dado nasce, a ingestão…"). Text carries the
argument; the panel carries the evidence.

## What these panels deliberately avoid

- No motion that cannot be stopped. Auto-advance is fine. The reference panel opens
  already running with `Pausar` visible, but only while the panel is on screen. It
  stops for good at the first manual interaction. The prose around it must never move.
- No scroll-driven state. The scroll belongs to the text.
- Nothing hidden behind interaction: the panel is complete at step 1, it just gets
  more specific.
- No fake numbers presented as measurements. The footnote clarifies which numbers
  are illustrative.

## Build order for your own course

1. Write the lesson's argument as five or six sentences. The steps of the panel are
   those sentences, in order, each with one artifact change.
2. Author the `steps[]` array (title, note, active nodes/hops, ms, output). No markup
   yet.
3. Render `f(state)` for one static state, badly, in plain HTML. Check it reads with
   no CSS.
4. Add the state, the controls and the pager. Verify keyboard: `→` next, `←` prev,
   `Home` restart, and the pager navigable.
5. Add colour states and the legend. Verify with a screenshot at step 1 and step N.
   Both must read as "this is a panel about X".
6. Add the scenario tab (normal / breaking) if the topic has a failure mode.
7. Reduced motion: no auto-advance, instant state changes, everything else identical.
