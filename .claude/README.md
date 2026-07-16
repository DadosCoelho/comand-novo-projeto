# `.claude/` deste projeto — comandos + skills de automação

Esta pasta traz, além dos comandos padrão do template `harness-lite`
(`learning`, `manual-verify`), os itens específicos de workflow deste
repositório: versionamento Git automático e registro automático de
pesquisas.

```
.claude/
├── arvore-de-commits.md    # gerado por scripts/arvore-de-commits.* -- ver secao abaixo
├── commands/claude/
│   ├── learning.md          # /claude:learning (padrão do harness-lite)
│   ├── manual-verify.md     # /claude:manual-verify (padrão do harness-lite)
│   ├── pesquisa.md          # /claude:pesquisa — pesquisa um tema e registra em pesquisa/
│   └── novo-projeto.md      # /claude:novo-projeto — scaffold de projeto novo
├── skills/
│   ├── git-workflow/         # conhecimento prático de Git + regras de automação
│   │   ├── SKILL.md
│   │   └── reference/
│   │       ├── comandos-essenciais.md
│   │       ├── comandos-avancados.md
│   │       ├── branching-merge-fluxos.md
│   │       └── boas-praticas-seguranca.md
│   └── pesquisa-workflow/     # registro automático de pesquisas em pesquisa/
│       └── SKILL.md
└── scripts/
    ├── install-global.ps1 / .sh    # instala skills+comandos em ~/.claude/
    └── arvore-de-commits.ps1 / .sh # gera .claude/arvore-de-commits.md
templates/                     # os templates que /claude:novo-projeto copia
├── harness-lite/
│   └── .claude/scripts/arvore-de-commits.ps1 / .sh  # bundlado, sem install-global
└── harness-full/
    └── .claude/scripts/arvore-de-commits.ps1 / .sh  # idem
```

Como estão em `.claude/commands/` e `.claude/skills/` **deste repositório**,
qualquer pessoa que clonar/copiar este projeto e abrir com o Claude Code já
tem os dois disponíveis automaticamente, sem nenhum passo extra — mas o uso
mais comum é diferente: **promover os dois para o nível global** da sua
própria máquina (`~/.claude/`), para que valham em **todos** os projetos, não
só neste.

## O que cada um faz

### Skill `git-workflow`

Conhecimento prático de Git (comandos, merge/rebase, fluxos de trabalho,
boas práticas) **mais** um conjunto de regras de comportamento que o Claude
Code passa a seguir por padrão em qualquer repositório:

1. `git init` automático se o projeto ainda não for um repositório.
2. Branch nova por tarefa/feature substancial (`git switch -c tipo/slug`).
3. Commit local atômico ao final de cada tarefa concluída — sem precisar
   pedir.
4. `git push` / `pull` / `fetch` e qualquer ação que toque o GitHub/GitLab
   **só com autorização explícita na conversa**, mesmo que já autorizado
   antes na mesma sessão.
5. Nunca reescreve histórico já publicado (rebase/amend/force-push) sem
   confirmação.

Ver o conteúdo completo em [`skills/git-workflow/SKILL.md`](skills/git-workflow/SKILL.md).

### Skill `pesquisa-workflow`

Registro automático de pesquisas: sempre que concluo uma investigação não
trivial (múltiplas buscas/leituras sobre um tema) num projeto que já tem uma
pasta `pesquisa/` na raiz, salvo uma nota estruturada em
`pesquisa/<slug>.md` e atualizo um índice em `pesquisa/README.md`, sem
precisar que o usuário peça. **Opt-in por pasta:** se `pesquisa/` não
existir, não crio nada sozinho — a pasta nasce ao habilitar a pergunta do
`/claude:novo-projeto` ou na primeira execução manual do
`/claude:pesquisa`. Ver
[`skills/pesquisa-workflow/SKILL.md`](skills/pesquisa-workflow/SKILL.md).

### Comando `/claude:pesquisa`

Pesquisa um tema explícito e registra a nota no mesmo formato que a skill
usa automaticamente — também serve para criar a pasta `pesquisa/` na mão
(bootstrap), ativando o registro automático dali em diante. Ver
[`commands/claude/pesquisa.md`](commands/claude/pesquisa.md).

### Comando `/claude:novo-projeto`

Cria um projeto novo a partir de um template (`lite` ou `full`), inicializa
um repositório Git limpo, e pergunta se você quer habilitar — **só naquele
projeto** — (1) um hook `Stop` que faz um commit local de segurança ao final
de cada resposta (nunca push/pull, só commit local) e (2) a pasta
`pesquisa/` com o registro automático de pesquisas. Ver
[`commands/claude/novo-projeto.md`](commands/claude/novo-projeto.md).

Os templates que ele copia (`templates/harness-lite`, `templates/harness-full`)
estão **empacotados neste repositório** — não é mais preciso ter uma pasta
`harness-templates` separada. A única exigência: o comando lê os templates a
partir de `%USERPROFILE%\Documents\GitHub\comand-novo-projeto\templates\...`,
então este repositório precisa estar clonado nesse caminho (ajuste `$repoRoot`
no arquivo do comando se você clonar em outro lugar).

### Árvore de commits ao vivo (`.claude/arvore-de-commits.md`)

Diferente de [`pesquisa/11-arvore-de-commits.md`](../pesquisa/11-arvore-de-commits.md)
(diagramas **conceituais** de branch/merge/rebase), este arquivo mostra o
diagrama Mermaid `gitGraph` gerado a partir do **histórico real** deste
repositório — commits, branches e merges de verdade, sempre atualizado.

- Gerado por [`scripts/arvore-de-commits.sh`](scripts/arvore-de-commits.sh) /
  [`.ps1`](scripts/arvore-de-commits.ps1) — rode manualmente a qualquer
  momento para atualizar.
- O script é **bundlado em ambos os templates** (`.claude/scripts/` dentro de
  cada um) — todo projeto criado via `/claude:novo-projeto` já nasce com ele,
  independente do hook. O hook `Stop` (item 1 do `/claude:novo-projeto`, ver
  acima) chama esse script a cada resposta, então o arquivo se mantém
  sozinho; sem o hook, é só um gerador sob demanda.
- Diferente das skills/comandos globais, este script **não** é distribuído
  por `install-global` — ele é sempre local ao projeto (bundlado ou copiado
  manualmente), porque opera sobre "o repositório onde ele está", não sobre
  um repositório arbitrário.
- O arquivo sempre fica **um commit atrasado**: ele não pode conter a hash do
  commit que o atualiza, por definição (mesma limitação de qualquer changelog
  autogerado).
- Suporta histórico linear perfeitamente e branch+merge simples (uma branch
  de cada vez, mesclada de volta) de forma correta; várias branches
  concorrentes/aninhadas usam best-effort (branches ainda não mescladas são
  anexadas ao final do diagrama).

## Instalar isso globalmente em outra máquina

Para que as regras valham em **todo projeto**, não só neste, clone o
repositório no caminho esperado pelo `/claude:novo-projeto` e rode o script
de instalação:

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

O script (`.claude/scripts/install-global.sh` / `.ps1`) copia, de dentro do clone
para `~/.claude/`:

- **Skills** (`.claude/skills/` → `~/.claude/skills/`): `git-workflow`,
  `pesquisa-workflow`.
- **Comandos** (`.claude/commands/claude/` → `~/.claude/commands/claude/`):
  `novo-projeto.md`, `pesquisa.md`.

Por padrão ele **não sobrescreve** o que já existir em `~/.claude/` — passe
`--force` (bash) ou `-Force` (PowerShell) se quiser atualizar uma instalação
anterior com as versões do clone. Ele é exatamente o que os comandos manuais
abaixo fazem, só automatizado:

<details>
<summary>Equivalente manual (o que o script roda por baixo)</summary>

```bash
cp -r ~/Documents/GitHub/comand-novo-projeto/.claude/skills/git-workflow ~/.claude/skills/git-workflow
cp -r ~/Documents/GitHub/comand-novo-projeto/.claude/skills/pesquisa-workflow ~/.claude/skills/pesquisa-workflow
cp ~/Documents/GitHub/comand-novo-projeto/.claude/commands/claude/novo-projeto.md ~/.claude/commands/claude/novo-projeto.md
cp ~/Documents/GitHub/comand-novo-projeto/.claude/commands/claude/pesquisa.md ~/.claude/commands/claude/pesquisa.md
```

</details>

> As skills sozinhas (sem clonar o repositório) continuam funcionando
> normalmente — nenhuma depende de `templates/`. É só o comando
> `/claude:novo-projeto` que precisa do clone existir naquele caminho.
> `/claude:pesquisa` já vem copiado dentro dos templates também, então
> qualquer projeto gerado por eles já nasce com o comando disponível.

### Reforço opcional no `CLAUDE.md` global

As skills já são descobertas automaticamente pelo Claude Code (gatilho
definido no frontmatter de cada `SKILL.md`), mas para garantir que as regras
valham mesmo se o gatilho não disparar, adicione ao seu `~/.claude/CLAUDE.md`:

```markdown
## Versionamento automático (skill `git-workflow`)

Em todo projeto com repositório Git (ou que deveria ter um), siga a skill
global `git-workflow` (`~/.claude/skills/git-workflow/`):

- `git init` automático se o projeto ainda não for um repositório.
- Branch nova por tarefa/feature substancial (`git switch -c tipo/slug`).
- Commit local atômico ao final de cada tarefa concluída.
- `git push`/`pull`/`fetch` e ações no GitHub/GitLab só com autorização
  explícita na conversa.

## Registro automático de pesquisas (skill `pesquisa-workflow`)

Em todo projeto que já tenha uma pasta `pesquisa/` na raiz, siga a skill
global `pesquisa-workflow` (`~/.claude/skills/pesquisa-workflow/`):

- Ao concluir uma pesquisa não trivial (múltiplas buscas/leituras sobre um
  tema), salvar uma nota estruturada em `pesquisa/<slug>.md` e atualizar o
  índice em `pesquisa/README.md`, sem que o usuário precise pedir.
- Se `pesquisa/` não existir no projeto, não criar nada sozinho — é
  opt-in por pasta (ver `/claude:novo-projeto` ou `/claude:pesquisa`).
```

## Por que Git local é automático mas Git remoto não

Commits e branches locais são reversíveis e não afetam ninguém além de
quem está na própria máquina — por isso viram hábito automático. Já
`push`/`pull`/`fetch` tocam um servidor compartilhado (GitHub, GitLab...) e
podem afetar outras pessoas ou sobrescrever trabalho remoto — por isso
continuam exigindo autorização explícita a cada vez, sem exceção.

Para o contexto completo de pesquisa sobre Git usado como base desta skill,
ver a pasta [`../pesquisa/`](../pesquisa/) na raiz deste repositório.
