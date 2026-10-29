#!/usr/bin/env sh
# Mostra o diff entre cada skill de terceiro-parte aqui e upstream, sem aplicar nada.
cd "$(dirname "$0")/.."
echo "TODO: clone upstream repos forneçidos em skills.lock.yaml para /var/tmp, "
echo "diff SKILL.md por skill, e reporte divergencias. Nunca aplicar cega."
