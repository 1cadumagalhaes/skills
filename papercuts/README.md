# Papercuts

Atrito registrado por agentes enquanto seguiam uma skill. Um arquivo por relato, nomeado
`AAAA-MM-DD-<skill>.md`, escrito pela skill `papercut` (ver `~/.agents/skills/papercut/SKILL.md`).

Cada relato traz cinco linhas: o que foi tentado com `file:line` da instrução, o que a skill prometia, o que
aconteceu com a saída real citada, o contorno que manteve a sessão andando, e a menor correção que evitaria
o problema.

Como usar:

- `ls papercuts/ | cut -d- -f4- | sort | uniq -c | sort -rn` mostra quais skills mais fazem o agente tropeçar.
- Um relato por causa. Causa repetida no mesmo dia vira `-2`, não um terceiro arquivo com o mesmo texto.
- Quando a correção entra, o relato fica: é o registro de que o erro existiu e do que o evitou.
- Correção que é regra mecânica entra no `scripts/check.sh`, não em prosa. Se a mesma classe de erro pode
  ser detectada por script, detectar é melhor que documentar.
