# Pesquisa sobre Git

Índice organizado do conhecimento levantado sobre o Git — do conceito ao
funcionamento interno, passando por comandos, fluxos de trabalho e boas
práticas.

## Sumário

1. [Introdução e história](01-introducao-historia.md) — o que é, por que
   surgiu, DVCS vs. centralizado.
2. [Conceitos fundamentais](02-conceitos-fundamentais.md) — repositório,
   commit, branch, HEAD, staging area, remote.
3. [Internals — como o Git funciona por dentro](03-internals.md) — objetos
   (blob/tree/commit/tag), `.git/`, refs, packfiles, SHA-1 vs SHA-256.
4. [Comandos essenciais do dia a dia](04-comandos-essenciais.md) — tabela de
   comandos básicos com exemplos.
5. [Comandos avançados](05-comandos-avancados.md) — rebase interativo,
   reflog, bisect, worktree, submodules, hooks, filter-repo.
6. [Branching e merge](06-branching-e-merge.md) — merge vs. rebase,
   fast-forward, conflitos, estratégias.
7. [Fluxos de trabalho (workflows)](07-fluxos-de-trabalho.md) — Feature
   Branch, Git Flow, Trunk-Based, Forking.
8. [Boas práticas](08-boas-praticas.md) — commits atômicos, mensagens,
   Conventional Commits, segredos, `.gitignore`.
9. [Git vs. GitHub/GitLab/Bitbucket](09-git-vs-plataformas.md) — a
   ferramenta vs. as plataformas.
10. [Referências](10-referencias.md) — links úteis para aprofundar.
11. [A árvore de commits — diagramas](11-arvore-de-commits.md) — os mesmos
    conceitos de branch/merge/rebase/cherry-pick/HEAD, em diagramas Mermaid.

## Como usar esta pasta

Cada arquivo é independente e pode ser lido isoladamente, mas a leitura em
ordem (1 → 11) segue uma progressão lógica: do conceito ao uso prático, do
básico ao avançado.

> Existe também um resumo anterior, mais enxuto, em
> [`ai-docs/pesquisa-git.md`](../ai-docs/pesquisa-git.md). Esta pasta
> substitui e expande aquele conteúdo, organizado por tema.
