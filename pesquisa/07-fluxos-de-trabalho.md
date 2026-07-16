# Fluxos de trabalho (workflows)

O Git em si não impõe um fluxo de trabalho — é uma ferramenta flexível o
suficiente para suportar vários modelos de colaboração. A escolha depende
do tamanho do time, da cadência de release e do quanto de processo formal
faz sentido.

## Feature Branch Workflow

O modelo mais comum hoje em times que usam GitHub/GitLab/Bitbucket:

- Cada funcionalidade, bugfix ou tarefa ganha sua própria branch, criada a
  partir de `main` (ex.: `feature/login-social`, `fix/crash-ao-salvar`).
- O trabalho é integrado de volta em `main` via **Pull Request / Merge
  Request**, com revisão de código antes de mesclar.
- `main` deve estar sempre em estado "deployável".
- Simples de entender e adotar, funciona bem com CI/CD.

## Git Flow

Modelo mais formal, proposto por Vincent Driessen em 2010, com branches de
papéis fixos:

- `main` (ou `master`) — sempre reflete o que está **em produção**.
- `develop` — branch de integração contínua do próximo release.
- `feature/*` — branches curtas, saem de `develop` e voltam para `develop`.
- `release/*` — quando `develop` está pronta para virar um release, cria-se
  essa branch para últimos ajustes/testes antes de ir para `main`.
- `hotfix/*` — correções urgentes direto a partir de `main`, mescladas de
  volta em `main` **e** em `develop`.

Vantagens: bom controle sobre versões, releases bem definidos, apropriado
para software com ciclos de lançamento espaçados (ex.: aplicativos
desktop, firmware). Desvantagens: considerado **pesado demais** para times
que fazem deploy contínuo (múltiplas vezes ao dia) — a quantidade de
branches e merges vira overhead sem benefício correspondente.

## Trunk-Based Development

Modelo favorecido por times de entrega contínua (e por referências como o
livro *Accelerate* e o relatório *DORA* como prática associada a alta
performance):

- Todo mundo integra direto (ou via branches muito curtas, de horas — não
  dias) em uma única branch principal (`trunk`/`main`).
- Trabalho incompleto ou arriscado fica escondido atrás de **feature
  flags**, em vez de isolado em uma branch separada por longo tempo.
- Evita o "merge hell" de branches de feature longas e divergentes.
- Exige disciplina de testes automatizados e CI robusto, já que qualquer
  commit em `main` pode ir para produção a qualquer momento.

## Forking Workflow

Padrão em projetos **open source**, onde os colaboradores não têm acesso de
escrita direto ao repositório original:

- Cada colaborador cria seu próprio **fork** (cópia completa do repositório
  sob sua conta).
- Trabalha em branches dentro do próprio fork.
- Propõe mudanças via **Pull Request entre repositórios** (do fork para o
  repositório original).
- Mantenedores do projeto original controlam totalmente o que entra,
  revisando cada PR — sem precisar dar permissão de escrita a ninguém de
  fora do time principal.
- Geralmente combinado com um remote `upstream` apontando para o
  repositório original, para manter o fork sincronizado:
  ```bash
  git remote add upstream <url-do-repo-original>
  git fetch upstream
  git merge upstream/main
  ```

## Qual escolher

- **Projeto pessoal/pequeno**: Feature Branch simples, sem cerimônia.
- **Time com deploy contínuo/CI maduro**: Trunk-Based (ou Feature Branch
  com branches bem curtas, o que na prática se aproxima de trunk-based).
- **Software com releases versionados e espaçados** (não-SaaS, ex.:
  bibliotecas, firmware, apps desktop): Git Flow ou uma variação
  simplificada dele.
- **Projeto open source com contribuidores externos**: Forking Workflow.

Muitos times acabam usando um **híbrido**: Feature Branch + PR como base,
com convenções emprestadas de Git Flow só para releases (ex.: tags de
versão, branch `release/*` ocasional para hotfix).
