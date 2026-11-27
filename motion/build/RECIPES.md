# Recipes salvos do `emil-design-eng`

Seis padrões que existiam só naquele arquivo e que nenhuma irmã do cluster cobre. O resto do conteúdo dele
está em `motion/review`, `motion/improve`, `motion/performance` e `motion/sequence`. Absorvido de
`emilkowalski/skills`, MIT, © 2026 Emil Kowalski (`licenses/MIT-Emil-Kowalski.txt`).

## Tooltips: sem atraso no segundo hover

Atraso no primeiro tooltip evita ativação acidental. Depois que um abriu, os vizinhos devem abrir na hora,
sem animação.

```css
.tooltip { transition: transform 125ms ease-out, opacity 125ms ease-out; }
.tooltip[data-starting-style],
.tooltip[data-ending-style] { opacity: 0; transform: scale(0.97); }
.tooltip[data-instant] { transition-duration: 0ms; }
```

## Descartar por velocidade, não por distância

Não exija arrastar além de um limiar. Calcule `velocity = |delta| / elapsed`. Acima de ~0,11, dispensa
mesmo com distância curta.

```js
const velocity = Math.abs(swipeAmount) / (Date.now() - dragStart.current.getTime());
if (Math.abs(swipeAmount) >= SWIPE_THRESHOLD || velocity > 0.11) dismiss();
```

## Damping e friction nas bordas

Ao arrastar além do limite natural, o elemento anda cada vez menos. Nunca pare de repente: aplique
friction crescente em vez de bloqueio.

## Hold-to-delete

`clip-path: inset(0 100% 0 0)` sobre um overlay colorido; no `:active`, transição para `inset(0 0 0 0)`
em 2s linear; ao soltar, volta em 200ms ease-out. `scale(0.97)` no botão dá o retorno do toque.

## Tabs com transição de cor contínua

Duplique a lista de tabs, estilize a cópia como ativa e recorte com `clip-path` para mostrar só a tab
ativa. Anime o recorte. Isso produz transição de cor que animar `color` e `background` individualmente
nunca alcança.

## Reveal de imagem e slider de comparação

Reveal: `clip-path: inset(0 0 100% 0)` até entrar no viewport, com `IntersectionObserver` e
`{ once: true, margin: "-100px" }`. Slider: duas imagens sobrepostas, a de cima recortada em
`inset(0 50% 0 0)`, ajustando o inset direito pelo arrasto. Sem DOM extra.
