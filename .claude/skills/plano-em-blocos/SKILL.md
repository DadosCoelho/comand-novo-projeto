---
name: plano-em-blocos
description: Executa trabalho longo em blocos medidos — planeja em `ai-docs/plano/`, agrupa blocos por contexto compartilhado, pede `/usage` nas duas pontas de cada bloco e `/clear` só quando a troca de contexto justifica. Opt-in por projeto: só age se `ai-docs/plano/` já existir. Transforma orçamento de sessão de intuição em régua medida, que melhora a cada bloco.
trigger: >
  TRIGGER proativamente quando o trabalho pedido não cabe numa sessão —
  mais de ~3 módulos substanciais, estimativa acima de ~6.000 linhas, ou o
  usuário descreve uma sequência de entregas ("implemente X, depois Y, depois
  Z"). Também trigger ao retomar trabalho num projeto que já tem
  `ai-docs/plano/`: antes de abrir um bloco, ao fechá-lo, e sempre que a
  decisão "sigo ou paro" depender de orçamento. E quando o usuário perguntar
  sobre consumo, `/usage`, `/clear`, quando parar, ou como dividir um trabalho
  grande.
  SKIP quando `ai-docs/plano/` não existe (opt-in ausente — não crie a pasta
  sozinho; quem a cria é o comando `/claude:plano`), quando a tarefa cabe
  numa sessão (aí a skill é puro overhead), ou quando o usuário pedir
  explicitamente para não medir.
---

# Plano em blocos — trabalho longo, medido

Duas coisas nesta skill: (1) as **regras de comportamento** que sigo em
projetos que executam trabalho longo em blocos, e (2) a **régua de orçamento**
que torna as decisões de sessão aritmética em vez de intuição.

Ela existe porque três coisas dão errado sozinhas em todo projeto longo, e
nenhuma por falta de cuidado:

1. **A estimativa erra sempre para o mesmo lado e nunca se corrige.**
2. **A medição se perde** — "anoto depois" é "não anotei".
3. **A decisão de sessão é tomada por intuição**, e a intuição errada é cara e
   invisível.

## O que é um bloco

Uma unidade de trabalho que **termina verde**: compila, testes passam, um
commit, e algo verificável rodando. É o que torna o trabalho interrompível —
com blocos verdes, parar numa fronteira qualquer (fim de janela, fim de dia,
telefone tocando) não deixa nada pela metade.

Um bloco declara, no plano:

- **Entrega verificável** — a frase que se confere rodando, não lendo.
- **Documentos a carregar** — quais, exatamente.
- **Módulos que toca** — os que existem e vão ser alterados.
- **Estimativa em linhas**, já corrigida pelo fator de erro observado.

## Regras de comportamento automático

### 1. Opt-in por pasta, não por mim

Só ajo se `ai-docs/plano/` já existir na raiz do projeto. Se não existir, **não
crio sozinho** — a ausência é sinal deliberado de "não quero isso aqui". Mesma
disciplina do `pesquisa-workflow`. A pasta nasce de duas formas: resposta "sim"
no `/claude:novo-projeto`, ou primeira execução do `/claude:plano`.

### 2. Onde cada coisa mora

| | O quê | Exemplos |
|---|---|---|
| `.claude/` | *como* eu trabalho | commands, skills, scripts, settings |
| `ai-docs/` | o que produzi **sobre** o trabalho | `lessons.md`, `plano/` |
| raiz | o produto e suas **fontes** | código, especificação, `pesquisa/` |

O plano não é configuração — é conteúdo de projeto, muitas vezes o documento
mais consultado depois da especificação. Não vai para `.claude/`.

Dentro de `ai-docs/plano/`:

- **`plano.md`** — os blocos, o agrupamento em janelas, o estado. **Muda** conforme
  o usuário muda de ideia.
- **`medicoes.md`** — bloco, data, linhas, pontos, régua. **Só cresce**, e é dele
  que a régua sai.

Dois arquivos e não um: fundir faz o registro histórico ser reescrito junto com
o plano, e é o registro que sustenta a régua.

### 3. Planejar antes da primeira linha

Trabalho que não cabe numa sessão → escrevo `plano.md` **antes** de começar, e
confirmo o recorte com o usuário. Um bloco mal recortado custa mais que o tempo
de recortá-lo bem.

### 4. Agrupar blocos por contexto compartilhado

**Esta é a regra que mais economiza, e ela é de planejamento — não de decisão
por bloco.**

Cada bloco que **abre** uma janela paga ~30% a mais, porque começa com o
contexto frio. Então o que se minimiza não é o número de janelas: é o **número
de partidas frias, ponderado pelo tamanho do bloco que abre**.

Critério mecânico de agrupamento:

- **Blocos consecutivos que compartilham documentos ou módulos ficam na mesma
  janela.** É por isso que o contexto quente é mais barato — os documentos já
  estão carregados e cacheados.
- **Quebra-se onde o conjunto muda** (troca de camada, de domínio, de stack).
  Aí, e só aí, o `/clear` se paga.
- **O menor bloco abre a janela**, quando a dependência permitir — a penalidade
  do frio é proporcional ao tamanho do bloco que a paga.
- **Blocos agrupados precisam ser encostados no relógio.** O cache tem TTL de
  ~1 h: dois blocos na mesma sessão separados por uma noite pagam frio do mesmo
  jeito. Quando isso for inevitável, digo que a economia sumiu — e aí tanto faz
  limpar, o que pelo menos deixa o rastro certo na medição.

Se dois blocos afins **não cabem** na mesma janela, digo isso explicitamente em
vez de fingir um empacotamento que vai estourar.

### 5. As duas leituras, e nunca no meio

Eu **não consigo** rodar `/usage` nem `/clear` — são comandos do harness. O que
faço é pedir, nos dois momentos em que a leitura vale:

- **Ao abrir a primeira janela de um dia de trabalho**, antes de carregar o
  primeiro documento.
- **Ao fechar cada bloco**, depois de ele estar verde.

**Nunca no meio de um bloco.** Interromper o trabalho para pedir número vira
ruído, e ruído faz o usuário desligar a skill.

### 6. Nunca escrever "(a anotar)"

Um bloco sem as duas pontas vira rateio, e rateio não alimenta régua. Se a
leitura de abertura não foi feita, peço antes de continuar. Se a de fechamento
foi esquecida, tento **recuperar da transcrição** (ver abaixo) antes de desistir.

### 7. Medir e atualizar a régua do projeto

Ao fechar o bloco:

1. Conto as linhas eu mesmo — `git diff --numstat <commit-anterior> <commit>` —
   separadas por código, teste, script e documentação.
2. Caso com a leitura de `/usage` e registro em `medicoes.md`.
3. **Recalculo a régua daquele projeto** e comparo com a estimativa.
4. Se a estimativa errou, **anoto o fator** — e aplico no bloco seguinte.

### 8. Reaplicar o fator de erro à força

Uma régua corrigida que ninguém reaplica não corrige nada. Ao estimar um bloco
novo, puxo o fator de erro observado do `medicoes.md` e o aplico. Se os últimos
blocos erraram +50%, o próximo já nasce 50% maior.

**A causa mais comum de subestimar não é o que o bloco escreve — é o que ele
toca.** Um bloco que acrescenta um módulo isolado custa o que escreve; um que
liga um módulo novo a oito existentes custa também o ajuste dos oito, inclusive
os testes deles. Estimar pelos documentos a carregar erra; estimar por **linhas
novas + pontos de contato** acerta melhor.

### 9. Decidir "sigo, limpo ou paro" com a régua

Ao fechar um bloco, com a leitura na mão:

| Situação | Decisão |
|---|---|
| Sobra folga **e** o próximo bloco compartilha documento/módulo | **Segue na mesma sessão** |
| Sobra folga **mas** o próximo troca de contexto | **Peço `/clear`**, dizendo por quê |
| O próximo bloco não cabe na folga | **Paro**, e digo quando a janela volta |

Nunca abro um bloco grande que sabidamente não cabe. Trabalho que atravessa a
virada da janela **não é medível pela sessão**, só pela cota semanal — e perder
a medição é o custo que esta skill existe para evitar.

## A régua

`pontos = linhas ÷ N`, onde N depende de o contexto estar quente:

| Contexto | N (linhas por ponto de sessão) |
|---|---|
| Sessão contínua, contexto quente | **~85** |
| Depois de `/clear` ou sessão nova | **~65** |

**Esses números são um ponto de partida declarado, não uma verdade.** Vieram de
nove medições de um projeto TypeScript com testes pesados e documentação densa.
Um projeto de scripts curtos terá outra razão. A régua de cada projeto vive em
`medicoes.md` e **converge para a dele** a cada bloco medido.

Duas coisas que a régua não cobre e que precisam ser ditas quando aparecem:

- **A janela e a cota são da conta, não do projeto.** Trabalho em outro projeto
  consome as mesmas. Uma leitura estranha pode ter causa fora daqui.
- **`/clear` e abrir sessão nova são a mesma coisa** para o orçamento: contexto
  zerado, cache perdido, ÷65. Nenhum dos dois reseta a janela.

## Recuperar medição perdida

As transcrições ficam em `~/.claude/projects/<slug-do-projeto>/*.jsonl` e são
legíveis. Delas saem três coisas que eu não preciso pedir a ninguém:

1. **As leituras de `/usage`** já feitas, com timestamp e sessão — o texto
   `Current session: N% used` está gravado.
2. **Se a sessão nasceu de `/clear`** — o comando fica registrado nas primeiras
   linhas do arquivo.
3. **Quando cada sessão começou e terminou** — dos timestamps, o que dá a janela.

Cruzando com `git log`, dá para **reconstruir a régua retroativamente**, mesmo
sem ninguém ter anotado nada. Use `scripts/medicoes.py` (quando existir) ou
extraia direto.

Isso é **rede de segurança, não substituto**: só recupera o que foi digitado. Se
o `/usage` nunca foi rodado num bloco, não há nada lá.

### Duas armadilhas na aritmética, aprendidas ao validar o script

**1. Na virada, o que sobrava da janela antiga não foi consumido — expirou.** A
janela é de 5 h de relógio: quem estava em 74% quando ela virou não gastou os
26 restantes. Somar `(100 − anterior) + seguinte` conta ociosidade como
trabalho.

**2. Sessão que atravessou a virada fica fora da régua.** Os pontos dela são
cota inferior, então dividir linhas por eles infla a razão — e infla mais
quanto mais cedo a janela virou. Num projeto real isso chegou a **inverter a
régua**: 109 linhas/ponto a frio contra 77 a quente, o oposto do que oito
medições mostravam.

> Um dado ruim que entra sempre no mesmo lado da comparação não vira ruído,
> vira **viés** — e viés não se detecta olhando a dispersão. O que o detectou
> foi a conclusão sair contrária às medições anteriores.

### A régua mede implementação, não desenho

Um trecho de trabalho que foi **conversa de desenho** consome orçamento e quase
não produz linha. Medido pela régua de implementação, dá um número alarmante e
sem sentido — 10 linhas por ponto contra os 85 esperados, sem nada estar
errado.

Ao registrar, **diga qual dos dois foi**. Blocos de desenho entram no
`medicoes.md` com o custo anotado e a razão em branco; misturá-los com os de
implementação estraga a régua para os dois.

## Formato dos arquivos

### `ai-docs/plano/plano.md`

```markdown
# Plano de <projeto>

> **Estado:** bloco N de M · última atualização YYYY-MM-DD

## Blocos

| # | Bloco | Entrega verificável | Docs | Módulos que toca | Est. |
|---|---|---|---|---|---|
| 1 | ... | ... | ... | ... | ~N linhas |

## Agrupamento em janelas

| Janela | Blocos | Por que juntos | Pontos previstos |
|---|---|---|---|
| A | 1, 2 | compartilham o doc X | ~N |
| B | 3 | troca de camada → `/clear` antes | ~N |

## Decisões e achados
<o que se aprendeu executando, e que muda blocos futuros>
```

### `ai-docs/plano/medicoes.md`

```markdown
# Registro de execução

## Régua deste projeto

| Contexto | N atual | Medições |
|---|---|---|
| Quente | ... | ... |
| Frio | ... | ... |

Fator de erro da estimativa: **+N%** (últimos M blocos)

## Blocos

| Bloco | Data | Sessão | Janela in→out | Pontos | Linhas | ÷ | Est. | Erro |
|---|---|---|---|---|---|---|---|---|
| 1 | ... | `abc12345` | 0% → 42% | 42 | 2.387 | 57 | ~3.000 | −20% |
```

O `Janela in→out` é o que torna a linha auditável: qualquer um confere a
subtração. Quando a janela vira no meio, o cálculo é `(100 − entrada) + saída`,
e a linha precisa dizer que virou.

## O que esta skill não faz

- **Não roda `/usage` nem `/clear`.** Pede; o usuário digita. Dois toques por bloco.
- **Não reseta janela nem cota.**
- **Não decide sozinha o que é um bloco** — propõe o recorte, o usuário ajusta.
- **Não serve para tarefa curta.** Numa coisa que cabe numa sessão, é overhead.

## Referência

Detalhe do que está resumido acima, para consultar quando algo não bater:

- [`reference/regua-de-orcamento.md`](reference/regua-de-orcamento.md) — o
  método: as duas cotas, a aritmética dos pontos (e os três erros já cometidos
  nela), como estimar por pontos de contato, como empacotar janelas, e como
  recuperar medição das transcrições.
- [`reference/formato-do-plano.md`](reference/formato-do-plano.md) — os dois
  arquivos campo a campo, com exemplos preenchidos de um projeto real e o que
  nunca escrever neles.
- `scripts/medicoes.py` — lê as transcrições e o `git log` e imprime a régua do
  projeto. Rode-o ao adotar a skill num projeto que já tem história.

## Relacionado

- `git-workflow` — o commit que fecha cada bloco verde.
- `pesquisa-workflow` — mesma disciplina de opt-in por pasta.
- `/claude:learning` — lição pontual vai para `ai-docs/lessons.md`; o que muda a
  régua vai para `medicoes.md`. Não duplicar.
