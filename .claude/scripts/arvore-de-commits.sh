#!/usr/bin/env bash
# Gera/atualiza .claude/arvore-de-commits.md com um diagrama Mermaid
# `gitGraph` a partir do historico REAL do repositorio atual -- a versao
# "ao vivo" dos diagramas conceituais em pesquisa/11-arvore-de-commits.md.
#
# Uso: bash scripts/arvore-de-commits.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OUT="$REPO_ROOT/.claude/arvore-de-commits.md"

cd "$REPO_ROOT"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Nao e um repositorio git: $REPO_ROOT" >&2; exit 1; }
mkdir -p "$(dirname "$OUT")"

sanitize() {
  printf '%s' "$1" | sed 's/"/\\"/g'
}

# 1) branches locais -- main/master primeiro (historico compartilhado),
#    depois as demais em ordem alfabetica. A "dona" de cada commit e a
#    primeira branch (nessa ordem) cujo historico de FIRST-PARENT (a linha
#    principal, sem entrar pelo lado que foi passado num merge) o contem --
#    diferente de reachability simples, isso nao marca commits de uma
#    feature como "do main" so porque o main ja fez merge dela.
mapfile -t all_branches < <(git branch --format='%(refname:short)' 2>/dev/null)

base_branch=""
for b in "${all_branches[@]}"; do
  if [ "$b" = "main" ] || [ "$b" = "master" ]; then base_branch="$b"; break; fi
done
[ -z "$base_branch" ] && base_branch="${all_branches[0]:-main}"

ordered_branches=("$base_branch")
for b in "${all_branches[@]}"; do
  [ "$b" = "$base_branch" ] && continue
  ordered_branches+=("$b")
done

declare -A owner
for b in "${ordered_branches[@]}"; do
  while IFS= read -r h; do
    [ -z "$h" ] && continue
    [ -n "${owner[$h]:-}" ] && continue
    owner[$h]="$b"
  done < <(git log --first-parent --topo-order --reverse --pretty=tformat:'%H' "$b" 2>/dev/null)
done

declare -A emitted
declare -A branch_declared
mermaid=("gitGraph")

# Emite, em ordem, os commits da linha principal de $2 que pertencem a
# branch $1 e ainda nao foram emitidos.
emit_branch_commits() {
  local br="$1" tip="$2" h subj short msg
  while IFS= read -r h; do
    [ -z "$h" ] && continue
    [ "${owner[$h]:-}" != "$br" ] && continue
    [ -n "${emitted[$h]:-}" ] && continue
    subj="$(git log -1 --pretty=format:'%s' "$h")"
    short="${h:0:7}"
    msg="$(sanitize "$subj")"
    mermaid+=("   commit id: \"$short: $msg\"")
    emitted[$h]=1
  done < <(git log --first-parent --topo-order --reverse --pretty=tformat:'%H' "$tip" 2>/dev/null)
}

# 2) percorre a linha principal (first-parent) da branch base. Cada merge
#    encontrado dispara a branch do outro lado (declarada e "esvaziada" ali,
#    logo antes do merge) antes de continuar.
while IFS=$'\x01' read -r h parents subject; do
  [ -z "$h" ] && continue
  [ -n "${emitted[$h]:-}" ] && continue

  read -ra parent_arr <<< "$parents"
  short="${h:0:7}"
  msg="$(sanitize "$subject")"

  if [ "${#parent_arr[@]}" -ge 2 ]; then
    p2="${parent_arr[1]}"
    ob="${owner[$p2]:-$base_branch}"
    if [ "$ob" != "$base_branch" ]; then
      if [ -z "${branch_declared[$ob]:-}" ]; then
        mermaid+=("   branch $ob")
        branch_declared[$ob]=1
      fi
      mermaid+=("   checkout $ob")
      emit_branch_commits "$ob" "$p2"
      mermaid+=("   checkout $base_branch")
    fi
    mermaid+=("   merge $ob id: \"$short: $msg\"")
  else
    mermaid+=("   commit id: \"$short: $msg\"")
  fi
  emitted[$h]=1
done < <(git log --first-parent --topo-order --reverse --pretty=tformat:'%H%x01%P%x01%s' "$base_branch")

# 3) branches locais que ainda nao foram mescladas na base ficam de fora do
#    passo 2 -- anexa cada uma, na ordem, ao final (melhor esforco).
for b in "${ordered_branches[@]}"; do
  [ "$b" = "$base_branch" ] && continue
  tip="$(git rev-parse "$b" 2>/dev/null)" || continue
  pending=""
  for h in "${!owner[@]}"; do
    if [ "${owner[$h]}" = "$b" ] && [ -z "${emitted[$h]:-}" ]; then pending=1; break; fi
  done
  [ -z "$pending" ] && continue
  if [ -z "${branch_declared[$b]:-}" ]; then
    mermaid+=("   branch $b")
    branch_declared[$b]=1
  fi
  mermaid+=("   checkout $b")
  emit_branch_commits "$b" "$tip"
done

{
  echo "# Árvore de commits"
  echo
  echo "> Gerado automaticamente a partir do histórico real do repositório — não editar à mão."
  echo "> Atualizado em: $(date '+%Y-%m-%d %H:%M:%S')"
  echo
  echo '```mermaid'
  printf '%s\n' "${mermaid[@]}"
  echo '```'
  echo
  echo '<details><summary>Log bruto (git log --graph)</summary>'
  echo
  echo '```'
  git log --graph --abbrev-commit --decorate --date=short --pretty=format:'%h %ad %s%d' --all
  echo
  echo '```'
  echo
  echo '</details>'
} > "$OUT"

echo "OK  $OUT atualizado."
