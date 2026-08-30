# A régua de orçamento — como medir, e o que o número não diz

Referência de consulta. O `SKILL.md` traz as regras operacionais; aqui está o
**método** por trás delas, para quando algo não bater e for preciso entender por
quê.

## As duas cotas, e qual delas morde

| Cota | O que é | Quando morde |
|---|---|---|
| **Janela de sessão** | 5 h de relógio, a partir do primeiro uso | **Quase sempre** |
| **Cota semanal** | reinicia num dia fixo da semana | Só em projeto comprimido em uma ou duas semanas |

Numa cadência de fim de semana, cada dia de trabalho cai numa semana própria e
custa 5 a 15 dos 100 pontos semanais. **O limitador real é a janela**, e é sobre
ela que o planejamento se faz.

Duas propriedades da janela que decidem quase tudo:

1. **Ela expira por tempo, não por consumo.** Quem está em 74% quando ela vira
   não gastou os 26 restantes — eles se perderam.
2. **Ela é da conta, não do projeto.** Trabalho em outro projeto no mesmo
   intervalo consome a mesma janela e não aparece na medição daqui.

## A régua

```
pontos de sessão = linhas entregues ÷ N
```

| Contexto | N |
|---|---|
| Sessão contínua, contexto quente | **~85** |
| Depois de `/clear` ou sessão nova | **~65** |

A diferença de ~30% é o custo de reconstruir o contexto. Com acerto de cache na
casa de 99%, contexto grande é **barato de manter e caro de reconstruir** — o
`/clear` troca o barato pelo caro.

### De onde esses números vieram

Nove medições de um projeto TypeScript com testes pesados e documentação densa:

| Método | Amostras | Linhas por ponto **semanal** |
|---|---|---|
| Sessão contínua, sem `/clear` | 2 | **898** (917 e 878, a 4% uma da outra) |
| Bloco isolado, com `/clear` | 3 | **637 ± 6%** (597, 674, 640) |

Depois, um script lendo só disco reproduziu a régua por caminho independente:
**88 a quente e 67 a frio**, contra os 85/65 construídos à mão. Três por cento
de erro.

> **Trate 85/65 como ponto de partida emprestado, não como verdade.** Um projeto
> de scripts curtos, ou de front-end com muito componente, terá outra razão. A
> régua de cada projeto vive no `medicoes.md` e converge para a dele a cada
> bloco.

## A aritmética dos pontos

Dentro de uma janela, é subtração simples: `saída − entrada`.

Quando a janela vira no meio, **não é**. Três erros possíveis, todos já
cometidos:

### Erro 1 — comparar só a primeira e a última leitura

Leituras `0% → 74% → 22%`. O par extremo (0 → 22) não acusa queda nenhuma e diz
22 pontos. Foram 96.

**Some par a par**, percorrendo todas as leituras.

### Erro 2 — contar o que sobrou da janela antiga

`(100 − 74) + 22 = 48`? Não. Os 26 que faltavam para 100 **não foram gastos** —
a janela expirou por tempo. Somá-los conta ociosidade como trabalho, e produziu
122 pontos numa sessão que consumiu 96.

**Some só o avanço dentro de cada janela.** Depois de uma virada, a janela nova
começa em 0 — supondo que nenhum outro projeto a tenha consumido antes, que é
justamente o que não se pode garantir. Por isso o resultado é **cota inferior**.

### Erro 3 — deixar sessões que viraram dentro da régua

Este é o pior, porque não parece erro. Os pontos de uma sessão que virou são
cota inferior, então `linhas ÷ pontos` sai **inflado** — e infla mais quanto mais
cedo a janela virou.

Num projeto real, quase toda sessão com `/clear` havia atravessado uma virada. O
efeito se concentrou num lado só e **inverteu a régua**:

| | Com as viradas dentro | Sem elas |
|---|---|---|
| Contínua | 77 linhas/ponto | **88** |
| Depois de `/clear` | 109 linhas/ponto | **67** |

A primeira coluna diria que `/clear` é mais eficiente — o oposto do que oito
medições mostravam.

> **Um dado ruim que entra sempre no mesmo lado da comparação não vira ruído,
> vira viés — e viés não se detecta olhando a dispersão.** O que o detectou foi
> a conclusão sair contrária às medições anteriores, o que só é possível quando
> existem medições anteriores para contradizer.

**Sessão que atravessou a virada fica fora do cálculo da régua.** Ela ainda
entra no registro, marcada, porque o custo foi real — só não é comparável.

## A régua mede implementação, não desenho

Um trecho de trabalho que foi **conversa de decisão** consome orçamento e quase
não produz linha. Medido pela régua de implementação, dá um número alarmante e
sem significado: num caso real, **10 linhas por ponto** contra os 85 esperados,
sem nada estar errado.

Ao registrar, diga qual dos dois foi:

- **Bloco de implementação** — entra na régua.
- **Bloco de desenho** — entra no registro com o custo anotado e a **razão em
  branco**. Misturá-lo com os de implementação estraga a régua para os dois.

## Estimar: linhas novas **mais** pontos de contato

O erro de estimativa observado foi **sempre para baixo**, e sempre pela mesma
causa:

| Bloco | Estimado | Real | Erro |
|---|---|---|---|
| A | ~3.000 | 2.387 | −20% |
| B | ~2.500 | 3.368 | +35% |
| C | ~2.500 | 3.841 | +54% |
| D | ~1.500 | 2.179 | +45% |
| E | ~2.500 | 3.967 | +59% |

A causa não é o que o bloco **escreve** — é o que ele **toca**. Um bloco que
acrescenta um módulo isolado custa o que escreve; um que liga um módulo novo a
oito existentes custa também o ajuste dos oito, **inclusive os testes deles**.

Estimar pelos documentos a carregar erra. Estimar por linhas novas + pontos de
contato acerta melhor.

> **A régua corrigida precisa ser reaplicada.** A correção acima foi escrita
> depois do bloco C e **não foi aplicada** aos blocos D e E — que erraram +45% e
> +59%, a mesma magnitude do erro que ela existia para evitar. Ao estimar um
> bloco novo, puxe o fator do `medicoes.md` e aplique.

## Planejar: minimizar partidas frias

Cada bloco que **abre** uma janela paga ~30% a mais. O que se minimiza não é o
número de janelas — é o **número de partidas frias, ponderado pelo tamanho do
bloco que abre**:

| Bloco | Frio (÷65) | Quente (÷85) | Penalidade |
|---|---|---|---|
| 3.900 linhas | 60 pts | 46 pts | **14** |
| 1.300 linhas | 20 pts | 15 pts | **5** |

Daí as três regras de empacotamento:

1. **Agrupar por documento ou módulo compartilhado** — é o que mantém o cache
   quente. O plano já tem a coluna "Docs a carregar"; a comparação é mecânica.
2. **O menor bloco abre a janela**, quando a dependência permitir.
3. **Blocos agrupados precisam ser encostados no relógio.** O cache tem TTL de
   ~1 h; dois blocos na mesma sessão separados por uma noite pagam frio do mesmo
   jeito.

**Teto prático de ~85 pontos por janela**, não 100: deixa margem para o erro de
estimativa, e 100% significa parar no meio de um bloco — e bloco tem de terminar
verde.

### Quando o empacotamento não fecha

Diga isso, em vez de fingir. Num caso real, cinco blocos de 1.300 a 4.650 linhas
não pareavam: dois deles somavam 118 pontos, muito acima do teto. O resultado
foram quatro janelas com quatro partidas frias, e **57 dos 255 pontos eram
desperdício estrutural** — não má organização, mas tamanho de bloco.

Saber disso de antemão é melhor que descobrir no meio.

## `/clear` e sessão nova são a mesma coisa

Para o orçamento, não há diferença: contexto zerado, cache perdido, ÷65. E
**nenhum dos dois reseta a janela** — ela é da conta e do relógio.

Empiricamente, o `/clear` aparece registrado nas primeiras linhas de um arquivo
de transcrição **novo**, nunca no meio de um existente. As duas diferenças que
sobram são pequenas: atrito (o `/clear` mantém o diretório de trabalho) e rastro
(ele deixa registrado como aquela sessão nasceu, o que torna a medição
auditável).

## Recuperar o que não foi anotado

As transcrições ficam em `~/.claude/projects/<slug>/*.jsonl` e são legíveis.
Delas saem, sem depender da memória de ninguém:

1. **As leituras de `/usage` já feitas** — o texto `Current session: N% used`
   fica gravado, com timestamp.
2. **Se a sessão nasceu de `/clear`** — o comando fica nas primeiras linhas.
3. **Quando cada sessão começou e terminou** — dos timestamps.

`scripts/medicoes.py` faz isso e cruza com o `git log`. Rode-o ao adotar a skill
num projeto que já tem história: ele nasce com a régua daquele projeto em vez do
ponto de partida emprestado.

**É rede de segurança, não substituto.** Só recupera o que foi digitado.

## Medir tempo de execução (não de orçamento)

Uma armadilha vizinha, para quando o projeto tiver teste de desempenho:

- **Aqueça antes e meça em processo novo.** A frio mede-se o JIT — 22 ms contra
  0,62 ms no mesmo teste.
- **Repetir a medição no mesmo processo mede o GC** — 3,6 ms e 11,7 ms conforme
  a ordem.
- **Rode a suíte sem paralelismo de arquivos.** Com 16 arquivos concorrendo, o
  mesmo teste deu 0,9 ms sozinho e 14 ms disputando CPU.
