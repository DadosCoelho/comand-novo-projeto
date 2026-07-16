<#
  Gera/atualiza .claude/arvore-de-commits.md com um diagrama Mermaid
  gitGraph a partir do historico REAL do repositorio atual -- a versao
  "ao vivo" dos diagramas conceituais em pesquisa/11-arvore-de-commits.md.

  Uso: powershell -File scripts\arvore-de-commits.ps1
#>

$repoRoot = Split-Path -Parent $PSScriptRoot
$out = Join-Path $repoRoot ".claude\arvore-de-commits.md"

function Sanitize([string]$s) {
    return $s -replace '"', '\"'
}

Push-Location $repoRoot
try {
    git rev-parse --is-inside-work-tree *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Nao e um repositorio git: $repoRoot"
        exit 1
    }
    New-Item -ItemType Directory -Path (Split-Path $out -Parent) -Force | Out-Null

    # 1) branches locais -- main/master primeiro (historico compartilhado),
    #    depois as demais em ordem alfabetica. A "dona" de cada commit e a
    #    primeira branch (nessa ordem) cujo historico de FIRST-PARENT (a
    #    linha principal, sem entrar pelo lado passado num merge) o contem.
    $allBranches = @(git branch --format='%(refname:short)' 2>$null)

    $baseBranch = $allBranches | Where-Object { $_ -eq 'main' -or $_ -eq 'master' } | Select-Object -First 1
    if (-not $baseBranch) { $baseBranch = if ($allBranches.Count -gt 0) { $allBranches[0] } else { 'main' } }

    $orderedBranches = @($baseBranch) + @($allBranches | Where-Object { $_ -ne $baseBranch })

    $owner = @{}
    foreach ($b in $orderedBranches) {
        $hashes = @(git log --first-parent --topo-order --reverse --pretty=format:'%H' $b 2>$null)
        foreach ($h in $hashes) {
            if ([string]::IsNullOrEmpty($h)) { continue }
            if (-not $owner.ContainsKey($h)) { $owner[$h] = $b }
        }
    }

    $emitted = @{}
    $branchDeclared = @{}
    $mermaid = New-Object System.Collections.Generic.List[string]
    $mermaid.Add("gitGraph")

    function Emit-BranchCommits([string]$br, [string]$tip) {
        $hashes = @(git log --first-parent --topo-order --reverse --pretty=format:'%H' $tip 2>$null)
        foreach ($h in $hashes) {
            if ([string]::IsNullOrEmpty($h)) { continue }
            if ($owner[$h] -ne $br) { continue }
            if ($emitted.ContainsKey($h)) { continue }
            $subj = git log -1 --pretty=format:'%s' $h
            $short = $h.Substring(0, 7)
            $msg = Sanitize $subj
            $mermaid.Add("   commit id: `"$short`: $msg`"")
            $emitted[$h] = $true
        }
    }

    # 2) percorre a linha principal (first-parent) da branch base. Cada
    #    merge encontrado dispara a branch do outro lado (declarada e
    #    "esvaziada" ali, logo antes do merge) antes de continuar.
    $mainLine = @(git log --first-parent --topo-order --reverse --pretty=format:'%H|%P|%s' $baseBranch 2>$null)
    foreach ($line in $mainLine) {
        if ([string]::IsNullOrEmpty($line)) { continue }
        $parts = $line.Split('|', 3)
        $h = $parts[0]
        $parents = @()
        if ($parts.Count -gt 1 -and $parts[1]) { $parents = $parts[1] -split ' ' }
        $subject = if ($parts.Count -gt 2) { $parts[2] } else { "" }

        if ($emitted.ContainsKey($h)) { continue }
        $short = $h.Substring(0, 7)
        $msg = Sanitize $subject

        if ($parents.Count -ge 2) {
            $p2 = $parents[1]
            $ob = if ($owner.ContainsKey($p2)) { $owner[$p2] } else { $baseBranch }
            if ($ob -ne $baseBranch) {
                if (-not $branchDeclared.ContainsKey($ob)) {
                    $mermaid.Add("   branch $ob")
                    $branchDeclared[$ob] = $true
                }
                $mermaid.Add("   checkout $ob")
                Emit-BranchCommits -br $ob -tip $p2
                $mermaid.Add("   checkout $baseBranch")
            }
            $mermaid.Add("   merge $ob id: `"$short`: $msg`"")
        } else {
            $mermaid.Add("   commit id: `"$short`: $msg`"")
        }
        $emitted[$h] = $true
    }

    # 3) branches locais ainda nao mescladas na base ficam de fora do passo
    #    2 -- anexa cada uma, na ordem, ao final (melhor esforco).
    foreach ($b in $orderedBranches) {
        if ($b -eq $baseBranch) { continue }
        $tip = git rev-parse $b 2>$null
        if (-not $tip) { continue }
        $pending = $owner.GetEnumerator() | Where-Object { $_.Value -eq $b -and -not $emitted.ContainsKey($_.Key) } | Select-Object -First 1
        if (-not $pending) { continue }
        if (-not $branchDeclared.ContainsKey($b)) {
            $mermaid.Add("   branch $b")
            $branchDeclared[$b] = $true
        }
        $mermaid.Add("   checkout $b")
        Emit-BranchCommits -br $b -tip $tip
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $rawGraph = git log --graph --abbrev-commit --decorate --date=short --pretty=format:'%h %ad %s%d' --all

    $lines = @(
        "# Árvore de commits"
        ""
        "> Gerado automaticamente a partir do histórico real do repositório — não editar à mão."
        "> Atualizado em: $timestamp"
        ""
        '```mermaid'
    ) + $mermaid + @(
        '```'
        ""
        '<details><summary>Log bruto (git log --graph)</summary>'
        ""
        '```'
    ) + $rawGraph + @(
        '```'
        ""
        '</details>'
    )

    $lines -join "`n" | Set-Content -Path $out -Encoding utf8
    Write-Host "OK  $out atualizado."
}
finally {
    Pop-Location
}
