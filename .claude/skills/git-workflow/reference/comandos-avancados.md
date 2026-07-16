# Comandos avançados

## `git rebase -i` (rebase interativo)

Reordenar, reescrever mensagens, juntar (`squash`/`fixup`) ou remover
commits — **só em branches locais/não publicadas** (ver regra de nunca
reescrever histórico já enviado a um remote sem autorização).

```bash
git rebase -i HEAD~5      # reescreve os últimos 5 commits
git rebase -i main         # reaplica os commits da branch atual sobre 'main'
```

## `git reflog` — a rede de segurança

Log local de todo lugar para onde HEAD/branches já apontaram — permite
recuperar commits "perdidos" após `reset --hard` malfeito, rebase que deu
errado, ou checkout de detached HEAD:

```bash
git reflog
git reset --hard HEAD@{2}   # volta para o estado de 2 movimentos atrás
```

## `git bisect` — achar o commit que quebrou algo

```bash
git bisect start
git bisect bad                 # commit atual está com o bug
git bisect good v1.2.0          # essa versão antiga estava OK
# testa o commit que o Git faz checkout, responde:
git bisect good   # ou
git bisect bad
# repete até achar o culpado, depois:
git bisect reset
```

Automatizável: `git bisect run ./test.sh` (script retorna 0 = bom).

## `git cherry-pick`

Aplica um commit específico de outra branch na atual, sem trazer o resto
do histórico dela:

```bash
git cherry-pick <hash>
git cherry-pick -n <hash>   # aplica sem commitar, para revisar antes
```

## `git worktree` — múltiplas pastas, um repositório

```bash
git worktree add ../hotfix-branch hotfix/urgent-fix
git worktree list
git worktree remove ../hotfix-branch
```

## Hooks locais do Git (`.git/hooks/`)

Scripts disparados em eventos do próprio Git (diferente dos hooks do
Claude Code): `pre-commit` (lint/formatação), `commit-msg` (validar
mensagem), `pre-push` (rodar testes). Não versionados por padrão — usar
**Husky** (Node) se o time quiser compartilhá-los via `package.json`.

## Removendo dados sensíveis do histórico

Apagar um arquivo em um commit novo **não** remove do histórico. Para
limpar de verdade:

```bash
git filter-repo --path caminho/do/arquivo-secreto --invert-paths
```

Depois: `push --force` (reescreve o remoto, **sempre com autorização
explícita**) e, mais importante, **trocar a credencial vazada** — ela já
pode ter sido copiada antes da limpeza.

## Manutenção

```bash
git gc                  # compacta objetos soltos em packfiles
git fsck                 # verifica integridade do banco de dados de objetos
```
