# skills

Repositório de skills AI (seção 11 do pi-setup.md). Consumido por Pi e OpenCode
via symlinks em `~/.agents/skills/` (os dois agentes leem esse diretório).

## Estrutura

- `personal/` — skills meus (modern-python, frontend-workflow, ...)
- `retize/` — padrões de time Retize; staging até o time adotar (depois viram repo em ~/Work)
- `third-party/` — skills de terceiro-parte, com edições locais preservadas; fonte+pin em skills.lock.yaml
- `scripts/` — helpers (update/review de terceiros)

## Regras de update de terceiros

1. Trabalhe sempre contra skills.lock.yaml (fonte + pin + modified_by_user).
2. Upstream nunca sobrescreve cego: scripts/update-skills.sh mostra o diff antes.
3. customização pequena → wrapper SKILL.md apontando pro original; grande → vendor (o que já é o caso da maioria).
