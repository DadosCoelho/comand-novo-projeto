---
description: Detecta stack, backend, package manager, comandos e convenções do projeto e sincroniza a seção "Project-specific notes" do CLAUDE.md.
argument-hint: [dica opcional, ex: "usamos pnpm e testamos com vitest"]
allowed-tools: Read, Glob, Grep, Bash, Edit
---

# /claude:atualizar-notas — sincronizar "Project-specific notes" do CLAUDE.md

Investiga o estado real do projeto e atualiza a seção `## Project-specific
notes` do `CLAUDE.md` (Stack, Backend/database, Package manager, Run/build/
test, Conventions), substituindo `{{placeholders}}` por valores reais
conforme forem ficando decidíveis. É a versão sob demanda da regra "Keep
Project-specific notes current" do próprio `CLAUDE.md` — mesma coisa que eu
já devo fazer sozinho ao longo do desenvolvimento, só que disparada
explicitamente.

## Argumentos

- `$ARGUMENTS` — opcional. Dica em texto livre para campos que a detecção
  sozinha não resolve (ex.: `"convenção é validar tudo com zod"`,
  `"rodamos teste com vitest"`). Trate como pista a confirmar contra o
  repositório, não como verdade absoluta — se contradizer o que está no
  disco, sinalize o conflito em vez de aceitar cegamente.

## Passos

### Passo 1: Localizar a seção

Leia o `CLAUDE.md` na raiz do projeto e encontre `## Project-specific
notes` (5 campos: Stack, Backend/database, Package manager, Run/build/test,
Conventions). Se o arquivo ou a seção não existir, **pare** e avise — este
comando só sincroniza uma seção existente, não cria `CLAUDE.md` do zero.

### Passo 2: Detectar cada campo a partir do repositório

Investigue o projeto de verdade — não chute:

- **Stack**: `package.json` (`dependencies`/`devDependencies` — react, vue,
  next, express...), `requirements.txt`/`pyproject.toml` (django, flask,
  fastapi), `go.mod`, `Cargo.toml`, `pom.xml`/`build.gradle`. Sem manifesto
  nenhum, use a extensão de arquivo dominante como último recurso.
- **Backend / database**: clientes de banco/ORM no manifesto (`prisma`,
  `mongoose`, `pg`, `mysql2`, `firebase-admin`, `@supabase/supabase-js`,
  `convex`), serviços em `docker-compose.yml`, nomes de variável em
  `.env.example` (`DATABASE_URL`, `MONGODB_URI`). Nada encontrado é
  legitimamente `"none"` — não force uma resposta.
- **Package manager**: lockfile presente — `package-lock.json`→npm,
  `pnpm-lock.yaml`→pnpm, `yarn.lock`→yarn, `bun.lockb`→bun; em Python:
  `poetry.lock`→poetry, `uv.lock`→uv, `Pipfile.lock`→pipenv,
  `requirements.txt` sozinho→pip.
- **Run / build / test**: bloco `scripts` do `package.json`, alvos de
  `Makefile`, `[tool.poetry.scripts]` do `pyproject.toml`, ou instruções do
  `README.md` na ausência de tudo isso.
- **Conventions**: melhor esforço — layout de pastas (`src/`, `app/`,
  `components/`, `tests/`), biblioteca de validação (`zod`, `yup`,
  `pydantic`), padrão de auth (`next-auth`, `passport`, firebase auth),
  biblioteca de i18n, estilo de nomenclatura observado em múltiplos
  arquivos. Só escreva o que for observável em **2 ou mais lugares** — um
  arquivo isolado ainda não é uma convenção.

Se `$ARGUMENTS` foi passado, use como pista para campos que a detecção
sozinha deixou ambíguos — confirme contra o repositório (ex.: se o usuário
diz "pnpm" mas existe `package-lock.json`, sinalize a divergência em vez de
confiar cegamente na dica).

### Passo 3: Mesclar sem atropelar

Para cada um dos 5 campos:

- Ainda é `{{placeholder}}` e algo foi detectado → preencha.
- Já está preenchido com conteúdo real **e** ainda bate com o que está no
  disco → não mexa.
- Já está preenchido mas agora **contradiz** o disco (ex.: diz "npm" mas
  hoje existe `pnpm-lock.yaml`) → atualize, e mencione a mudança
  explicitamente no relatório — nunca sobrescreva em silêncio uma decisão
  que o usuário pode ter tomado de propósito.
- Nada detectável para o campo → deixe o placeholder como está. Campo vazio
  significa "ainda não decidido", não "esquecido".

### Passo 4: Escrever e relatar

Edite o `CLAUDE.md` com a seção atualizada. Relate ao usuário, por campo:
inalterado / preenchido (valor) / atualizado (valor antigo → novo). Se nada
mudou, diga isso claramente em vez de fazer uma edição vazia.

## Regras

- Nunca invente valores que você não consegue observar no repositório — uma
  nota de "Conventions" errada é pior que vazia, porque toda sessão futura
  confia nela ao pé da letra.
- Este comando só mexe na seção "Project-specific notes" — nada mais do
  `CLAUDE.md`.
- Escreva na mesma língua em que o `CLAUDE.md` já está (hoje, inglês).
