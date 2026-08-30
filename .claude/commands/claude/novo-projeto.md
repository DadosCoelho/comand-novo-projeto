---
description: Cria um projeto novo na pasta Projetos a partir de um template harness (lite ou full).
argument-hint: lite|full <nome-do-projeto>
allowed-tools: Bash, Read, Glob, Write, AskUserQuestion
---

# /claude:novo-projeto — gerar projeto a partir de um template harness

Crie um projeto novo copiando um dos templates empacotados neste próprio
repositório (`templates/harness-lite`, `templates/harness-full`) para a
pasta `Projetos`, sem arrastar histórico git nenhum (cada projeto nasce com
seu próprio repositório limpo).

## Argumentos

`$ARGUMENTS` segue o formato: `<template> <nome-do-projeto>`

- **template**: `lite` ou `full`
  - `lite` → `<comand-novo-projeto>\templates\harness-lite`
  - `full` → `<comand-novo-projeto>\templates\harness-full`
- **nome-do-projeto**: o nome da pasta a criar dentro de
  `%USERPROFILE%\Documents\Projetos\`.

> **Pré-requisito:** este comando lê os templates de dentro do repositório
> `comand-novo-projeto` (o mesmo que contém este arquivo), esperado em
> `%USERPROFILE%\Documents\Projetos\Ferramentas\comand-novo-projeto\`. Se você clonou
> esse repositório em outro lugar, ajuste `$repoRoot` no passo 2 abaixo.

## Passos

1. **Parse e validação.** Separe `$ARGUMENTS` em `<template>` e `<nome>`.
   - Se faltar algum, ou se `<template>` não for `lite`/`full`, **pare** e
     mostre o uso: `/claude:novo-projeto lite|full <nome-do-projeto>`.
   - Resolva o caminho de origem (`harness-lite` ou `harness-full` dentro de
     `templates/`) e o destino `%USERPROFILE%\Documents\Projetos\<nome>`.
   - Se o destino **já existir**, pare e avise — nunca sobrescreva uma pasta
     existente.

2. **Copiar o template.** Os templates empacotados em `templates/` já não
   têm `.git` próprio (foram removidos ao empacotar), então a cópia é
   direta — sem exclusão nem limpeza extra:

   ```powershell
   $repoRoot = "$env:USERPROFILE\Documents\Projetos\Ferramentas\comand-novo-projeto"
   $src  = "$repoRoot\templates\harness-<TEMPLATE>"
   $dest = "$env:USERPROFILE\Documents\Projetos\<NOME>"
   if (-not (Test-Path $src)) { throw "Template nao encontrado em $src — confirme que comand-novo-projeto esta clonado em $repoRoot (ou ajuste `$repoRoot` neste comando)." }
   if (Test-Path $dest) { throw "Destino já existe: $dest" }
   New-Item -ItemType Directory -Path $dest | Out-Null
   Copy-Item -Path (Join-Path $src '*') -Destination $dest -Recurse -Force
   ```

3. **Inicializar um repositório git limpo** no destino:

   ```powershell
   git -C $dest init -b main
   git -C $dest add -A
   git -C $dest commit -m "chore: scaffold a partir do template harness-<TEMPLATE>"
   ```

4. **Perguntar sobre auto-commit local.** Use `AskUserQuestion` para
   perguntar se o usuário quer habilitar, **só neste projeto**, um hook de
   segurança que faz um commit local automático ao final de cada resposta
   (evento `Stop`) quando houver mudanças relevantes no working tree —
   nunca `push`/`pull`/`fetch`, só commit local. Isso é complementar aos
   commits atômicos que já são feitos por padrão (ver skill global
   `git-workflow`); serve como rede de segurança extra. O mesmo hook também
   chama `.claude/scripts/arvore-de-commits.sh` (já bundlado no template) a
   cada resposta, regenerando `.claude/arvore-de-commits.md` — o diagrama
   Mermaid `gitGraph` do histórico real do projeto.

   - Pergunta: "Quer habilitar auto-commit local automático (checkpoint a
     cada resposta) neste projeto?" com opções "Sim, habilitar" / "Não,
     obrigado".
   - Se **sim**, escreva `$dest\.claude\settings.local.json` com:

     ```json
     {
       "hooks": {
         "Stop": [
           {
             "hooks": [
               {
                 "type": "command",
                 "shell": "bash",
                 "statusMessage": "Verificando checkpoint automático...",
                 "timeout": 30,
                 "command": "git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0\nroot=$(git rev-parse --show-toplevel)\nbash \"$root/.claude/scripts/arvore-de-commits.sh\" >/dev/null 2>&1 || true\n[ -z \"$(git status --porcelain --untracked-files=all 2>/dev/null)\" ] && exit 0\ngit add -A -- . 2>/dev/null\nstaged=$(git diff --cached --name-only)\n[ -z \"$staged\" ] && exit 0\nn=$(printf '%s\\n' \"$staged\" | wc -l | tr -d ' ')\nsample=$(printf '%s\\n' \"$staged\" | head -3 | tr '\\n' ',' | sed 's/,$//')\nmsg=\"chore: checkpoint automático ($n arquivo(s): $sample)\"\nif git commit -q -m \"$msg\" 2>/dev/null; then\n  esc=\"Commit automático: $msg\"\n  esc=\"${esc//\\\\/\\\\\\\\}\"\n  esc=\"${esc//\\\"/\\\\\\\"}\"\n  printf '{\"systemMessage\": \"%s\"}\\n' \"$esc\"\nfi"
               }
             ]
           }
         ]
       }
     }
     ```

   - `.claude/settings.local.json` já está no `.gitignore` de ambos os
     templates (lite e full) — não versionar essa preferência pessoal.
   - Se **não**, não crie o arquivo; não pergunte de novo depois, o
     usuário pode pedir manualmente mais tarde se mudar de ideia. Sem o
     hook, `.claude/scripts/arvore-de-commits.sh`/`.ps1` continuam
     disponíveis para rodar sob demanda (`.claude/arvore-de-commits.md` só
     é criado/atualizado quando alguém chama o script).

5. **Perguntar sobre o RTK (compressão da saída de comandos).** Só faça esta
   pergunta se o `rtk` estiver instalado — confira com
   `Get-Command rtk -ErrorAction SilentlyContinue`. Sem o binário no PATH o
   hook chamaria um executável inexistente a cada comando; nesse caso **pule
   o passo em silêncio** e apague `$dest\.rtk\`.

   O RTK é um proxy de CLI: roda o comando de verdade e comprime a saída
   antes de ela entrar no contexto (filtra, agrupa, deduplica). Use
   `AskUserQuestion` — "Quer habilitar o RTK (compressão da saída de
   comandos) neste projeto?", opções "Sim, habilitar" / "Não, obrigado".

   - Se **sim**, **mescle** este bloco em `$dest\.claude\settings.local.json`.
     Mesclar, não sobrescrever: o arquivo pode já ter o hook `Stop` do passo
     4, e escrever por cima apagaria o auto-commit.

     ```json
     {
       "hooks": {
         "PreToolUse": [
           {
             "matcher": "Bash",
             "hooks": [
               { "type": "command", "command": "rtk hook claude" }
             ]
           }
         ]
       }
     }
     ```

     **Nunca rode `rtk init -g`** — ele instala o hook em
     `~/.claude/settings.json` e passa a valer para todos os projetos, que é
     o oposto do que este passo faz. (`rtk init` sem `-g` também não serve:
     não instala hook nenhum, só escreve instruções no `CLAUDE.md`.)

     O `.rtk/config.toml` já vem no template, **versionado**, com a lista de
     exclusões e o princípio para mantê-la: exclua todo comando cuja saída é
     o produto, não o meio.
   - Se **não**, apague `$dest\.rtk\` — sem o hook ele é só ruído.

   > **Avise sobre a régua se o passo 7 também for habilitado.** O RTK
   > derruba o consumo de pontos e portanto muda o N da régua de orçamento.
   > Os 85/65 emprestados foram medidos **sem** ele, então vão
   > **superestimar** o custo dos primeiros blocos — que é o lado seguro do
   > erro, e a régua converge para a deste projeto a cada bloco. Isso só vale
   > enquanto o RTK ficar estável: mexer no `.rtk/config.toml` no meio do
   > projeto cria uma descontinuidade na série. Se mexer, anote a data em
   > `medicoes.md`. O `medicoes.py` lê transcrição e `git log` — ele não tem
   > como saber se o RTK estava ligado.

6. **Perguntar sobre registro automático de pesquisas.** Use
   `AskUserQuestion` para perguntar se o usuário quer habilitar, neste
   projeto, o registro automático de pesquisas: sempre que eu concluir uma
   investigação não trivial (múltiplas buscas/leituras sobre um tema), salvo
   uma nota estruturada em `pesquisa/<slug>.md` e atualizo um índice — sem
   que o usuário precise pedir. Isso é feito pela skill global
   `pesquisa-workflow`; o comando `/claude:pesquisa` (já copiado do
   template, disponível em ambos) já entra junto e serve tanto para pesquisa
   explícita quanto para habilitar isso depois manualmente.

   - Pergunta: "Quer habilitar registro automático de pesquisas
     (`pesquisa/`) neste projeto?" com opções "Sim, habilitar" / "Não,
     obrigado".
   - Se **sim**, crie `$dest\pesquisa\README.md` com um índice vazio:

     ```markdown
     # Pesquisas

     | Data | Tema | Tags |
     |---|---|---|
     ```

     A pasta `pesquisa/` é **versionada** (não é preferência local como o
     hook de commit) — faz parte do conteúdo do projeto.
   - Se **não**, não crie a pasta agora. O comando `/claude:pesquisa`
     continua disponível e, se usado manualmente depois, cria a pasta e
     ativa o registro automático a partir daí (não precisa perguntar de
     novo).

7. **Perguntar sobre plano em blocos medidos.** Use `AskUserQuestion` para
   perguntar se o usuário quer habilitar, neste projeto, o planejamento em
   blocos com orçamento de sessão: quando o trabalho não couber numa sessão,
   eu recorto em blocos que terminam verdes, agrupo em janelas por contexto
   compartilhado, peço `/usage` nas duas pontas de cada bloco e `/clear` só
   quando a troca de contexto justifica — mantendo uma régua que melhora a
   cada bloco medido. Isso é feito pela skill global `plano-em-blocos`; o
   comando `/claude:plano` entra junto e serve tanto para criar o plano
   quanto para habilitar isso depois manualmente.

   **Só faça esta pergunta se o projeto tiver cara de trabalho longo** —
   template `full`, ou o usuário descrevendo várias entregas. Num projeto
   pequeno a skill é overhead, e perguntar já sugere que ela é necessária.

   - Pergunta: "Quer habilitar plano em blocos medidos (`ai-docs/plano/`)
     neste projeto?" com opções "Sim, habilitar" / "Não, obrigado".
   - Se **sim**, crie `$desti-docs\plano\plano.md` e
     `$desti-docs\plano\medicoes.md` nos formatos declarados na skill
     `plano-em-blocos`, com os blocos ainda vazios e a régua no ponto de
     partida (85 quente / 65 frio), marcada como **ponto de partida
     emprestado, a ser substituído pela régua deste projeto**.

     A pasta `ai-docs/plano/` é **versionada** — é conteúdo de projeto, não
     configuração de ferramenta, e por isso não vai para `.claude/`.
   - Se **não**, não crie a pasta agora. O comando `/claude:plano` continua
     disponível e, se usado manualmente depois, cria a pasta e ativa o
     comportamento automático a partir daí.

8. **Relatar.** Mostre ao usuário:
   - O caminho do projeto criado.
   - Confirmação de que é um repo git novo (sem o histórico do template).
   - **Próximos passos por template:**
     - **lite:** preencher os `{{placeholders}}` em `CLAUDE.md`
       ("Project-specific notes"). Comandos disponíveis: `/claude:learning`,
       `/claude:manual-verify`, `/claude:pesquisa`, `/claude:plano`.
     - **full:** preencher os `{{placeholders}}` em `ai-docs/PRD.md` e em
       `CLAUDE.md`; depois `/claude:create-tasks` → `/claude:dev`. Lembrar de curar
       `.claude/skills/` e `ai-docs/tools.yaml`.
   - Se o auto-commit local foi habilitado no passo 4, avise que ele só
     entra em vigor na próxima sessão do Claude Code aberta nesse projeto, e
     que a partir daí `.claude/arvore-de-commits.md` também passa a ser
     mantido sozinho.
   - Se o RTK foi habilitado no passo 5, avise que ele também só entra em
     vigor na próxima sessão do Claude Code aberta nesse projeto, que dá
     para conferir com `rtk gain` depois de alguns comandos, e que o
     `rtk gain` estima `bytes ÷ 4` sobre o que ele tocou — é o teto do
     efeito possível, não o efeito no consumo da sessão. Quem decide isso é
     o `/usage`.
   - Se o registro de pesquisas foi habilitado no passo 6, avise que a
     skill `pesquisa-workflow` precisa estar instalada globalmente
     (`~/.claude/skills/pesquisa-workflow/`) para o registro automático
     funcionar — sem ela, só o comando `/claude:pesquisa` (rodado à mão)
     funciona.
   - Se o plano em blocos foi habilitado no passo 7, avise o mesmo sobre a
     skill `plano-em-blocos` (`~/.claude/skills/plano-em-blocos/`), e que a
     primeira leitura de `/usage` é pedida no começo do primeiro bloco.

## Regras

- Nunca sobrescreva uma pasta existente — pare e avise.
- Os templates em `templates/` não têm `.git` próprio — cada projeto novo
  ganha histórico limpo já pelo passo 3 (`git init`), sem precisar excluir
  nada na cópia.
- Não faça `git push` nem crie repositório remoto; isso é decisão do usuário.
- As skills e MCPs do usuário são **globais** (`~/.claude/`), então o projeto
  novo já nasce com elas — inclusive a skill `git-workflow`, que já cobre
  branch por tarefa e commit por tarefa concluída por padrão. O hook do
  passo 4, o RTK do passo 5, a pasta `pesquisa/` do passo 6 e a pasta
  `ai-docs/plano/` do passo 7 são extras opt-in por projeto.
- **Nada de conteúdo de projeto vai para `.claude/`.** Ali moram comandos,
  skills, scripts e settings — *como* eu trabalho. O que eu produzo **sobre**
  o trabalho (lições, plano, medições) vai para `ai-docs/`; o produto e suas
  fontes (código, especificação, `pesquisa/`) ficam na raiz.
- `.claude/scripts/arvore-de-commits.sh`/`.ps1` vêm bundlados em ambos os
  templates e sempre disponíveis, independente do que foi respondido no
  passo 4 — só o hook automático (que os chama a cada resposta) é opt-in.
