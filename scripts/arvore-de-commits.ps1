<#
  Gera/atualiza .claude/arvore-de-commits.md com a arvore REAL de commits do
  repositorio atual (git log --graph), diferente dos diagramas conceituais
  em pesquisa/11-arvore-de-commits.md.

  Uso: powershell -File scripts\arvore-de-commits.ps1
#>

$repoRoot = Split-Path -Parent $PSScriptRoot
$out = Join-Path $repoRoot ".claude\arvore-de-commits.md"

Push-Location $repoRoot
try {
    git rev-parse --is-inside-work-tree *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Nao e um repositorio git: $repoRoot"
        exit 1
    }

    $graph = git log --graph --abbrev-commit --decorate --date=short --pretty=format:'%h %ad %s%d' --all
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $lines = @(
        "# Árvore de commits"
        ""
        "> Gerado automaticamente a partir de ``git log --graph`` — não editar à mão."
        "> Atualizado em: $timestamp"
        ""
        '```'
    ) + $graph + @('```')

    New-Item -ItemType Directory -Path (Split-Path $out -Parent) -Force | Out-Null
    $lines -join "`n" | Set-Content -Path $out -Encoding utf8

    Write-Host "OK  $out atualizado."
}
finally {
    Pop-Location
}
