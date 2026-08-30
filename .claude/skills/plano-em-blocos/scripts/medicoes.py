#!/usr/bin/env python3
"""
Extrai a régua de orçamento de um projeto a partir do que já está em disco.

Duas fontes, nenhuma delas precisando que alguém tenha anotado nada:

1. **As transcrições** em `~/.claude/projects/<slug>/*.jsonl` — delas saem as
   leituras de `/usage` já feitas (o texto `Current session: N% used` fica
   gravado), o instante de cada uma, e se a sessão nasceu de um `/clear`.
2. **O git** — dele saem os commits, as datas e as linhas de cada um.

Cruzando as duas, sai quanto custou cada trecho de trabalho e quantas linhas
por ponto de sessão o projeto produz.

## O que este script NÃO tenta fazer

**Casar leitura com bloco automaticamente.** A correspondência entre "sessão
que foi de 12% a 62%" e "bloco 10 do plano" depende de julgamento — uma sessão
pode conter dois blocos, um bloco pode atravessar duas sessões, e parte do
consumo pode ter vindo de conversa que não virou linha nenhuma. Um casador
automático erraria em silêncio, que é pior que não existir.

O que o script faz é entregar o **material bruto já organizado**: por sessão, a
leitura de entrada e a de saída, se a janela virou no meio, e os commits que
caem naquele intervalo. A atribuição a blocos é de quem lê.

## Uso

    python medicoes.py                    # projeto = diretório atual
    python medicoes.py --projeto <path>
    python medicoes.py --sem-git          # só as leituras, sem cruzar commits

Sem dependências além da biblioteca padrão.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

# O texto que o `/usage` imprime. Se o formato mudar, é aqui que se conserta —
# e o script avisa quando não acha nada, em vez de devolver uma tabela vazia
# como se o projeto não tivesse história.
PADRAO_LEITURA = re.compile(
    r"Current session:\s*(\d+)%\s*used.*?Current week[^:]*:\s*(\d+)%\s*used",
    re.S,
)
PADRAO_CLEAR = re.compile(r"<command-name>/clear</command-name>")


# ─── Modelo ──────────────────────────────────────────────────────────────────


@dataclass
class Leitura:
    quando: datetime
    sessao: str
    janela: int
    semana: int


@dataclass
class Sessao:
    id: str
    arquivo: Path
    comecou_com_clear: bool = False
    leituras: list[Leitura] = field(default_factory=list)
    primeiro_evento: datetime | None = None
    ultimo_evento: datetime | None = None

    @property
    def entrada(self) -> Leitura | None:
        return self.leituras[0] if self.leituras else None

    @property
    def saida(self) -> Leitura | None:
        return self.leituras[-1] if len(self.leituras) > 1 else None

    @property
    def viradas(self) -> int:
        """Quantas vezes a janela virou no meio da sessão."""
        return sum(
            1
            for anterior, seguinte in zip(self.leituras, self.leituras[1:])
            if seguinte.janela < anterior.janela
        )

    @property
    def virou(self) -> bool:
        return self.viradas > 0

    @property
    def pontos(self) -> int | None:
        """
        Pontos de sessão consumidos, somando **par a par** todas as leituras.

        Não basta comparar a primeira com a última: uma sessão com leituras
        0% → 74% → 22% consumiu ~48 pontos e atravessou a virada, mas o par
        extremo (0 → 22) diz 22 e não acusa virada nenhuma. Foi exatamente o que
        aconteceu na sessão que escreveu este script, e é a razão de a soma ser
        por pares.

        **Na virada, o que sobrava da janela antiga NÃO entra na conta.** A
        janela expira por tempo, não por consumo: quem estava em 74% quando ela
        virou não gastou os 26 restantes — eles se perderam. Somar
        `(100 − anterior)` seria contar como trabalho o que foi ociosidade, e é
        o erro que a primeira versão deste script cometeu (deu 122 pontos numa
        sessão que consumiu 96).

        O que se soma é o avanço **dentro de cada janela**. Depois de uma
        virada, a janela nova começa em 0 — supondo que nenhum outro projeto a
        tenha consumido antes desta leitura, que é justamente o que não se pode
        garantir. Daí o resultado ser **cota inferior**, e daí uma sessão que
        atravessa a virada não ser comparável a uma medida limpa.
        """
        if len(self.leituras) < 2:
            return None
        total = 0
        anterior_na_janela = self.leituras[0].janela
        for seguinte in self.leituras[1:]:
            if seguinte.janela < anterior_na_janela:
                # Virou: o trecho da janela nova conta a partir do zero.
                total += seguinte.janela
            else:
                total += seguinte.janela - anterior_na_janela
            anterior_na_janela = seguinte.janela
        return total

    @property
    def pontos_semana(self) -> int | None:
        e, s = self.entrada, self.saida
        return None if e is None or s is None else s.semana - e.semana


@dataclass
class Commit:
    sha: str
    quando: datetime
    assunto: str
    linhas: int


# ─── Leitura das transcrições ────────────────────────────────────────────────


def slug_do_projeto(caminho: Path) -> str:
    r"""
    Converte o caminho do projeto no slug que o Claude Code usa para nomear a
    pasta de transcrições.

    Cada `:`, `\` e `/` vira **um** hífen — sem colapsar a sequência. É o que faz
    `C:\Users` virar `C--Users` e não `C-Users`, e foi o primeiro motivo de o
    script não achar a pasta de um projeto que estava bem ali.
    """
    texto = str(caminho.resolve())
    for separador in (":", "\\", "/"):
        texto = texto.replace(separador, "-")
    return texto.strip("-").replace(" ", "-")


def achar_transcricoes(projeto: Path) -> Path | None:
    base = Path.home() / ".claude" / "projects"
    if not base.is_dir():
        return None

    # Sem diferenciar maiúsculas: `Path.resolve()` devolve `C:\...` no Windows,
    # e o slug gravado costuma ter a letra do drive minúscula — ela segue o caso
    # com que o caminho entrou na sessão, não o do sistema de arquivos.
    alvo = slug_do_projeto(projeto).lower()
    for d in base.iterdir():
        if d.is_dir() and d.name.lower() == alvo:
            return d

    # O esquema do slug já mudou entre versões do Claude Code. Em vez de
    # depender do formato exato, cai para o que termina com o nome da pasta —
    # e só aceita se houver exatamente um candidato, para não medir o projeto
    # errado em silêncio.
    nome = projeto.resolve().name.lower()
    candidatos = [d for d in base.iterdir() if d.is_dir() and d.name.lower().endswith(nome)]
    return candidatos[0] if len(candidatos) == 1 else None


def _quando(registro: dict) -> datetime | None:
    bruto = registro.get("timestamp")
    if not bruto:
        return None
    try:
        return datetime.fromisoformat(bruto.replace("Z", "+00:00"))
    except ValueError:
        return None


def ler_sessoes(pasta: Path) -> list[Sessao]:
    sessoes: list[Sessao] = []

    for arquivo in sorted(pasta.glob("*.jsonl")):
        sessao = Sessao(id=arquivo.stem[:8], arquivo=arquivo)
        for numero, linha in enumerate(arquivo.open(encoding="utf-8", errors="replace"), 1):
            try:
                registro = json.loads(linha)
            except json.JSONDecodeError:
                continue

            quando = _quando(registro)
            if quando is not None:
                if sessao.primeiro_evento is None:
                    sessao.primeiro_evento = quando
                sessao.ultimo_evento = quando

            # O conteúdo pode ser string ou lista de blocos; o texto cru do
            # registro serve para os dois casos, e é o que o regex quer.
            cru = linha

            # `/clear` só conta como origem da sessão se estiver no começo do
            # arquivo — mais adiante seria um eco (um grep meu, por exemplo),
            # não o comando de verdade.
            if numero <= 5 and PADRAO_CLEAR.search(cru):
                sessao.comecou_com_clear = True

            if "Current session" not in cru:
                continue

            # O JSON escapa as quebras de linha; desescapa para o regex casar
            # o "Current session" e o "Current week" que ficam em linhas
            # diferentes na saída do comando.
            texto = cru.encode("utf-8", "replace").decode("unicode_escape", "replace")
            for m in PADRAO_LEITURA.finditer(texto):
                sessao.leituras.append(
                    Leitura(
                        quando=quando or datetime.min.replace(tzinfo=timezone.utc),
                        sessao=sessao.id,
                        janela=int(m.group(1)),
                        semana=int(m.group(2)),
                    )
                )

        if sessao.leituras or sessao.primeiro_evento:
            sessao.leituras.sort(key=lambda l: l.quando)
            sessoes.append(sessao)

    sessoes.sort(key=lambda s: s.primeiro_evento or datetime.min.replace(tzinfo=timezone.utc))
    return sessoes


# ─── Leitura do git ──────────────────────────────────────────────────────────


def ler_commits(projeto: Path) -> list[Commit]:
    try:
        saida = subprocess.run(
            ["git", "log", "--no-merges", "--numstat", "--date=iso-strict",
             "--pretty=format:%x00%H%x00%cI%x00%s"],
            cwd=projeto, capture_output=True, text=True, check=True, encoding="utf-8",
        ).stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        return []

    commits: list[Commit] = []
    atual: Commit | None = None
    for linha in saida.splitlines():
        if linha.startswith("\x00"):
            _, sha, data, assunto = linha.split("\x00", 3)
            try:
                quando = datetime.fromisoformat(data)
            except ValueError:
                continue
            atual = Commit(sha=sha[:7], quando=quando, assunto=assunto, linhas=0)
            commits.append(atual)
        elif atual is not None and linha.strip():
            partes = linha.split("\t")
            if partes and partes[0].isdigit():
                atual.linhas += int(partes[0])

    commits.sort(key=lambda c: c.quando)
    return commits


# ─── Saída ───────────────────────────────────────────────────────────────────


def _local(dt: datetime | None) -> str:
    if dt is None:
        return "?"
    return dt.astimezone().strftime("%d/%m %H:%M")


def relatar(sessoes: list[Sessao], commits: list[Commit], com_git: bool) -> None:
    print()
    print("═" * 92)
    print("  SESSÕES E LEITURAS DE /usage")
    print("═" * 92)
    print()
    print(f"  {'sessão':9}{'início':>13}{'fim':>13}{'origem':>10}"
          f"{'janela':>18}{'pontos':>9}{'semana':>9}")
    print("  " + "─" * 92)

    medidas: list[tuple[Sessao, int, int]] = []

    for s in sessoes:
        origem = "/clear" if s.comecou_com_clear else "nova"
        if s.entrada and s.saida:
            # Com mais de duas leituras, mostra o caminho inteiro — é ele que
            # explica um número de pontos maior que a diferença das pontas.
            if len(s.leituras) > 2:
                janela = "→".join(f"{l.janela}" for l in s.leituras) + "%"
            else:
                janela = f"{s.entrada.janela}% → {s.saida.janela}%"
            janela += " ↻" if s.virou else ""
            pontos = f"≥{s.pontos}" if s.virou else str(s.pontos)
            semana = str(s.pontos_semana)
            medidas.append((s, s.pontos or 0, s.pontos_semana or 0))
        elif s.entrada:
            janela = f"{s.entrada.janela}% (só uma)"
            pontos = semana = "—"
        else:
            janela = "sem leitura"
            pontos = semana = "—"

        print(f"  {s.id:9}{_local(s.primeiro_evento):>13}{_local(s.ultimo_evento):>13}"
              f"{origem:>10}{janela:>18}{pontos:>9}{semana:>9}")

    if not any(s.leituras for s in sessoes):
        print()
        print("  Nenhuma leitura de /usage encontrada nas transcrições.")
        print("  Ou o comando nunca foi rodado neste projeto, ou o formato da saída")
        print("  mudou — nesse caso, conserte PADRAO_LEITURA no topo deste arquivo.")
        return

    if not com_git or not commits:
        return

    # ── Commits por sessão ───────────────────────────────────────────────────
    print()
    print("═" * 92)
    print("  COMMITS DENTRO DE CADA SESSÃO MEDIDA")
    print("═" * 92)

    for s, pontos, semana in medidas:
        if s.primeiro_evento is None or s.ultimo_evento is None:
            continue
        dentro = [c for c in commits if s.primeiro_evento <= c.quando <= s.ultimo_evento]
        linhas = sum(c.linhas for c in dentro)

        print()
        print(f"  ── {s.id} · {_local(s.primeiro_evento)} · {pontos} pontos de sessão, "
              f"{semana} de semana")
        if not dentro:
            print("     (nenhum commit neste intervalo — trabalho de desenho, ou não commitado)")
            continue
        for c in dentro:
            print(f"     {c.sha}  {c.linhas:>6} linhas  {c.assunto[:58]}")
        if pontos > 0:
            print(f"     {'':7}  {linhas:>6} linhas  → {linhas / pontos:.0f} linhas por ponto"
                  + ("  ⚠ janela virou: cota inferior" if s.virou else ""))

    # ── A régua ──────────────────────────────────────────────────────────────
    quentes: list[tuple[int, int]] = []
    frias: list[tuple[int, int]] = []
    descartadas = 0
    for s, pontos, _ in medidas:
        if s.primeiro_evento is None or s.ultimo_evento is None or pontos <= 0:
            continue
        # **Sessão que atravessou a virada fica de fora da régua.** O número de
        # pontos dela é cota inferior, então dividir linhas por ele infla a
        # razão — e infla mais quanto mais cedo a janela virou. Incluí-las
        # chegou a inverter a régua deste projeto (109 linhas/ponto a frio
        # contra 77 a quente, o oposto do que oito medições mostravam).
        if s.virou:
            descartadas += 1
            continue
        linhas = sum(c.linhas for c in commits
                     if s.primeiro_evento <= c.quando <= s.ultimo_evento)
        if linhas == 0:
            continue
        (frias if s.comecou_com_clear else quentes).append((linhas, pontos))

    print()
    print("═" * 92)
    print("  A RÉGUA DESTE PROJETO")
    print("═" * 92)
    print()

    if descartadas:
        print(f"  ({descartadas} sessão(ões) fora do cálculo por terem atravessado a virada —")
        print("   os pontos delas são cota inferior, e a razão sairia inflada.)")
        print()

    for rotulo, amostra in (("contínua (sem /clear)", quentes), ("depois de /clear", frias)):
        if not amostra:
            print(f"  {rotulo:24} sem amostra")
            continue
        linhas = sum(a for a, _ in amostra)
        pontos = sum(p for _, p in amostra)
        print(f"  {rotulo:24} {linhas / pontos:6.0f} linhas por ponto de sessão"
              f"   ({len(amostra)} sessõe(s), {linhas} linhas, {pontos} pontos)")

    print()
    print("  Ressalvas que este número carrega, e que não devem ser omitidas ao usá-lo:")
    print("  · A janela e a cota são da CONTA, não do projeto — trabalho em outro")
    print("    projeto no mesmo intervalo entra na conta e não aparece aqui.")
    print("  · Sessão de DESENHO consome orçamento e quase não produz linha. Misturada")
    print("    com implementação, ela puxa a razão para baixo sem que nada esteja errado.")
    print("  · Sessão que atravessou a virada (↻) dá cota inferior, não medida.")
    print()


# ─── Entrada ─────────────────────────────────────────────────────────────────


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[1])
    ap.add_argument("--projeto", default=".", help="raiz do projeto (padrão: diretório atual)")
    ap.add_argument("--sem-git", action="store_true", help="não cruzar com os commits")
    args = ap.parse_args()

    # O console do Windows abre em cp1252 e engasga nas molduras e nos acentos.
    # Reconfigurar é mais honesto que trocar a tabela por ASCII: quem roda isto
    # está lendo uma tabela, e tabela sem moldura é lista.
    for fluxo in (sys.stdout, sys.stderr):
        try:
            fluxo.reconfigure(encoding="utf-8")  # type: ignore[union-attr]
        except (AttributeError, OSError):
            pass

    projeto = Path(args.projeto).resolve()
    if not projeto.is_dir():
        print(f"Projeto não encontrado: {projeto}", file=sys.stderr)
        return 1

    pasta = achar_transcricoes(projeto)
    if pasta is None:
        print("Não achei a pasta de transcrições deste projeto em ~/.claude/projects/.",
              file=sys.stderr)
        print("Se houver mais de uma candidata, passe --projeto com o caminho exato.",
              file=sys.stderr)
        return 1

    print(f"\nProjeto: {projeto}")
    print(f"Transcrições: {pasta}")

    sessoes = ler_sessoes(pasta)
    commits = [] if args.sem_git else ler_commits(projeto)
    relatar(sessoes, commits, com_git=not args.sem_git)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
