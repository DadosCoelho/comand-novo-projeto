---
description: Cria ou revisa um plano de trabalho em blocos medidos em ai-docs/plano/, com orçamento de sessão.
argument-hint: [o que se quer construir]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /claude:plano — planejar trabalho longo em blocos medidos

Cria ou revisa o plano de `$ARGUMENTS` em `ai-docs/plano/`. A primeira execução
no projeto cria a pasta — a partir daí, a skill `plano-em-blocos` passa a agir
sozinha: pede as leituras de `/usage`, decide sessão e mantém o registro.

**Leia a skill `plano-em-blocos` antes de executar este comando.** Ela carrega
a régua, o critério de agrupamento e o formato dos arquivos; este comando é só
o gatilho manual.

## Argumentos

- `$ARGUMENTS` — o que se quer construir. Se vazio, **pergunte** ao usuário
  antes de continuar.

## Passos

### 1. Decidir se o trabalho merece um plano em blocos

Só merece se **não couber numa sessão**: mais de ~3 módulos substanciais,
estimativa acima de ~6.000 linhas, ou uma sequência declarada de entregas.

Se couber numa sessão, **diga isso e não crie a pasta** — a skill seria puro
overhead. Ofereça fazer o trabalho direto.

### 2. Se `ai-docs/plano/` não existe, criar

Crie `ai-docs/plano/` com `plano.md` e `medicoes.md` nos formatos da skill.
Se o projeto **já tem história** (commits, e talvez um plano informal em outro
arquivo), não comece do zero:

- Rode `scripts/medicoes.py` da skill, ou extraia à mão de
  `~/.claude/projects/<slug>/*.jsonl` as leituras de `/usage` já feitas.
- Cruze com `git log` para casar blocos, datas e linhas.
- **Nasça com a régua daquele projeto**, não com o ponto de partida emprestado.

### 3. Recortar os blocos

Cada bloco declara: entrega verificável, documentos a carregar, módulos que
toca, e estimativa em linhas **já corrigida** pelo fator de erro observado (se
houver história) ou com margem declarada (se não houver).

Regras de recorte:

- Um bloco termina **verde**: compila, testes passam, um commit, algo rodando.
- Bloco que não cabe numa janela é dois blocos.
- Bloco que não tem entrega verificável não é um bloco — é uma intenção.

### 4. Agrupar em janelas

Aplique o critério da skill: blocos que compartilham documentos ou módulos
ficam juntos; quebra onde o conjunto muda; o menor bloco abre a janela;
agrupados precisam ser encostados no relógio.

Monte a tabela de janelas com os pontos previstos, e **diga quando dois blocos
afins não couberem juntos** em vez de empacotar um estouro.

### 5. Confirmar o recorte com o usuário

Apresente os blocos e o agrupamento e **pergunte** antes de começar a executar.
Um bloco mal recortado custa mais que o tempo de recortá-lo bem.

### 6. Pedir a leitura de abertura

Antes de carregar o primeiro documento do primeiro bloco, peça `/usage` e
registre em `medicoes.md`. Sem a leitura de abertura, o bloco vira rateio.

## Revisão de um plano existente

Se `ai-docs/plano/` já existe, este comando **revisa** em vez de criar:

- Atualiza os blocos conforme o usuário mudou de ideia.
- Reagrupa as janelas se o recorte mudou.
- **Reaplica o fator de erro** às estimativas dos blocos ainda abertos — é o
  passo que mais se esquece, e o que faz o mesmo erro se repetir.
- Registra em "Decisões e achados" o que se aprendeu executando.

## O que não fazer

- **Não crie a pasta** se o trabalho cabe numa sessão.
- **Não escreva "(a anotar)"** numa linha de medição. Se falta leitura, peça
  ou recupere da transcrição.
- **Não invente pontos.** Toda linha do registro precisa ter as duas leituras,
  ou dizer explicitamente que é rateio e de qual total medido.
