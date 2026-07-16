# Git vs. GitHub / GitLab / Bitbucket

Uma confusão comum, especialmente para quem está começando: **Git** e
**GitHub** não são a mesma coisa.

## Git é a ferramenta

Git é um programa de controle de versão que roda **localmente**, via linha
de comando (ou GUI), instalado na sua máquina. Ele não depende de nenhum
serviço online para funcionar — dá para usar Git por anos, em projetos
pessoais, sem nunca criar uma conta em nenhuma plataforma.

## GitHub, GitLab, Bitbucket, Azure DevOps são plataformas/serviços

São produtos comerciais (ou gratuitos com camada paga) que **hospedam
repositórios Git na nuvem** e adicionam uma camada enorme de funcionalidade
em volta do Git puro:

- **Pull Requests / Merge Requests** — interface para propor, revisar e
  discutir mudanças antes de integrar (o próprio conceito de "PR" não
  existe no Git em si — é uma convenção dessas plataformas).
- **Issues** — rastreamento de bugs/tarefas.
- **CI/CD** — pipelines automatizados (GitHub Actions, GitLab CI, Bitbucket
  Pipelines).
- **Wikis, Projects/Kanban boards, Releases, Packages/Registry**.
- **Gestão de permissões e times**, proteção de branch (bloquear push
  direto em `main`, exigir revisão aprovada, exigir CI verde antes de
  mesclar).
- **Hospedagem e descoberta** de projetos open source (o efeito de rede do
  GitHub em particular foi decisivo para popularizar contribuição open
  source via fork + PR).

## Comunicação com o remoto: sempre via protocolo Git

Independente da plataforma, a comunicação entre o Git local e o
repositório remoto acontece por protocolos padrão do próprio Git:

- **HTTPS** — `https://github.com/usuario/repo.git`, autenticação via
  usuário/token (ou credential manager).
- **SSH** — `git@github.com:usuario/repo.git`, autenticação via par de
  chaves pública/privada.

Ou seja, tecnicamente é possível hospedar um repositório Git **sem
nenhuma dessas plataformas** — por exemplo, um servidor próprio acessível
via SSH (`git init --bare` em um servidor, e colegas fazem
`git clone usuario@servidor:/caminho/repo.git`), ou até compartilhar via
sistema de arquivos local/rede. As plataformas existem para tornar isso
muito mais fácil e agregar as funcionalidades de colaboração acima.

## Resumo

| | Git | GitHub / GitLab / Bitbucket |
|---|---|---|
| O que é | Ferramenta de controle de versão | Plataforma/serviço de hospedagem + colaboração |
| Onde roda | Localmente, na sua máquina | Na nuvem (ou self-hosted, no caso do GitLab/Bitbucket) |
| Depende do outro? | Não — funciona 100% offline/local | Sim — por baixo, usam Git para versionamento |
| Dono/mantenedor | Comunidade open source (Software Freedom Conservancy) | Empresas (Microsoft/GitHub, GitLab Inc., Atlassian/Bitbucket) |
| Conceitos que adiciona | — | Pull Request, Issues, CI/CD, Wiki, permissões de time |
