# comand-novo-projeto

Kit pessoal para o Claude Code: gera projetos novos a partir de dois
templates (`harness-lite`/`harness-full`) e traz automações que valem em
**qualquer** projeto — versionamento Git automático, registro automático de
pesquisas e uma árvore de commits sempre atualizada.

> **Este repositório não é "Use this template"** — ele precisa ser
> **clonado** num caminho fixo, porque o comando `/claude:novo-projeto` lê os
> templates de dentro do próprio clone. (Os templates em si, sim, podem virar
> repositórios "Use this template" separados no GitHub — ver
> [`templates/harness-lite/README.md`](templates/harness-lite/README.md) e
> [`templates/harness-full/README.md`](templates/harness-full/README.md).)

## Clone e instalação

Clone exatamente neste caminho (é onde `/claude:novo-projeto` espera
encontrar o repositório):

```bash
git clone https://github.com/DadosCoelho/comand-novo-projeto.git \
  ~/Documents/GitHub/comand-novo-projeto
bash ~/Documents/GitHub/comand-novo-projeto/.claude/scripts/install-global.sh
```

No Windows/PowerShell:

```powershell
git clone https://github.com/DadosCoelho/comand-novo-projeto.git `
  "$env:USERPROFILE\Documents\GitHub\comand-novo-projeto"
powershell -File "$env:USERPROFILE\Documents\GitHub\comand-novo-projeto\.claude\scripts\install-global.ps1"
```

O `install-global` copia as skills (`git-workflow`, `pesquisa-workflow`) e os
comandos (`/claude:novo-projeto`, `/claude:pesquisa`) para `~/.claude/` — daí
em diante eles valem em **qualquer** projeto na máquina, não só neste
repositório. Detalhes, flags (`--force`/`-Force`) e o que o script faz por
baixo: [`.claude/README.md`](.claude/README.md).

## Uso

Depois de instalado, dentro de qualquer sessão do Claude Code:

```
/claude:novo-projeto lite <nome-do-projeto>   # scaffold minimo
/claude:novo-projeto full <nome-do-projeto>   # scaffold com PRD -> tasks -> dev
```

Isso cria `%USERPROFILE%\Documents\GitHub\<nome-do-projeto>` com um
repositório Git novo e limpo (sem o histórico deste repo), a partir do
template escolhido — e pergunta se você quer habilitar, só naquele projeto,
o checkpoint automático de commits e o registro automático de pesquisas.

## O que tem aqui

```
CLAUDE.md                 # convenções deste repositório
.claude/
├── arvore-de-commits.md    # diagrama Mermaid do historico REAL deste repo
├── README.md                # detalhes de cada skill/comando + instalação global
├── commands/claude/
│   ├── learning.md          # /claude:learning
│   ├── manual-verify.md     # /claude:manual-verify
│   ├── pesquisa.md          # /claude:pesquisa — pesquisa um tema, registra em pesquisa/
│   └── novo-projeto.md      # /claude:novo-projeto — gera projeto novo a partir de um template
├── skills/
│   ├── git-workflow/         # conhecimento pratico de Git + auto-versionamento
│   └── pesquisa-workflow/     # registro automatico de pesquisas (opt-in via pesquisa/)
└── scripts/
    ├── install-global.ps1 / .sh    # instala skills+comandos em ~/.claude/
    └── arvore-de-commits.ps1 / .sh # gera .claude/arvore-de-commits.md
ai-docs/
└── lessons.md             # licoes registradas por /claude:learning
pesquisa/
└── *.md                    # pesquisa organizada sobre Git (conceitos, comandos, fluxos...)
templates/                  # os dois templates que /claude:novo-projeto copia
├── harness-lite/            # minimo: CLAUDE.md + 3 comandos
└── harness-full/            # PRD -> /claude:create-tasks -> /claude:dev, com agentes e auditoria
```

## Documentação

- [`.claude/README.md`](.claude/README.md) — o que cada skill/comando faz,
  como instalar globalmente numa máquina nova, e como funciona a árvore de
  commits ao vivo.
- [`pesquisa/`](pesquisa/) — pesquisa completa sobre Git (conceitos,
  internals, comandos, workflows, boas práticas) que fundamenta a skill
  `git-workflow`.
- [`templates/harness-lite/README.md`](templates/harness-lite/README.md) e
  [`templates/harness-full/README.md`](templates/harness-full/README.md) —
  documentação de cada template, do ponto de vista de quem recebe um projeto
  gerado a partir dele (ou clona o template direto do GitHub).

## Comandos

| Comando | O que faz |
|---|---|
| `/claude:novo-projeto lite\|full <nome>` | Cria um projeto novo em `~/Documents/GitHub/<nome>` a partir de um template, com repositório Git limpo. |
| `/claude:pesquisa [tema]` | Pesquisa um tema e registra uma nota em `pesquisa/<slug>.md`, atualizando o índice. Primeira execução cria a pasta. |
| `/claude:learning [descrição]` | Registra uma lição em `ai-docs/lessons.md`. |
| `/claude:manual-verify [pedido]` | Roda uma verificação livre que você descrever e relata o que precisa de ação humana. |
