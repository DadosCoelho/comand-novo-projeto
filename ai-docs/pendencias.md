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

- [x] `scripts/medicoes.py` — feito e **validado contra um projeto com 13
      blocos e 20 leituras**: reproduziu sozinho 88 linhas/ponto a quente e 67 a
      frio, contra os 85/65 que nove medições manuais produziram. Erro de 3%,
      lendo só disco.
- [ ] `reference/regua-de-orcamento.md` e `reference/formato-do-plano.md`.
- [x] **Validar contra o Cadin** — feito, e o teste **achou dois defeitos** que
      um projeto vazio nunca teria mostrado (ver abaixo).
- [ ] `reference/regua-de-orcamento.md` e `reference/formato-do-plano.md` — o
      `SKILL.md` já carrega o essencial; estas são detalhamento.

## O que a validação contra um projeto real achou

Nenhum dos dois apareceria num projeto vazio:

1. **Somar só as pontas perde viradas no meio.** Uma sessão com leituras
   0% → 74% → 22% tem par extremo 0→22, que não acusa queda nenhuma e diz 22
   pontos quando foram 96. A soma passou a ser par a par.
2. **Na virada, o que sobrava da janela antiga não foi consumido — expirou.**
   A primeira versão somava `(100 − anterior)` e devolvia 122 pontos para uma
   sessão de 96. Pior: como quase toda sessão com `/clear` deste projeto virou,
   isso **inverteu a régua** (109 linhas/ponto a frio contra 77 a quente, o
   oposto de tudo que oito medições mostravam). Sessão que atravessa a virada
   agora sai do cálculo, com o motivo impresso.

**Correção que isso trouxe ao projeto medido:** o bloco 11 estava registrado
com "~53 pontos de sessão", número que supunha a janela antiga preenchida até
100%. É suposição, não medida — a cota inferior real é ≥18, e o valor está em
algum ponto entre os dois. A régua não foi afetada, porque para aquele bloco
ela foi calculada sobre pontos **semanais**.
