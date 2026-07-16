# Comandos avançados

## `git rebase -i` (rebase interativo)

Permite reescrever uma sequência de commits antes de integrá-los: reordenar,
reescrever mensagens, juntar (`squash`/`fixup`), dividir, ou remover commits
inteiros.

```bash
git rebase -i HEAD~5      # reescreve os últimos 5 commits
git rebase -i main         # reaplica os commits da branch atual sobre 'main'
```

No editor que abre, cada linha é um commit com uma ação:

```
pick   1a2b3c4  primeiro commit
squash 5d6e7f8  junta este no commit anterior
reword 9a0b1c2  mantém o commit, mas edita a mensagem
drop   3d4e5f6  remove esse commit inteiramente
```

**Regra de ouro**: nunca reescrever (rebase, amend, force-push) commits que
já foram publicados em uma branch compartilhada e que outras pessoas já
possam ter baseado trabalho em cima — isso muda os hashes dos commits e
gera conflitos/duplicações para quem já puxou a versão antiga.

## `git reflog`

Log local (não sincronizado, específico da máquina) de todo lugar para onde
HEAD e as branches já apontaram — inclusive commits "perdidos" após um
`reset --hard` malfeito ou um rebase que deu errado. É a rede de segurança
para recuperar trabalho:

```bash
git reflog                      # lista o histórico de movimentos do HEAD
git reset --hard HEAD@{2}       # volta para o estado de 2 movimentos atrás
```

## `git bisect`

Busca binária automatizada no histórico para achar qual commit introduziu
um bug, dado um commit "bom" conhecido e um "ruim" (geralmente o atual):

```bash
git bisect start
git bisect bad                 # o commit atual está com o bug
git bisect good v1.2.0          # essa versão antiga estava OK
# o Git faz checkout de um commit no meio; você testa e responde:
git bisect good   # ou
git bisect bad
# repete até o Git apontar o commit exato culpado
git bisect reset               # volta para a branch original
```

Pode ser automatizado passando um script/comando que retorna código de saída
0 (bom) ou diferente de 0 (ruim): `git bisect run ./test.sh`.

## `git cherry-pick`

Aplica um commit específico (por hash) de outra branch na branch atual, sem
trazer o restante do histórico dela — útil para levar um fix pontual para
outra linha de desenvolvimento (ex.: um hotfix que precisa ir também para
uma branch de release antiga).

```bash
git cherry-pick <hash>
git cherry-pick <hash1> <hash2>    # vários commits
git cherry-pick -n <hash>           # aplica sem commitar (para revisar antes)
```

## `git worktree`

Permite ter **múltiplas working trees** (pastas de trabalho) ligadas ao
mesmo repositório `.git`, cada uma podendo estar em uma branch diferente —
sem precisar clonar o repositório de novo nem fazer stash/checkout toda hora
para alternar de contexto:

```bash
git worktree add ../hotfix-branch hotfix/urgent-fix
# agora ../hotfix-branch é uma pasta independente, na branch hotfix/urgent-fix,
# compartilhando o mesmo histórico/objetos do repo original

git worktree list
git worktree remove ../hotfix-branch
```

## Submodules e alternativas

**Submodules** (`git submodule`) permitem embutir um repositório Git dentro
de outro, fixando um commit específico do repositório embutido:

```bash
git submodule add <url> caminho/da/pasta
git submodule update --init --recursive   # ao clonar um repo que já tem submodules
```

São notoriamente confusos de operar corretamente (fácil esquecer de
atualizar o ponteiro, ou de rodar `--init` ao clonar). Alternativas comuns
em times modernos: **monorepo** (tudo em um repositório só) ou gerenciador
de pacotes/dependências específico da linguagem em vez de submodules.

## Hooks

Scripts que o Git executa automaticamente em determinados eventos, ficam em
`.git/hooks/` (não versionados por padrão — cada clone precisa configurá-los
de novo, a menos que se use uma ferramenta como **Husky**, no ecossistema
Node, para versionar hooks via `package.json`). Alguns hooks comuns:

| Hook | Quando dispara |
|---|---|
| `pre-commit` | Antes de finalizar um commit — comum para lint/formatação |
| `commit-msg` | Para validar/ajustar a mensagem de commit |
| `pre-push` | Antes de um `git push` — comum para rodar testes |
| `post-checkout` | Depois de um checkout/switch de branch |

## Removendo dados sensíveis do histórico

Simplesmente apagar um arquivo em um novo commit **não** remove ele do
histórico — quem tiver o repo ainda consegue achar o conteúdo em commits
antigos. Para remover de verdade (reescrevendo todo o histórico):

```bash
# ferramenta recomendada atualmente pela documentação oficial do Git:
git filter-repo --path caminho/do/arquivo-secreto --invert-paths

# alternativa histórica, mais lenta, mas sem instalar nada externo:
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch caminho/do/arquivo-secreto" \
  --prune-empty --tag-name-filter cat -- --all
```

Depois disso é obrigatório um `push --force` (reescreve o remoto) e,
crucialmente, **trocar a credencial vazada** — ela já pode ter sido copiada,
indexada ou usada antes da limpeza.

## `git gc` e manutenção

```bash
git gc                 # compacta objetos soltos em packfiles, limpa objetos órfãos antigos
git fsck                # verifica integridade do banco de dados de objetos
git count-objects -v    # mostra quantos objetos soltos existem e o espaço usado
```

O Git roda uma forma leve de `gc` automaticamente em vários comandos; rodar
manualmente é útil em repositórios muito grandes ou após operações pesadas
de reescrita de histórico.
