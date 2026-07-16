# `.claude/` deste projeto — comando + skill de versionamento Git

Esta pasta traz, além dos comandos padrão do template `harness-lite`
(`learning`, `manual-verify`), dois itens específicos de workflow com Git:

```
.claude/
├── commands/claude/
│   ├── learning.md          # /claude:learning (padrão do harness-lite)
│   ├── manual-verify.md     # /claude:manual-verify (padrão do harness-lite)
│   └── novo-projeto.md      # /claude:novo-projeto — scaffold de projeto novo
└── skills/
    └── git-workflow/         # conhecimento prático de Git + regras de automação
        ├── SKILL.md
        └── reference/
            ├── comandos-essenciais.md
            ├── comandos-avancados.md
            ├── branching-merge-fluxos.md
            └── boas-praticas-seguranca.md
templates/                     # os templates que /claude:novo-projeto copia
├── harness-lite/
└── harness-full/
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

### Comando `/claude:novo-projeto`

Cria um projeto novo a partir de um template (`lite` ou `full`), inicializa
um repositório Git limpo, e pergunta se você quer habilitar — **só naquele
projeto** — um hook `Stop` que faz um commit local de segurança ao final de
cada resposta (nunca push/pull, só commit local). Ver
[`commands/claude/novo-projeto.md`](commands/claude/novo-projeto.md).

Os templates que ele copia (`templates/harness-lite`, `templates/harness-full`)
estão **empacotados neste repositório** — não é mais preciso ter uma pasta
`harness-templates` separada. A única exigência: o comando lê os templates a
partir de `%USERPROFILE%\Documents\GitHub\comand-novo-projeto\templates\...`,
então este repositório precisa estar clonado nesse caminho (ajuste `$repoRoot`
no arquivo do comando se você clonar em outro lugar).

## Instalar isso globalmente em outra máquina

Para que as regras valham em **todo projeto**, não só neste:

```bash
# 0) clone este repositório no caminho esperado pelo comando
git clone https://github.com/DadosCoelho/comand-novo-projeto.git \
  ~/Documents/GitHub/comand-novo-projeto

# 1) copie a skill para a pasta global de skills
cp -r ~/Documents/GitHub/comand-novo-projeto/.claude/skills/git-workflow ~/.claude/skills/git-workflow

# 2) copie o comando para a pasta global de comandos (namespace claude:)
cp ~/Documents/GitHub/comand-novo-projeto/.claude/commands/claude/novo-projeto.md ~/.claude/commands/claude/novo-projeto.md
# os templates ficam onde estão, dentro do clone — o comando os lê de lá
```

No Windows/PowerShell:

```powershell
git clone https://github.com/DadosCoelho/comand-novo-projeto.git `
  "$env:USERPROFILE\Documents\GitHub\comand-novo-projeto"
Copy-Item -Recurse "$env:USERPROFILE\Documents\GitHub\comand-novo-projeto\.claude\skills\git-workflow" "$HOME\.claude\skills\git-workflow"
Copy-Item "$env:USERPROFILE\Documents\GitHub\comand-novo-projeto\.claude\commands\claude\novo-projeto.md" "$HOME\.claude\commands\claude\novo-projeto.md"
```

> A skill sozinha (sem clonar o repositório) continua funcionando
> normalmente — ela não depende de `templates/`. É só o comando
> `/claude:novo-projeto` que precisa do clone existir naquele caminho.

### Reforço opcional no `CLAUDE.md` global

A skill já é descoberta automaticamente pelo Claude Code (gatilho definido
no frontmatter de `SKILL.md`), mas para garantir que as regras valham mesmo
se o gatilho não disparar, adicione ao seu `~/.claude/CLAUDE.md`:

```markdown
## Versionamento automático (skill `git-workflow`)

Em todo projeto com repositório Git (ou que deveria ter um), siga a skill
global `git-workflow` (`~/.claude/skills/git-workflow/`):

- `git init` automático se o projeto ainda não for um repositório.
- Branch nova por tarefa/feature substancial (`git switch -c tipo/slug`).
- Commit local atômico ao final de cada tarefa concluída.
- `git push`/`pull`/`fetch` e ações no GitHub/GitLab só com autorização
  explícita na conversa.
```

## Por que Git local é automático mas Git remoto não

Commits e branches locais são reversíveis e não afetam ninguém além de
quem está na própria máquina — por isso viram hábito automático. Já
`push`/`pull`/`fetch` tocam um servidor compartilhado (GitHub, GitLab...) e
podem afetar outras pessoas ou sobrescrever trabalho remoto — por isso
continuam exigindo autorização explícita a cada vez, sem exceção.

Para o contexto completo de pesquisa sobre Git usado como base desta skill,
ver a pasta [`../pesquisa/`](../pesquisa/) na raiz deste repositório.
