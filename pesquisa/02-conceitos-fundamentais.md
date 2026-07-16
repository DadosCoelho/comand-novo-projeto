# Conceitos fundamentais

## Repositório (repo)

A pasta de um projeto rastreada pelo Git. Criada com `git init` ou obtida
via `git clone`. Todo o estado do controle de versão — histórico, branches,
tags, configuração — fica dentro da subpasta oculta `.git/`; o restante da
pasta é a **working tree** (os arquivos "de verdade" que você edita).

## Os três estados de um arquivo

Todo arquivo rastreado pelo Git passa por três áreas conceituais:

```
Working Tree  --git add-->  Staging Area (Index)  --git commit-->  Repository (.git)
  (modificado)                  (staged)                        (commitado/histórico)
```

- **Working tree** — os arquivos no disco, como você os edita normalmente.
- **Staging area / index** — uma área intermediária onde você marca
  exatamente quais mudanças (mesmo que sejam só partes de um arquivo, via
  `git add -p`) farão parte do próximo commit.
- **Repository** — o histórico permanente, guardado como objetos dentro de
  `.git/objects` (ver [internals](03-internals.md)).

Essa separação em três estados é uma das características mais distintivas
do Git frente a outros VCS: permite compor um commit com precisão, mesmo
que a working tree tenha mudanças que você não quer incluir ainda.

## Commit

Um "snapshot" do estado dos arquivos staged em um momento específico.
Cada commit tem:

- Um **hash** único (SHA-1 tradicionalmente, SHA-256 em repositórios mais
  novos que optam por esse modo) que identifica seu conteúdo e histórico.
- **Autor** e **committer** (podem ser diferentes — ex.: em rebase/cherry-pick
  aplicado por outra pessoa), cada um com nome, e-mail e timestamp.
- Uma **mensagem** descrevendo a mudança.
- Um ponteiro para o(s) **commit(s) pai(s)** — um único pai no caso comum,
  dois ou mais em merges, nenhum no commit raiz do repositório.
- Um ponteiro para a **árvore (tree)** representando o estado completo dos
  arquivos naquele momento.

Importante: um commit no Git não é um "diff" — é uma referência para uma
árvore completa de arquivos. O Git calcula diffs sob demanda comparando
árvores, mas armazena (com deduplicação/compressão via packfiles) o
conteúdo completo referenciado por cada commit.

## Branch

Um **ponteiro móvel e leve** para um commit — literalmente um arquivo de 41
bytes (o hash) dentro de `.git/refs/heads/`. Criar uma branch é uma
operação praticamente instantânea, porque não copia arquivos: apenas cria
um novo ponteiro.

Ao commitar estando em uma branch, o ponteiro daquela branch avança
automaticamente para apontar ao novo commit.

- `main` (ou historicamente `master`) costuma ser a branch principal.
- Branches podem ser **locais** (só na sua máquina) ou **remotas**
  (referências ao estado de branches em um remote, ex.:
  `origin/main`, atualizadas via `git fetch`).

## HEAD

Ponteiro especial que indica **onde você está agora**. Normalmente HEAD
aponta para uma branch (ex.: `refs/heads/main`), e a branch aponta para um
commit — HEAD é então "simbólico". Quando você faz checkout direto de um
commit (sem branch), fica em **detached HEAD**: HEAD aponta diretamente
para o commit, e novos commits feitos nesse estado não pertencem a nenhuma
branch (podem ser "perdidos" se você trocar de branch sem criar uma nova
referência para eles — embora o `reflog` normalmente permita recuperá-los).

## Remote

Uma referência nomeada para outro repositório Git, geralmente
`origin` (nome convencional para o remote de onde você clonou). Um
repositório pode ter múltiplos remotes (ex.: `origin` e `upstream`, comum
em fluxos de fork). Comandos que envolvem remotes:

- `git fetch <remote>` — baixa objetos e atualiza as referências remotas
  (`origin/main`, etc.) **sem** tocar na sua working tree ou branches
  locais.
- `git pull` — equivale a `git fetch` + `git merge` (ou `rebase`, conforme
  configuração) da branch remota correspondente na sua branch atual.
- `git push` — envia commits locais para atualizar uma branch no remote.

## Tag

Um ponteiro **fixo** (ao contrário da branch, não se move) para um commit
específico — tipicamente usado para marcar releases (`v1.0.0`). Pode ser:

- **Lightweight** — só um nome apontando para um commit, sem metadados
  extra.
- **Annotated** — um objeto próprio no banco de dados do Git, com autor,
  data, mensagem e opcionalmente assinatura GPG (`git tag -s`).

## Working tree vs. worktree (atenção à ambiguidade do termo)

"Working tree" no sentido genérico é qualquer cópia de trabalho dos
arquivos. Já `git worktree` é um comando específico que permite ter
**múltiplas working trees simultâneas** ligadas ao mesmo repositório
`.git`, cada uma em uma pasta diferente e possivelmente em uma branch
diferente — útil para trabalhar em duas branches ao mesmo tempo sem
precisar clonar o repositório de novo (ver [comandos avançados](05-comandos-avancados.md)).
