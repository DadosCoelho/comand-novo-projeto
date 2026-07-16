#!/usr/bin/env bash
# Instala as skills e comandos deste repo em ~/.claude/ (nivel global do
# usuario), para que valham em TODOS os projetos, nao so neste.
#
# Uso:
#   bash scripts/install-global.sh            # nao sobrescreve o que ja existe
#   bash scripts/install-global.sh --force    # sobrescreve versoes ja instaladas

set -euo pipefail

FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_HOME="$HOME/.claude"

SKILLS=(git-workflow pesquisa-workflow)
COMMANDS=(novo-projeto.md pesquisa.md)

echo "Instalando globalmente a partir de: $REPO_ROOT"
echo "Destino (~/.claude): $CLAUDE_HOME"
echo

for skill in "${SKILLS[@]}"; do
  src="$REPO_ROOT/.claude/skills/$skill"
  dest="$CLAUDE_HOME/skills/$skill"

  if [ ! -e "$src" ]; then
    echo "AVISO  skills/$skill nao encontrada em $src -- pulando"
    continue
  fi
  if [ -e "$dest" ] && [ "$FORCE" -eq 0 ]; then
    echo "SKIP   skills/$skill (ja existe em $dest -- use --force para sobrescrever)"
    continue
  fi

  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -r "$src" "$dest"
  echo "OK     skills/$skill -> $dest"
done

for cmd in "${COMMANDS[@]}"; do
  src="$REPO_ROOT/.claude/commands/claude/$cmd"
  dest="$CLAUDE_HOME/commands/claude/$cmd"

  if [ ! -e "$src" ]; then
    echo "AVISO  commands/claude/$cmd nao encontrado em $src -- pulando"
    continue
  fi
  if [ -e "$dest" ] && [ "$FORCE" -eq 0 ]; then
    echo "SKIP   commands/claude/$cmd (ja existe em $dest -- use --force para sobrescrever)"
    continue
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "OK     commands/claude/$cmd -> $dest"
done

echo
echo "Pronto. Abra (ou reabra) o Claude Code em qualquer projeto -- as skills"
echo "sao descobertas pelo gatilho no frontmatter, e os comandos ficam"
echo "disponiveis como /claude:novo-projeto e /claude:pesquisa."
