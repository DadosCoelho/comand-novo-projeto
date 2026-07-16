# Introdução e história

## O que é Git

Git é um **sistema de controle de versão distribuído (DVCS — Distributed
Version Control System)**. Ele rastreia mudanças em arquivos ao longo do
tempo, permitindo voltar a estados anteriores, comparar versões, trabalhar em
paralelo com outras pessoas e reconciliar mudanças concorrentes.

## História

- Criado por **Linus Torvalds** em **2005**, para o desenvolvimento do
  **kernel Linux**.
- O motivo direto: a equipe do kernel usava a ferramenta proprietária
  **BitKeeper**, e perdeu o acesso gratuito a ela após uma disputa sobre
  engenharia reversa de um dos colaboradores da comunidade.
- Torvalds levou cerca de duas semanas para escrever a primeira versão
  funcional do Git, com objetivos bem específicos:
  - **Velocidade** (operações locais devem ser quase instantâneas).
  - **Design simples**, porém robusto para histórico não-linear (milhares de
    branches paralelas, como no kernel).
  - **Totalmente distribuído** — sem dependência de um servidor central.
  - **Capacidade de lidar com projetos grandes** (como o próprio kernel)
    com eficiência.
- O nome "git" é gíria britânica pejorativa (algo como "idiota" / "infeliz").
  O próprio Torvalds brincou dizendo que segue a tradição de nomear projetos
  seus com o próprio nome (piada com "ego"), mas o termo pegou por ser curto,
  fácil de digitar e disponível como comando único no shell.
- Hoje o Git é mantido por uma comunidade ampla (não só Torvalds — o
  mantenedor atual do projeto principal é **Junio Hamano**) e é, disparado,
  o sistema de controle de versão mais usado do mundo, servindo de base para
  plataformas como **GitHub**, **GitLab**, **Bitbucket** e **Azure DevOps**.

## Distribuído vs. Centralizado

Sistemas antigos como **CVS** e **Subversion (SVN)** são **centralizados**:
existe um único servidor com o histórico completo, e os clientes baixam
apenas o snapshot da versão atual (ou um subconjunto do histórico). Toda
operação que precisa de histórico (`log`, `diff` entre revisões antigas,
`commit`) depende de rede.

No Git (e em outros DVCS como Mercurial), **cada cópia local é um
repositório completo**: todo o histórico, todas as branches e tags. Isso
traz consequências práticas importantes:

- Dá para trabalhar **totalmente offline** — commitar, criar branches, ver
  histórico, comparar versões — e sincronizar depois.
- **Não existe um único ponto de falha**: se o servidor remoto (ex.:
  GitHub) cair ou for perdido, qualquer clone local tem o histórico
  completo e pode virar o novo "servidor".
- **Performance**: a maioria das operações (commit, log, diff, branch) é
  local e portanto muito rápida.
- Cada desenvolvedor pode ter seu próprio fluxo de branches locais sem
  "sujar" o repositório de ninguém até decidir compartilhar (`push`).

## Por que Git "venceu"

Alguns fatores que explicam a adoção massiva do Git em relação a
concorrentes (Mercurial, SVN, Perforce, ClearCase):

- Modelo de branching **extremamente leve e rápido** (branch no Git é só um
  ponteiro de 41 bytes para um commit, não uma cópia de arquivos).
- Efeito de rede do **GitHub** a partir de 2008, que popularizou o fluxo de
  Pull Request e virou o padrão de facto para colaboração open source.
- Ferramentas maduras de terceiros (GUIs, integrações de CI/CD, IDEs).
- Curva de aprendizado inicialmente mais dura que a de concorrentes, mas
  compensada pela flexibilidade e pela adoção do mercado — hoje é
  praticamente unânime nas vagas de desenvolvimento.
