# Pendências

> Trabalho decidido e ainda não feito. Uma linha por item, com o **porquê** —
> pendência sem motivo registrado vira pendência que ninguém sabe se ainda vale.

## ✅ Sincronizar a skill `plano-em-blocos` (feito em 29/08/2026)

A skill global `plano-em-blocos` foi criada em `~/.claude/skills/` e o comando
`/claude:plano` em `~/.claude/commands/claude/`. O `/claude:novo-projeto` global
já foi editado (passo 6 novo). Tudo foi trazido para este repositório, que é a
fonte da verdade dos comandos e dos templates, e registrado no `install-global`.

### O que a skill faz

Executa trabalho longo em **blocos medidos**: recorta o trabalho em blocos que
terminam verdes, agrupa em janelas por documento/módulo compartilhado, pede
`/usage` nas duas pontas de cada bloco e `/clear` só quando a troca de contexto
justifica. Mantém `ai-docs/plano/{plano.md,medicoes.md}` e uma régua de
orçamento que converge para a do projeto a cada bloco.

Opt-in por pasta, igual ao `pesquisa-workflow`: só age se `ai-docs/plano/`
existir.

### Itens

- [x] **Copiar `/claude:plano`** para `.claude/commands/claude/plano.md` deste
      repo (a cópia canônica) e para os dois templates
      (`templates/harness-{lite,full}/.claude/commands/claude/`).
- [x] **Sincronizar `novo-projeto.md`** — a cópia deste repo está defasada em
      relação à global. As mudanças foram: passo 6 novo (pergunta sobre plano
      em blocos), renumeração do antigo passo 6 para 7, `/claude:plano` na
      lista de comandos do `lite`, aviso sobre a skill global no relatório, e
      uma regra nova na seção "Regras".
- [x] **Acrescentar a linha na tabela de comandos** do `CLAUDE.md` dos dois
      templates:

      | `/claude:plano [o que construir]` | Planeja trabalho longo em blocos medidos em `ai-docs/plano/`, com orçamento de sessão (cria a pasta na primeira execução). |

- [x] **Decidir se o `harness-lite` deve embarcar o comando.** **Sim, nos dois.**
      O argumento que decidiu não foi "projeto pequeno às vezes cresce" — foi que
      **o custo de embarcar é zero**: comando e skill são opt-in por pasta, e sem
      `ai-docs/plano/` nenhum dos dois faz nada. Deixar de fora só criaria o caso
      em que o projeto cresce e o comando não está lá.
- [x] **Registrar no `install-global`** (`.sh` e `.ps1`) — era o item que faltava
      na lista original: o repo é a fonte, mas quem propaga para `~/.claude/` é
      esse script, e uma skill fora dele nunca chega na máquina de ninguém.

### A regra nova das "Regras" do `novo-projeto`

Vale registrar aqui porque vale para os templates inteiros, não só para o
comando:

> **Nada de conteúdo de projeto vai para `.claude/`.** Ali moram comandos,
> skills, scripts e settings — *como* eu trabalho. O que eu produzo **sobre** o
> trabalho (lições, plano, medições) vai para `ai-docs/`; o produto e suas
> fontes (código, especificação, `pesquisa/`) ficam na raiz.

Ela saiu de uma pergunta concreta: `plano/` deveria ficar em `.claude/`? Não —
o plano costuma ser o documento mais consultado depois da especificação, e
`.claude/` mistura versionado com local (`settings.local.json`). E `pesquisa/`
tampouco: no projeto Cadin, as notas de pesquisa são citadas **31 vezes por 13
dos 24 documentos** da especificação — são fonte, não subproduto.

## Fora deste repositório (para a mesma sessão)

Peças da skill que ficaram para a janela seguinte, e que **não** dependem
deste repo:

- [ ] `~/.claude/skills/plano-em-blocos/scripts/medicoes.py` — extrai as
      leituras de `/usage` das transcrições em `~/.claude/projects/<slug>/*.jsonl`,
      cruza com `git log` e imprime a régua do projeto. Já foi feito à mão uma
      vez (recuperou 20 leituras do Cadin); falta virar ferramenta.
- [ ] `reference/regua-de-orcamento.md` e `reference/formato-do-plano.md`.
- [ ] **Validar contra o Cadin** — 13 blocos e 20 leituras de história para o
      script conferir. É o teste real do formato: valida contra um projeto com
      passado, não contra um vazio.
