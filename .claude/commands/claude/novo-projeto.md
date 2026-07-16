---
description: Cria um projeto novo na pasta GitHub a partir de um template harness (lite ou full).
argument-hint: lite|full <nome-do-projeto>
allowed-tools: Bash, Read, Glob, Write, AskUserQuestion
---

# /claude:novo-projeto — gerar projeto a partir de um template harness

Crie um projeto novo copiando um dos templates locais para a pasta `GitHub`,
sem arrastar o histórico git do template (cada projeto nasce com seu próprio
repositório limpo).

## Argumentos

`$ARGUMENTS` segue o formato: `<template> <nome-do-projeto>`

- **template**: `lite` ou `full`
  - `lite` → `C:\Users\daldo\Documents\GitHub\harness-templates\harness-lite`
  - `full` → `C:\Users\daldo\Documents\GitHub\harness-templates\harness-full`
- **nome-do-projeto**: o nome da pasta a criar dentro de
  `C:\Users\daldo\Documents\GitHub\`.

## Passos

1. **Parse e validação.** Separe `$ARGUMENTS` em `<template>` e `<nome>`.
   - Se faltar algum, ou se `<template>` não for `lite`/`full`, **pare** e
     mostre o uso: `/claude:novo-projeto lite|full <nome-do-projeto>`.
   - Resolva o caminho de origem (`harness-lite` ou `harness-full`) e o destino
     `C:\Users\daldo\Documents\GitHub\<nome>`.
   - Se o destino **já existir**, pare e avise — nunca sobrescreva uma pasta
     existente.

2. **Copiar o template (sem o `.git` dele).** Use PowerShell via Bash tool ou
   diretamente. O essencial: copiar tudo **exceto** a pasta `.git` do template.

   ```powershell
   $src  = "C:\Users\daldo\Documents\GitHub\harness-templates\harness-<TEMPLATE>"
   $dest = "C:\Users\daldo\Documents\GitHub\<NOME>"
   if (Test-Path $dest) { throw "Destino já existe: $dest" }
   New-Item -ItemType Directory -Path $dest | Out-Null
   Copy-Item -Path (Join-Path $src '*') -Destination $dest -Recurse -Force -Exclude '.git'
   # .git é um diretório oculto; o -Exclude acima cobre o item de topo.
   # Garanta a remoção caso algo escape:
   if (Test-Path (Join-Path $dest '.git')) { Remove-Item (Join-Path $dest '.git') -Recurse -Force }
   ```

   > Observação: `Copy-Item -Recurse -Exclude '.git'` pode, dependendo da versão,
   > copiar `.git` aninhado. Por isso o `Remove-Item` de segurança logo depois.
   > Confirme com um `Test-Path` que `<dest>\.git` não existe ao final.

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
   `git-workflow`); serve como rede de segurança extra.

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
                 "command": "git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0\n[ -z \"$(git status --porcelain --untracked-files=all 2>/dev/null)\" ] && exit 0\ngit add -A -- . 2>/dev/null\nstaged=$(git diff --cached --name-only)\n[ -z \"$staged\" ] && exit 0\nn=$(printf '%s\\n' \"$staged\" | wc -l | tr -d ' ')\nsample=$(printf '%s\\n' \"$staged\" | head -3 | tr '\\n' ',' | sed 's/,$//')\nmsg=\"chore: checkpoint automático ($n arquivo(s): $sample)\"\nif git commit -q -m \"$msg\" 2>/dev/null; then\n  esc=\"Commit automático: $msg\"\n  esc=\"${esc//\\\\/\\\\\\\\}\"\n  esc=\"${esc//\\\"/\\\\\\\"}\"\n  printf '{\"systemMessage\": \"%s\"}\\n' \"$esc\"\nfi"
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
     usuário pode pedir manualmente mais tarde se mudar de ideia.

5. **Relatar.** Mostre ao usuário:
   - O caminho do projeto criado.
   - Confirmação de que é um repo git novo (sem o histórico do template).
   - **Próximos passos por template:**
     - **lite:** preencher os `{{placeholders}}` em `CLAUDE.md`
       ("Project-specific notes"). Comandos disponíveis: `/claude:learning`,
       `/claude:manual-verify`.
     - **full:** preencher os `{{placeholders}}` em `ai-docs/PRD.md` e em
       `CLAUDE.md`; depois `/claude:create-tasks` → `/claude:dev`. Lembrar de curar
       `.claude/skills/` e `ai-docs/tools.yaml`.
   - Se o auto-commit local foi habilitado no passo 4, avise que ele só
     entra em vigor na próxima sessão do Claude Code aberta nesse projeto.

## Regras

- Nunca sobrescreva uma pasta existente — pare e avise.
- Nunca copie o `.git` do template — cada projeto deve ter histórico próprio.
- Não faça `git push` nem crie repositório remoto; isso é decisão do usuário.
- As skills e MCPs do usuário são **globais** (`~/.claude/`), então o projeto
  novo já nasce com elas — inclusive a skill `git-workflow`, que já cobre
  branch por tarefa e commit por tarefa concluída por padrão. O hook do
  passo 4 é só uma rede de segurança extra, opt-in por projeto.
