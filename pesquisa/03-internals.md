# Internals — como o Git funciona por dentro

Entender o modelo de dados interno do Git ajuda a tirar o "medo" de comandos
como `reset`, `rebase` e `reflog` — no fundo, tudo é manipulação de objetos
imutáveis e ponteiros.

## O banco de dados de objetos (`.git/objects`)

O Git é, na essência, um **banco de dados de objetos endereçados por
conteúdo** (content-addressable). Todo objeto é identificado pelo hash
SHA-1 (40 caracteres hex) do seu conteúdo — dois conteúdos idênticos geram
sempre o mesmo hash, o que naturalmente deduplica dados.

Existem quatro tipos de objeto:

| Tipo | O que representa |
|---|---|
| **blob** | O conteúdo bruto de um arquivo (sem nome, sem metadados — só bytes) |
| **tree** | Um "diretório": lista de entradas (nome, modo, hash) apontando para blobs ou outras trees |
| **commit** | Metadados (autor, data, mensagem, pai(s)) + ponteiro para uma tree raiz |
| **tag** | (annotated tag) metadados apontando para outro objeto, geralmente um commit |

Ou seja: um commit não guarda "um diff" — ele aponta para uma **tree**
completa que, por sua vez, aponta para blobs e sub-trees, representando o
estado inteiro do projeto naquele momento. O Git calcula diffs comparando
duas trees sob demanda; não os armazena diretamente.

Fisicamente, cada objeto solto é gravado em
`.git/objects/xx/yyyy...` (os 2 primeiros caracteres do hash viram a
subpasta), comprimido com zlib. Repositórios maduros compactam objetos em
**packfiles** (`.git/objects/pack/*.pack`) via `git gc`, armazenando deltas
entre objetos semelhantes para economizar espaço.

## Referências (refs)

Ponteiros nomeados para commits, guardados como arquivos texto simples
(ou, em repositórios grandes, agregados em `packed-refs` por performance):

- `.git/refs/heads/<branch>` — branches locais.
- `.git/refs/remotes/<remote>/<branch>` — branches de tracking remoto.
- `.git/refs/tags/<tag>` — tags.
- `.git/HEAD` — geralmente contém `ref: refs/heads/main`, isto é, um
  ponteiro simbólico para a branch atual.

## `.git/index`

O arquivo binário que representa a **staging area**. Quando você roda
`git add`, o Git calcula o blob do conteúdo e atualiza esse índice para
apontar para ele; `git commit` gera uma tree a partir do índice atual.

## Reflog

O Git mantém um **log local de para onde HEAD e as branches apontaram** ao
longo do tempo (`.git/logs/`), independente do histórico de commits
"oficial". Isso é o que permite recuperar commits "perdidos" depois de um
`reset --hard`, um rebase malfeito ou um checkout de detached HEAD — desde
que o objeto ainda não tenha sido coletado pelo garbage collector
(`git gc`, que por padrão só remove objetos órfãos com mais de ~90 dias).
Comando: `git reflog`.

## SHA-1 vs. SHA-256

Historicamente o Git usa **SHA-1** para os hashes de objeto. Por SHA-1 ter
fraquezas criptográficas conhecidas (ataques de colisão demonstrados, ex.:
"SHAttered", 2017), o Git suporta desde 2020 um modo experimental de
repositório usando **SHA-256** (`git init --object-format=sha256`). Na
prática, a esmagadora maioria dos repositórios em uso (incluindo GitHub,
GitLab) ainda usa SHA-1 — a migração é opcional, não é o padrão, e não é
diretamente compatível/interoperável entre os dois formatos ainda. O
próprio Git mitiga colisões de SHA-1 usando uma variante reforçada
(`SHA-1DC`, "hardened SHA-1") que detecta tentativas de colisão conhecidas.

## Plumbing vs. Porcelain

O Git distingue dois níveis de comando:

- **Porcelain** — comandos de alto nível, para uso humano no dia a dia:
  `git commit`, `git status`, `git merge`, `git log`, etc.
- **Plumbing** — comandos de baixo nível, que manipulam diretamente os
  objetos internos: `git hash-object`, `git cat-file`, `git write-tree`,
  `git commit-tree`, `git update-ref`, `git rev-parse`. Úteis para
  entender internals, depurar situações estranhas ou escrever scripts/
  ferramentas que integram com o Git.

Exemplo prático de plumbing para "ver por dentro" um commit:

```bash
git cat-file -p HEAD          # mostra o objeto commit: tree, parent, author, message
git cat-file -p HEAD^{tree}   # mostra a tree raiz daquele commit
git cat-file -t <hash>        # mostra o tipo de um objeto (blob/tree/commit/tag)
```

## Estrutura típica de `.git/`

```
.git/
├── HEAD              # ponteiro simbólico para a branch atual
├── config             # configuração local do repositório
├── description         # usado apenas por GitWeb
├── hooks/              # scripts disparados em eventos (pre-commit, pre-push...)
├── index               # staging area
├── logs/                # reflog
│   ├── HEAD
│   └── refs/
├── objects/             # banco de dados de objetos (blobs, trees, commits, tags)
│   ├── pack/            # objetos compactados em packfiles
│   └── xx/               # objetos "soltos"
└── refs/
    ├── heads/            # branches locais
    ├── remotes/           # branches de tracking remoto
    └── tags/               # tags
```

## Configuração em camadas

O Git lê configuração em três (ou quatro) níveis, do mais geral ao mais
específico, cada um sobrescrevendo o anterior:

1. `/etc/gitconfig` (ou equivalente) — **system**, vale para todos os
   usuários da máquina (`git config --system`).
2. `~/.gitconfig` ou `~/.config/git/config` — **global**, vale para o
   usuário atual em todos os repositórios (`git config --global`).
3. `.git/config` dentro do repositório — **local**, vale só para aquele
   repositório (`git config --local`, o padrão quando não se passa flag).
4. Opcionalmente, `.git/config.worktree` — por worktree, se
   `extensions.worktreeConfig` estiver habilitado.
