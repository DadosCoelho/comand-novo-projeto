# Branching e merge

> Prefere visualizar em diagramas? Ver
> [11-arvore-de-commits.md](11-arvore-de-commits.md) — os mesmos conceitos
> abaixo, desenhados em Mermaid.

## Fast-forward vs. merge commit

Quando você mescla uma branch `feature` em `main`, o Git verifica se `main`
não avançou desde que `feature` foi criada:

- **Fast-forward**: se `main` não tem nenhum commit novo desde a origem de
  `feature`, o Git simplesmente move o ponteiro de `main` para o último
  commit de `feature` — não cria commit de merge, histórico fica linear.
- **Merge commit (three-way merge)**: se ambas as branches avançaram
  separadamente, o Git cria um **commit de merge**, com dois pais,
  combinando as mudanças das duas linhas de histórico. É chamado "three-way"
  porque o Git compara três pontos: o ancestral comum, a ponta de cada
  branch.

```bash
git merge --no-ff <branch>   # força um commit de merge mesmo quando fast-forward seria possível
git merge --ff-only <branch> # só mescla se puder ser fast-forward; senão, aborta
```

`--no-ff` é útil para manter visível no histórico que uma feature foi
desenvolvida em uma branch separada, mesmo quando um fast-forward seria
tecnicamente possível.

## Merge vs. Rebase

Duas formas diferentes de trazer para a branch atual as mudanças feitas em
outra (ou de atualizar sua branch com o que mudou em `main`):

| | Merge | Rebase |
|---|---|---|
| O que faz | Cria um novo commit que junta as duas histórias | Reescreve os commits da branch atual, um por um, como se tivessem sido criados em cima do novo ponto base |
| Histórico resultante | Não-linear, preserva exatamente o que aconteceu (inclui commits de merge) | Linear, "limpo", parece que tudo aconteceu em sequência |
| Hashes dos commits | Preservados | **Mudam** (são commits novos, mesmo com o mesmo conteúdo) |
| Seguro em branch compartilhada? | Sim, sempre | Só antes de publicar (fazer push) a branch — depois disso, reescrever é arriscado para quem já puxou |
| Conflitos | Resolvidos uma vez, no commit de merge | Podem precisar ser resolvidos **a cada commit** reaplicado |

Regra prática amplamente usada: **rebase branches locais e ainda não
compartilhadas** para manter histórico limpo antes de abrir um PR;
**merge (nunca rebase) branches já públicas/compartilhadas**, para não
quebrar o histórico de quem já baseou trabalho nelas.

## Resolvendo conflitos

Um conflito acontece quando o Git não consegue decidir sozinho como
combinar duas mudanças na mesma região de um arquivo (em merge ou rebase).
O arquivo fica marcado com marcadores:

```
<<<<<<< HEAD
versão da branch atual
=======
versão da branch sendo mesclada
>>>>>>> feature-branch
```

Fluxo para resolver:

```bash
# 1. editar o arquivo, decidindo o conteúdo final, removendo os marcadores
# 2. marcar como resolvido:
git add <arquivo>
# 3a. se estava em merge:
git commit
# 3b. se estava em rebase:
git rebase --continue
```

Comandos úteis durante o processo:

```bash
git merge --abort     # cancela o merge em andamento, volta ao estado anterior
git rebase --abort    # idem, para rebase
git status             # sempre mostra quais arquivos ainda têm conflito
git diff                # mostra os trechos em conflito de forma mais detalhada
```

## Estratégias de merge

O Git suporta diferentes algoritmos internos de merge (flag `-s` /
`--strategy`), sendo os mais relevantes na prática:

- **recursive** / **ort** (Ort — "Ostensibly Recursive's Twin" — é o
  sucessor do algoritmo recursive, e o padrão desde o Git 2.34) — o padrão
  para merges de duas branches, lida bem com renomeações e múltiplos
  ancestrais comuns.
  - Opção comum: `-X ours` / `-X theirs` — em caso de conflito, prefere
    automaticamente uma das duas versões (usar com cautela).
- **ort** também é usado internamente por `rebase` e `cherry-pick`.
- **octopus** — usado automaticamente quando se mescla mais de duas
  branches de uma vez.

## `git merge` vs. Pull Request "Squash and Merge" / "Rebase and Merge"

Nas plataformas (GitHub/GitLab/Bitbucket), ao fechar um Pull Request há
normalmente três opções, que por baixo dos panos usam os mecanismos acima:

- **Merge commit** — equivalente a `git merge --no-ff`: mantém todos os
  commits originais da branch, mais um commit de merge.
- **Squash and merge** — junta **todos** os commits da branch em um único
  commit novo sobre `main`, com uma mensagem consolidada. Histórico de
  `main` fica bem limpo (1 commit por PR), mas perde granularidade dos
  commits intermediários da feature.
- **Rebase and merge** — reaplica cada commit individual da branch,
  linearmente, no topo de `main` (sem criar commit de merge).

A escolha é uma decisão de convenção de time — squash é comum em times que
querem `main` com um commit por PR; merge commit é comum quando se quer
preservar granularidade e contexto de branches de feature.
