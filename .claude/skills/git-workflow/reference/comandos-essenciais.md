# Comandos essenciais do dia a dia

## Configuração inicial (uma vez por máquina)

```bash
git config --global user.name "Seu Nome"
git config --global user.email "voce@exemplo.com"
git config --global init.defaultBranch main
```

## Criando / obtendo um repositório

| Comando | Para quê serve |
|---|---|
| `git init -b main` | Cria um repositório novo na pasta atual, já com branch `main` |
| `git clone <url>` | Copia um repositório remoto (histórico completo) |
| `git clone --depth 1 <url>` | Clone raso, só o commit mais recente |

## Estado e histórico

| Comando | Para quê serve |
|---|---|
| `git status` | Branch atual, o que mudou, o que está staged |
| `git log --oneline --graph --all` | Histórico compacto, com grafo de branches |
| `git diff` | Working tree vs. staging area |
| `git diff --staged` | Staging area vs. último commit |
| `git show <commit>` | Detalhes e diff de um commit específico |
| `git blame <arquivo>` | Quem mudou cada linha e em qual commit |

## Stage e commit

| Comando | Para quê serve |
|---|---|
| `git add -A` | Adiciona todas as mudanças (novas, modificadas, removidas) |
| `git add -p` | Adiciona interativamente, por pedaço (hunk) |
| `git commit -m "tipo: resumo"` | Grava um snapshot com o que está staged |
| `git commit --amend` | Corrige o último commit (só se ainda não publicado) |
| `git restore --staged <arquivo>` | Tira do stage sem perder a mudança |
| `git restore <arquivo>` | Descarta mudanças não commitadas |

## Branches

| Comando | Para quê serve |
|---|---|
| `git branch` | Lista branches locais |
| `git switch -c <nome>` | Cria e troca para uma branch nova |
| `git switch <nome>` | Troca para uma branch existente |
| `git branch -d <nome>` | Apaga branch já mesclada |
| `git branch -m <novo-nome>` | Renomeia a branch atual |

## Integrando e sincronizando

| Comando | Para quê serve |
|---|---|
| `git merge <branch>` | Junta outra branch na atual |
| `git rebase <branch>` | Reaplica commits da atual em cima de outra |
| `git fetch <remote>` | Baixa refs do remote, sem tocar na working tree |
| `git pull` | `fetch` + `merge`/`rebase` — **só com autorização do usuário** |
| `git push` | Envia commits ao remote — **só com autorização do usuário** |

## Desfazendo coisas

| Comando | Para quê serve |
|---|---|
| `git stash` / `git stash pop` | Guarda e recupera mudanças não commitadas |
| `git reset --soft <commit>` | Move a branch, mantém mudanças staged |
| `git reset --hard <commit>` | Move a branch e **descarta** mudanças locais |
| `git revert <commit>` | Cria commit novo que desfaz outro, sem reescrever histórico |
| `git clean -fd` | Remove arquivos/pastas não rastreados |

## Aliases úteis

```bash
git config --global alias.st status
git config --global alias.co switch
git config --global alias.lg "log --oneline --graph --all --decorate"
```
