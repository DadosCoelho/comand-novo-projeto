---
name: git-workflow
description: Practical Git knowledge and this user's automatic local-versioning workflow — branch per task, commit at the end of each completed task, git init automatically when a project isn't versioned yet, and git push/pull/fetch only with explicit authorization in the conversation. Also a command/workflow/recovery reference (merge vs rebase, reflog, bisect, undoing mistakes).
trigger: >
  TRIGGER proactively whenever doing multi-step work inside (or about to create)
  a project directory: starting a new task/feature/fix, finishing a task or
  todo, needing to create/switch a branch, resolving a merge conflict,
  recovering lost work, or running any non-trivial git command. Also trigger
  when the user asks about git commands, branching, merge/rebase, workflows,
  or best practices ("como fazer rebase", "o que é git flow", "perdi um
  commit", "cria uma branch pra isso").
  SKIP when the user explicitly says not to touch git for this task, or when
  working outside any project directory (e.g. answering a conceptual question
  unrelated to a specific repo).
---

# Git Workflow — conhecimento prático + automação pessoal

Duas coisas nesta skill: (1) as **regras de comportamento automático** que
devo seguir em todo repositório Git deste usuário, e (2) uma **referência
prática** de comandos/fluxos para consultar quando precisar.

## Regras de comportamento automático (sempre válidas)

Estas regras vêm de uma decisão explícita do usuário sobre como quer que eu
trabalhe com Git em todos os projetos. Sigo por padrão, sem perguntar de
novo a cada tarefa:

1. **Git init automático.** Se eu estiver prestes a editar/criar arquivos
   num diretório de projeto que ainda não é um repositório Git, rodo
   `git init` (branch `main`) antes de continuar. Não preciso perguntar.

2. **Branch por tarefa/feature.** Ao começar um pedido novo e substancial
   (uma feature, um fix, uma exploração que vai gerar mudanças de código),
   crio e troco para uma branch descritiva a partir da branch atual:
   `git switch -c <tipo>/<slug-curto>` (ex.: `feature/login-social`,
   `fix/crash-ao-salvar`). Uso julgamento: uma pergunta rápida, uma
   correção de uma linha, ou uma continuação direta da mesma tarefa **não**
   merecem branch nova — só pedidos que começam um trabalho distinto.

3. **Commit ao final de cada tarefa concluída.** Quando terminar um
   subtarefa/todo com mudanças de arquivo relevantes, faço um commit local
   atômico com mensagem descritiva (ver [boas práticas](reference/boas-praticas-seguranca.md)).
   Não preciso que o usuário peça "comita isso" — é o padrão.

4. **Push, pull e fetch remoto só com autorização explícita nesta
   conversa.** Nunca sincronizo com um remote (GitHub, etc.) sem o usuário
   pedir claramente naquele momento — mesmo que eu já tenha feito push antes
   na mesma sessão, autorização não se estende automaticamente a chamadas
   futuras. Commits e branches **locais** não precisam de autorização.

5. **Nunca reescrevo histórico já publicado** (rebase/amend/force-push de
   commits que já foram enviados a um remote) sem confirmação explícita —
   ver [branching e merge](reference/branching-merge-fluxos.md).

6. **Hook de auto-commit por projeto é opt-in, não automático por mim.**
   Alguns projetos deste usuário têm um hook `Stop` configurado (via
   `/claude:novo-projeto`) que faz um commit mecânico de segurança ao final
   de cada resposta. Isso é um hook do harness, não uma ação minha — eu
   continuo fazendo meus próprios commits atômicos com mensagens boas
   (regra 3); o hook é só uma rede de segurança complementar. Não preciso
   verificar se ele existe nem replicá-lo manualmente.

## Referência rápida (cheatsheet)

| Preciso de... | Comando |
|---|---|
| Iniciar branch de tarefa nova | `git switch -c feature/<slug>` |
| Ver o que mudou | `git status` / `git diff` |
| Commitar tudo com mensagem | `git add -A && git commit -m "tipo: resumo"` |
| Desfazer um commit sem apagar histórico | `git revert <hash>` |
| Recuperar algo "perdido" | `git reflog` → `git reset --hard HEAD@{N}` |
| Achar o commit que quebrou algo | `git bisect start` |
| Levar um commit para outra branch | `git cherry-pick <hash>` |
| Trabalhar em 2 branches ao mesmo tempo | `git worktree add ../pasta branch` |

Para o dia a dia completo, aprofundamento e exemplos, ver:

- [reference/comandos-essenciais.md](reference/comandos-essenciais.md) —
  tabela completa de comandos do dia a dia, configuração inicial, aliases.
- [reference/comandos-avancados.md](reference/comandos-avancados.md) —
  rebase interativo, reflog, bisect, worktree, submodules, hooks, remoção
  de segredos do histórico.
- [reference/branching-merge-fluxos.md](reference/branching-merge-fluxos.md) —
  merge vs. rebase, conflitos, Feature Branch / Git Flow / Trunk-Based /
  Forking, quando usar cada um.
- [reference/boas-praticas-seguranca.md](reference/boas-praticas-seguranca.md) —
  mensagens de commit, Conventional Commits, nunca commitar segredos, o que
  fazer se um segredo vazar, `.gitignore`, `--force-with-lease`.

## Se algo der errado

Antes de qualquer operação potencialmente destrutiva (`reset --hard`,
`push --force`, `clean -f`, sobrescrever branch), rodar `git status`
primeiro e considerar `git stash` como rede de segurança — consistente com
a prática geral de "medir duas vezes, cortar uma" para ações difíceis de
reverter.
