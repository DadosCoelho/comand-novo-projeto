# Comandos essenciais do dia a dia

## Configuração inicial

```bash
git config --global user.name "Seu Nome"
git config --global user.email "voce@exemplo.com"
git config --global init.defaultBranch main   # define 'main' como branch padrão em novos repos
git config --list                              # vê toda a configuração ativa
```

## Criando / obtendo um repositório

| Comando | Para quê serve |
|---|---|
| `git init` | Cria um repositório novo na pasta atual |
| `git clone <url>` | Copia um repositório remoto (histórico completo) para a máquina local |
| `git clone --depth 1 <url>` | Clone "raso", só o commit mais recente — mais rápido para repos grandes |

## Estado e histórico

| Comando | Para quê serve |
|---|---|
| `git status` | Mostra branch atual, o que mudou, o que está staged |
| `git log` | Histórico de commits |
| `git log --oneline --graph --all` | Histórico compacto, com grafo de branches |
| `git log -p <arquivo>` | Histórico com o diff de cada commit que tocou o arquivo |
| `git diff` | Diferenças entre working tree e staging area |
| `git diff --staged` | Diferenças entre staging area e o último commit |
| `git diff <commit1> <commit2>` | Diferenças entre dois commits quaisquer |
| `git show <commit>` | Detalhes e diff de um commit específico |
| `git blame <arquivo>` | Quem mudou cada linha e em qual commit |

## Área de stage e commit

| Comando | Para quê serve |
|---|---|
| `git add <arquivo>` | Adiciona um arquivo (ou suas mudanças) à staging area |
| `git add -A` / `git add .` | Adiciona todas as mudanças (novas, modificadas, removidas) |
| `git add -p` | Adiciona interativamente, por "pedaço" (hunk) de mudança |
| `git commit -m "mensagem"` | Grava um snapshot com o que está staged |
| `git commit -am "mensagem"` | Atalho: `add` de tudo que já é rastreado + `commit` |
| `git commit --amend` | Corrige o último commit (mensagem e/ou conteúdo) |
| `git restore --staged <arquivo>` | Tira um arquivo da staging area (sem perder a mudança) |
| `git restore <arquivo>` | Descarta mudanças não commitadas em um arquivo |

## Branches

| Comando | Para quê serve |
|---|---|
| `git branch` | Lista branches locais |
| `git branch <nome>` | Cria uma branch nova (sem trocar para ela) |
| `git switch <nome>` / `git checkout <nome>` | Troca para uma branch existente |
| `git switch -c <nome>` / `git checkout -b <nome>` | Cria e troca para uma branch nova |
| `git branch -d <nome>` | Apaga uma branch já mesclada |
| `git branch -D <nome>` | Força apagar uma branch (mesmo não mesclada) |
| `git branch -m <novo-nome>` | Renomeia a branch atual |

## Integrando mudanças

| Comando | Para quê serve |
|---|---|
| `git merge <branch>` | Junta outra branch na branch atual |
| `git rebase <branch>` | Reaplica os commits da branch atual em cima de outra |
| `git pull` | `fetch` + `merge` (ou `rebase`, conforme config) da branch remota correspondente |
| `git pull --rebase` | Igual, mas integrando via rebase em vez de merge |
| `git push` | Envia commits locais da branch atual para o remote |
| `git push -u origin <branch>` | Envia e já configura o tracking daquela branch com o remote |

## Desfazendo coisas

| Comando | Para quê serve |
|---|---|
| `git stash` | Guarda mudanças não commitadas de lado, temporariamente |
| `git stash pop` | Aplica e remove o último stash guardado |
| `git reset --soft <commit>` | Move a branch para outro commit, mantendo mudanças staged |
| `git reset --mixed <commit>` | (padrão) Move a branch, mudanças voltam para working tree, não staged |
| `git reset --hard <commit>` | Move a branch e **descarta** mudanças na working tree/staging |
| `git revert <commit>` | Cria um novo commit que desfaz outro, **sem** reescrever histórico |
| `git clean -fd` | Remove arquivos e pastas não rastreados (não versionados) |

## Remotos

| Comando | Para quê serve |
|---|---|
| `git remote -v` | Lista os remotes configurados e suas URLs |
| `git remote add <nome> <url>` | Adiciona um remote novo |
| `git fetch <remote>` | Baixa objetos/refs do remote, sem alterar a working tree |
| `git remote prune origin` | Remove referências locais de branches que não existem mais no remote |

## Tags

| Comando | Para quê serve |
|---|---|
| `git tag` | Lista tags |
| `git tag <nome>` | Cria uma tag leve no commit atual |
| `git tag -a <nome> -m "msg"` | Cria uma tag anotada (com metadados) |
| `git push origin <tag>` | Envia uma tag específica para o remote |
| `git push --tags` | Envia todas as tags locais para o remote |

## Dica: aliases úteis

```bash
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.lg "log --oneline --graph --all --decorate"
```
