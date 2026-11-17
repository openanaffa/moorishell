<#
.SYNOPSIS
    Safely create, list, or remove MooriShell Git worktrees.
.DESCRIPTION
    Uses sibling worktree directories outside the repository by default.
    Removal refuses dirty worktrees and never deletes branches.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position=0)]
    [ValidateSet('New','List','Remove')]
    [string]$Action,

    [Parameter(Position=1)]
    [string]$Name,

    [string]$Branch,
    [string]$Base = 'origin/main',
    [string]$Root = 'F:\sources\worktrees',
    [switch]$ExistingBranch,
    [switch]$InitializeSubmodules
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Invoke-Git {
    param([string[]]$GitArgs)
    & git @GitArgs
    if ($LASTEXITCODE -ne 0) {
        throw "git $($GitArgs -join ' ') failed with exit code $LASTEXITCODE"
    }
}

switch ($Action) {
    'List' {
        Invoke-Git -GitArgs @('-C', $repoRoot, 'worktree', 'list')
    }
    'New' {
        if (-not $Name -or $Name -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
            throw 'Name is required and must be lowercase kebab-case (without a branch prefix).'
        }
        if (-not (Test-Path $Root)) {
            New-Item -ItemType Directory -Path $Root -Force | Out-Null
        }
        $destination = Join-Path $Root $Name
        if (Test-Path $destination) { throw "Worktree destination already exists: $destination" }

        if ($ExistingBranch) {
            if (-not $Branch) { throw '-Branch is required with -ExistingBranch.' }
            Invoke-Git -GitArgs @('-C', $repoRoot, 'worktree', 'add', $destination, $Branch)
        } else {
            if (-not $Branch) { $Branch = "feature/$Name" }
            if ($Branch -notmatch '^(feature|bugfix|hotfix|release|docs)/[a-z0-9]+(?:[-./][a-z0-9]+)*$') {
                throw "Branch must use an approved prefix and lowercase kebab-case: $Branch"
            }
            Invoke-Git -GitArgs @('-C', $repoRoot, 'worktree', 'add', '-b', $Branch, $destination, $Base)
        }

        if ($InitializeSubmodules) {
            Invoke-Git -GitArgs @('-C', $destination, 'submodule', 'update', '--init', '--recursive')
        }
        Write-Output "Worktree ready: $destination"
    }
    'Remove' {
        if (-not $Name) { throw 'Name is required to remove a worktree.' }
        $candidatePath = Join-Path $Root $Name
        if (-not (Test-Path $candidatePath)) { throw "Worktree path not found: $candidatePath" }
        $destination = (Resolve-Path $candidatePath).Path
        $status = & git -C $destination status --porcelain
        if ($LASTEXITCODE -ne 0) { throw "Unable to inspect worktree: $destination" }
        if ($status) { throw "Refusing to remove dirty worktree. Preserve or commit changes first: $destination" }
        Invoke-Git -GitArgs @('-C', $repoRoot, 'worktree', 'remove', $destination)
        Write-Output "Removed clean worktree: $destination (branch retained)"
    }
}
