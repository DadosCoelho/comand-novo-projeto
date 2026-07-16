---
name: pesquisa-workflow
description: Registro automático de pesquisas em uma pasta `pesquisa/` do projeto — uma nota por tema, com índice, sempre que uma investigação não trivial (múltiplas buscas/leituras sobre um assunto) é concluída. Opt-in por projeto: só age se a pasta `pesquisa/` já existir na raiz.
trigger: >
  TRIGGER proativamente ao concluir uma pesquisa não trivial dentro de um
  projeto que já tem uma pasta `pesquisa/` na raiz: investigação de múltiplas
  fontes/buscas sobre um tema (WebSearch, WebFetch, leitura de documentação),
  comparação de bibliotecas/abordagens, resposta a perguntas do tipo "como
  funciona X" / "o que é X" que exigiram pesquisa real (não só conhecimento
  já sabido). Também trigger quando o usuário pede pesquisa explicitamente
  ("pesquisa sobre", "investiga", "levanta informação sobre", "o que existe
  sobre").
  SKIP quando a pasta `pesquisa/` não existe na raiz do projeto (sinal de
  opt-in ausente — não crie a pasta sozinho, só o comando `/claude:pesquisa`
  faz isso na primeira execução manual), quando a resposta veio só de
  conhecimento já sabido (sem busca real), ou quando o usuário pedir
  explicitamente para não registrar.
---

# Pesquisa Workflow — registro automático de pesquisas

Duas coisas nesta skill: (1) a **regra de comportamento automático** que devo
seguir em projetos que já têm uma pasta `pesquisa/`, e (2) o **formato** das
notas que essa regra e o comando `/claude:pesquisa` usam.

## Regras de comportamento automático

1. **Opt-in por pasta, não por mim.** Só registro pesquisa automaticamente se
   `pesquisa/` já existir na raiz do projeto atual. Se não existir, não crio
   a pasta sozinho — diferente do `git init` automático da skill
   `git-workflow`, aqui a ausência da pasta é sinal deliberado de "não quero
   isso neste projeto". A pasta nasce de duas formas: (a) resposta "sim" à
   pergunta do `/claude:novo-projeto`, ou (b) primeira execução manual do
   comando `/claude:pesquisa`.

2. **Registro automático ao concluir pesquisa não trivial.** Terminei uma
   investigação de múltiplas fontes/buscas sobre um tema (não uma resposta
   trivial de uma linha) → salvo uma nota estruturada em
   `pesquisa/<slug-do-tema>.md` e atualizo o índice em `pesquisa/README.md`,
   sem que o usuário precise pedir. Uso julgamento: uma dúvida rápida
   respondida com o que eu já sabia não vira nota; uma investigação real
   (múltiplas buscas, comparação de fontes, leitura de docs) vira.

3. **Sem duplicar.** Se já existe uma nota sobre o mesmo tema (mesmo slug ou
   tema equivalente), atualizo o arquivo existente em vez de criar um novo —
   mesma regra do `/claude:learning` para lições.

4. **Nunca substitui a resposta ao usuário.** O registro é persistência
   complementar; respondo normalmente na conversa e o arquivo fica como
   histórico consultável depois.

## Formato da nota (`pesquisa/<slug>.md`)

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

## Índice (`pesquisa/README.md`)

Uma tabela simples, entrada mais recente no topo:

```markdown
# Pesquisas

| Data | Tema | Tags |
|---|---|---|
| YYYY-MM-DD | [Título](slug.md) | tag1, tag2 |
```

## Relação com o comando `/claude:pesquisa`

O comando existe para pesquisa **explícita** (o usuário pede um tema
específico) e para o **bootstrap** da pasta (primeira execução cria
`pesquisa/README.md` se ela não existir). Esta skill cobre o caso
**automático** (eu decido registrar, sem o usuário pedir, uma vez que a
pasta já existe). Os dois usam o mesmo formato de nota e o mesmo índice.
