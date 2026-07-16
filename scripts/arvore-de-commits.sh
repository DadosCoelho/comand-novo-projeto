#!/usr/bin/env bash
# Gera/atualiza .claude/arvore-de-commits.md com a arvore REAL de commits do
# repositorio atual (git log --graph), diferente dos diagramas conceituais
# em pesquisa/11-arvore-de-commits.md.
#
# Uso: bash scripts/arvore-de-commits.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO_ROOT/.claude/arvore-de-commits.md"

cd "$REPO_ROOT"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Nao e um repositorio git: $REPO_ROOT" >&2; exit 1; }

mkdir -p "$(dirname "$OUT")"
{
  echo "# Árvore de commits"
  echo
  echo "> Gerado automaticamente a partir de \`git log --graph\` — não editar à mão."
  echo "> Atualizado em: $(date '+%Y-%m-%d %H:%M:%S')"
  echo
  echo '```'
  git log --graph --abbrev-commit --decorate --date=short --pretty=format:'%h %ad %s%d' --all
  echo
  echo '```'
} > "$OUT"

echo "OK  $OUT atualizado."
