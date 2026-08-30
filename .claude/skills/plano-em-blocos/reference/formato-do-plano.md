# O formato de `ai-docs/plano/`

Referência de consulta: os dois arquivos, campo a campo, com exemplos
preenchidos de um projeto real.

## Por que dois arquivos

| | Muda? | Serve para |
|---|---|---|
| `plano.md` | **sim**, conforme o recorte muda | decidir o que fazer agora |
| `medicoes.md` | **não**, só cresce | derivar a régua |

Fundir os dois faz o registro histórico ser reescrito junto com o plano — e é o
registro que sustenta a régua. Um plano reescrito é normal; um registro
reescrito é um dado perdido.

---

# `plano.md`

```markdown
# Plano de <projeto>

> **Estado:** bloco N de M · última atualização YYYY-MM-DD

## Blocos

| # | Bloco | Entrega verificável | Docs | Módulos que toca | Est. |
|---|---|---|---|---|---|

## Agrupamento em janelas

| Janela | Blocos | Por que juntos | Pontos previstos |
|---|---|---|---|

## Decisões e achados
```

## Os campos, e por que cada um existe

### Entrega verificável

**A frase que se confere rodando, não lendo.** É o critério de "verde" daquele
bloco.

| Ruim | Bom |
|---|---|
| "Implementar concorrência" | "Subir preço 8% custa clientes de forma diferente conforme o concorrente reaja ou não" |
| "Módulo de tributos" | "Simples e Regular simuláveis; ponto de virada observável" |

Bloco sem entrega verificável não é bloco — é intenção. Se não dá para escrever
a frase, o recorte ainda não está pronto.

### Docs a carregar

**Lista exata**, não "a documentação relevante". É esta coluna que torna o
agrupamento em janelas mecânico:

| Bloco | Docs | Decisão |
|---|---|---|
| 14 | 18, **22** | — |
| 15 | **22**, 21 | compartilha o 22 → **mesma sessão** |
| 16 | 01, 03 | não compartilha nada → **`/clear` antes** |

### Módulos que toca

Os que **já existem** e vão ser alterados. É o segundo critério de agrupamento
(dois blocos podem não compartilhar documento e ainda assim compartilhar código
— duas telas que usam os mesmos componentes, por exemplo).

E é o insumo da estimativa: **o que faz o bloco crescer é o que ele toca**, não
o que ele escreve.

### Estimativa

Em linhas, **já corrigida** pelo fator de erro do `medicoes.md`. Se os últimos
blocos erraram +50%, a estimativa nova já nasce 50% maior.

## Exemplo preenchido

```markdown
## Blocos

| # | Bloco | Entrega verificável | Docs | Módulos que toca | Est. |
|---|---|---|---|---|---|
| 14 | Falência e empréstimos | Uma partida que quebra de verdade, pelas três condições | 18, 22 | passo 14, consolidação, catálogo de decisões, bens (garantia) | ~3.900 |
| 15 | Calibração | Os 6 testes de calibração do doc 22 passando | 22, 21 | nenhum novo — mede e ajusta tabelas | ~2.200 |
| 16 | Persistência | Partida sobrevive a fechar o navegador; cliente não grava | 01, 03 | serialização, app novo | ~3.900 |

## Agrupamento em janelas

| Janela | Blocos | Por que juntos | Pontos previstos |
|---|---|---|---|
| A | 14, 15 | compartilham o doc 22; o 15 mede o que o 14 construiu | ~86 |
| B | 16 | troca de camada (motor → web): `/clear` antes | ~60 |
```

## A seção "Decisões e achados"

O que se aprendeu **executando**, e que muda os blocos seguintes. É a parte que
mais se esquece de escrever e mais se lamenta depois.

Duas espécies valem sempre:

- **Achado que desrisca bloco futuro.** "A calibração fechou porque a varredura
  de sementes corrigiu o desvio; medir com uma semente só apontava para o lado
  errado."
- **Decisão que contradiz o que o plano dizia.** Com o porquê, e com a data.

---

# `medicoes.md`

```markdown
# Registro de execução

## Régua deste projeto

| Contexto | N atual | Medições |
|---|---|---|
| Contínua (contexto quente) | 88 | 1 sessão |
| Depois de `/clear` | 67 | 3 sessões |

Fator de erro da estimativa: **+50%** (últimos 4 blocos)

## Blocos

| Bloco | Data | Sessão | Janela in→out | Pontos | Linhas | ÷ | Est. | Erro |
|---|---|---|---|---|---|---|---|---|
| 9 | 22/08 | `9a455f56` | 42% → 84% | 42 | 2.387 | 57 | ~3.000 | −20% |
| 10 | 22/08 | `60acffe4` | 12% → 62% | 50 | 3.368 | 67 | ~2.500 | +35% |
| 11 | 22/08 | `f0352ae4` | 65% → 18% ↻ | ≥18 | 3.841 | — | ~2.500 | +54% |
| 12+13 | 29/08 | `44e693bb` | 0→74→22% ↻ | ≥96 | 6.146 | — | ~4.000 | +54% |
```

## Os campos

### Janela in→out

As duas leituras de `/usage`, cruas. **É o que torna a linha auditável** —
qualquer um confere a subtração sem confiar em quem preencheu.

Com mais de duas leituras, escreva o caminho todo (`0→74→22%`): é ele que
explica um número de pontos maior que a diferença das pontas.

Marque `↻` quando a janela virou no meio.

### Pontos

Soma **par a par**, contando só o avanço dentro de cada janela. Quando houve
virada, escreva `≥N` — é cota inferior, não medida.

### ÷ (linhas por ponto)

**Deixe em branco quando a janela virou.** Dividir linhas por uma cota inferior
infla a razão, e esse erro entra sempre do mesmo lado — foi o que já inverteu
uma régua inteira.

Deixe em branco também em **bloco de desenho**: ele consome orçamento e não
produz linha, e a razão dele não significa nada.

### Sessão

O id curto da transcrição. Serve para o `scripts/medicoes.py` conferir a linha
contra o disco, e para recuperar o que faltar.

## O que nunca escrever

**`(a anotar)`.** Um bloco sem as duas pontas vira rateio, e rateio não alimenta
régua. Se a leitura de abertura não foi feita, peça antes de continuar; se a de
fechamento foi esquecida, rode o `medicoes.py` antes de desistir.

Quando o rateio for inevitável — dois blocos numa sessão só, com uma leitura em
cada ponta do par —, **diga que é rateio e de qual total medido**:

```markdown
| 12 | 29/08 | `44e693bb` | rateio †† | ~26 | 2.179 | — | ~1.500 | +45% |
| 13 | 29/08 | `44e693bb` | rateio †† | ~48 | 3.967 | — | ~2.500 | +59% |

†† Os dois rodaram numa sessão só, medida nas duas pontas (0% → 74%, 74 pontos).
   A divisão acima é proporcional às linhas e é estimativa; o número forte é o
   do par.
```

## Como a régua é recalculada

1. Somar linhas e pontos das sessões **sem virada**, separadas por quente e
   frio.
2. `linhas ÷ pontos` em cada grupo.
3. Comparar com o valor anterior. Mudança grande com amostra pequena é ruído;
   mudança que persiste por dois blocos é a régua se corrigindo.

O `scripts/medicoes.py` faz os três passos e imprime as ressalvas junto — rodá-lo
é mais confiável que refazer a conta à mão.
