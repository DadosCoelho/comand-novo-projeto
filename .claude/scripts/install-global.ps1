<#
  Instala as skills e comandos deste repo em ~/.claude/ (nivel global do
  usuario), para que valham em TODOS os projetos, nao so neste.

  Uso:
    pwsh scripts\install-global.ps1            # nao sobrescreve o que ja existe
    pwsh scripts\install-global.ps1 -Force      # sobrescreve versoes ja instaladas
#>

param(
    [switch]$Force
)

$repoRoot   = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$claudeHome = Join-Path $HOME ".claude"

$skills = @("git-workflow", "pesquisa-workflow")
$commands = @("novo-projeto.md", "pesquisa.md")

Write-Host "Instalando globalmente a partir de: $repoRoot"
Write-Host "Destino (~/.claude): $claudeHome"
Write-Host ""

foreach ($skill in $skills) {
    $src  = Join-Path $repoRoot ".claude\skills\$skill"
    $dest = Join-Path $claudeHome "skills\$skill"

    if (-not (Test-Path $src)) {
        Write-Host "AVISO  skills/$skill nao encontrada em $src -- pulando"
        continue
    }
    if ((Test-Path $dest) -and -not $Force) {
        Write-Host "SKIP   skills/$skill (ja existe em $dest -- use -Force para sobrescrever)"
        continue
    }

    New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
    Copy-Item -Recurse -Force $src $dest
    Write-Host "OK     skills/$skill -> $dest"
}

foreach ($cmd in $commands) {
    $src  = Join-Path $repoRoot ".claude\commands\claude\$cmd"
    $dest = Join-Path $claudeHome "commands\claude\$cmd"

    if (-not (Test-Path $src)) {
        Write-Host "AVISO  commands/claude/$cmd nao encontrado em $src -- pulando"
        continue
    }
    if ((Test-Path $dest) -and -not $Force) {
        Write-Host "SKIP   commands/claude/$cmd (ja existe em $dest -- use -Force para sobrescrever)"
        continue
    }

    New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
    Copy-Item -Force $src $dest
    Write-Host "OK     commands/claude/$cmd -> $dest"
}

Write-Host ""
Write-Host "Pronto. Abra (ou reabra) o Claude Code em qualquer projeto -- as skills"
Write-Host "sao descobertas pelo gatilho no frontmatter, e os comandos ficam"
Write-Host "disponiveis como /claude:novo-projeto e /claude:pesquisa."
