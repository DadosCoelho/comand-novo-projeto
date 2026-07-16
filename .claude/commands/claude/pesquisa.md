---
description: Pesquisa um tema e registra uma nota estruturada em pesquisa/.
argument-hint: [tema]
allowed-tools: WebSearch, WebFetch, Read, Write, Edit, Glob, AskUserQuestion
---

# /claude:pesquisa — pesquisar um tema e registrar a nota

Pesquisa `$ARGUMENTS` e salva uma nota estruturada em `pesquisa/<slug>.md`,
atualizando o índice em `pesquisa/README.md`. A primeira execução no projeto
cria a pasta — a partir daí, a skill `pesquisa-workflow` passa a registrar
pesquisas automaticamente também, sem precisar deste comando.

## Argumentos

- `$ARGUMENTS` — o tema a pesquisar. Se vazio, **pergunte** ao usuário qual é
  o tema antes de continuar.

## Passos

### Passo 1: Pesquisar

Investigue o tema com as ferramentas disponíveis (WebSearch, WebFetch,
`context7` para documentação de bibliotecas, leitura de código do próprio
projeto quando relevante). Não se limite a uma única fonte se o tema pedir
comparação ou aprofundamento.

### Passo 2: Bootstrap da pasta (se necessário)

Se `pesquisa/` não existir na raiz do projeto, crie-a agora junto com
`pesquisa/README.md` (índice vazio, ver formato abaixo). A partir deste
ponto a pasta existe e a skill `pesquisa-workflow` passa a registrar
pesquisas futuras automaticamente, sem que este comando precise ser chamado
de novo.

### Passo 3: Escrever a nota

Crie (ou, se já existir uma nota sobre o mesmo tema, atualize)
`pesquisa/<slug-do-tema>.md`:

```markdown
# <Título da pesquisa>

> **Data:** YYYY-MM-DD
> **Tags:** tag1, tag2

## Pergunta / Contexto
<o que motivou a pesquisa>

## Resumo
<resposta direta, 3-5 frases>

## Detalhes
<desenvolvimento, comparações, trade-offs>

## Fontes
- [título do link](url)
```

### Passo 4: Atualizar o índice

Adicione (ou atualize) uma linha em `pesquisa/README.md`:

```markdown
| YYYY-MM-DD | [Título](slug.md) | tag1, tag2 |
```

Entrada mais recente no topo da tabela.

### Passo 5: Confirmar

Mostre ao usuário: título da nota, caminho do arquivo, e se a pasta
`pesquisa/` foi criada agora (primeira vez).

## Regras

- Use a data de hoje (YYYY-MM-DD) — pergunte ao usuário se não souber.
- Slug em kebab-case, curto e descritivo (ex.: `rate-limiting-express`).
- Se já existe nota sobre o mesmo tema, **atualize** em vez de duplicar.
- Sempre cite as fontes realmente consultadas — nunca invente links.
