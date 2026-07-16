# Pesquisa: Git

## O que é

Git é um **sistema de controle de versão distribuído (DVCS)**, criado por Linus
Torvalds em 2005 para o desenvolvimento do kernel Linux, depois que a equipe
perdeu o acesso gratuito à ferramenta proprietária BitKeeper. Hoje é o sistema
de controle de versão mais usado do mundo, base de plataformas como GitHub,
GitLab e Bitbucket.

Diferente de sistemas centralizados (como o antigo SVN/CVS), no Git **cada
cópia local do repositório é completa** — histórico inteiro, branches, tags —
o que permite trabalhar offline, fazer commits locais e só sincronizar com o
servidor remoto quando quiser.

## Conceitos fundamentais

- **Repositório (repo)** — a pasta do projeto rastreada pelo Git, com seu
  histórico guardado em `.git/`.
- **Commit** — um "snapshot" do estado dos arquivos em um momento, com hash
  SHA-1 (ou SHA-256, em repos mais novos) único, autor, data e mensagem.
- **Branch** — um ponteiro móvel para um commit; permite trabalhar em linhas
  de desenvolvimento paralelas sem afetar a principal (`main`/`master`).
- **HEAD** — ponteiro para o commit/branch em que você está "no momento".
- **Working tree / staging area (index) / repository** — os três estados de um
  arquivo: modificado no disco → adicionado ao stage (`git add`) → commitado
  (`git commit`).
- **Remote** — uma referência a outro repositório (geralmente `origin`), usado
  para `push`/`pull`/`fetch`.
- **Merge vs Rebase** — duas formas de integrar mudanças de uma branch em
  outra. Merge cria um commit de junção preservando o histórico real; rebase
  reescreve os commits da branch para "reaplicá-los" em cima de outro ponto,
  gerando histórico linear (mas alterando hashes — cuidado em branches
  compartilhadas).

## Comandos essenciais do dia a dia

| Comando | Para quê serve |
|---|---|
| `git init` | Cria um repositório novo na pasta atual |
| `git clone <url>` | Copia um repositório remoto para a máquina local |
| `git status` | Mostra o que mudou, o que está staged, branch atual |
| `git add <arquivo>` / `git add -A` | Move mudanças para a staging area |
| `git commit -m "msg"` | Grava um snapshot com as mudanças staged |
| `git log` / `git log --oneline --graph` | Histórico de commits |
| `git diff` | Diferenças entre working tree e staging (ou entre commits) |
| `git branch` | Lista/cria branches |
| `git checkout -b <nome>` / `git switch -c <nome>` | Cria e troca para uma branch nova |
| `git merge <branch>` | Junta outra branch na atual |
| `git rebase <branch>` | Reaplica commits da atual em cima de outra branch |
| `git pull` | `fetch` + `merge` (ou `rebase`, conforme config) do remoto |
| `git push` | Envia commits locais para o remoto |
| `git stash` | Guarda mudanças não commitadas de lado temporariamente |
| `git reset` | Move HEAD/branch para outro commit (soft/mixed/hard) |
| `git revert <commit>` | Cria um novo commit que desfaz outro, sem reescrever histórico |
| `git cherry-pick <commit>` | Aplica um commit específico de outra branch na atual |
| `git tag` | Marca um commit específico (ex.: versões de release) |
| `git blame <arquivo>` | Mostra quem mudou cada linha e em qual commit |
| `git bisect` | Busca binária no histórico para achar o commit que introduziu um bug |

## Fluxos de trabalho (workflows) comuns

- **Feature Branch Workflow** — cada funcionalidade/bug em uma branch própria,
  integrada via Pull Request/Merge Request. É o mais comum hoje em times que
  usam GitHub/GitLab.
- **Git Flow** — modelo mais formal com branches fixas (`main`, `develop`,
  `feature/*`, `release/*`, `hotfix/*`). Bom para releases versionadas e
  ciclos de entrega mais lentos; considerado pesado demais para times que
  fazem deploy contínuo.
- **Trunk-Based Development** — todo mundo commita direto (ou via branches
  muito curtas) numa branch única (`trunk`/`main`), com integração contínua e
  feature flags para esconder trabalho incompleto. Favorece CI/CD rápido.
- **Forking Workflow** — comum em projetos open source: cada colaborador tem
  seu próprio fork do repositório e propõe mudanças via PR entre forks.

## Boas práticas

- **Commits pequenos e atômicos** — cada commit deve representar uma mudança
  lógica coesa, facilitando revert, bisect e revisão.
- **Mensagens de commit descritivas** — convenção comum: linha de resumo curta
  (~50 caracteres) + linha em branco + corpo explicando o *porquê*. Padrões
  como [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`,
  `fix:`, `chore:`, `refactor:`...) ajudam a gerar changelogs automáticos.
- **Nunca commitar segredos** (chaves de API, senhas, `.env`) — usar
  `.gitignore` e, se vazar, trocar a credencial e limpar o histórico (ex.:
  `git filter-repo` ou BFG Repo-Cleaner), já que só remover em um commit novo
  não apaga do histórico.
- **Evitar `git push --force` em branches compartilhadas** — reescreve
  histórico remoto e pode sobrescrever trabalho de outras pessoas; preferir
  `--force-with-lease` quando realmente necessário.
- **Pull Requests com revisão** — mesmo em projetos pequenos, PRs dão um
  ponto de checagem antes de integrar código na branch principal.
- **`.gitignore` desde o início** — evita rastrear `node_modules`, builds,
  arquivos de IDE, etc.

## Git vs GitHub/GitLab/Bitbucket

Git é a **ferramenta** de controle de versão (roda localmente, via linha de
comando). GitHub, GitLab e Bitbucket são **plataformas/serviços** que hospedam
repositórios Git na nuvem e adicionam funcionalidades em volta: Pull Requests,
issues, CI/CD, wikis, gestão de permissões, etc. É possível usar Git
inteiramente sem nunca tocar nessas plataformas (ex.: servidor Git próprio via
SSH).

## Referências úteis

- Documentação oficial: https://git-scm.com/doc
- Livro gratuito *Pro Git* (Scott Chacon & Ben Straub): https://git-scm.com/book
- `git help <comando>` — manual embutido de qualquer subcomando
