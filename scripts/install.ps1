<#
.SYNOPSIS
    MooriShell bootstrap entry point.

    Reads and validates the dependency catalog and supports an offline plan.
    Provisioning, restore, and uninstall are not implemented and are refused safely.

.DESCRIPTION
    The catalog's source metadata is provisional. Package installation remains
    disabled until artifact mapping, integrity checks, detection, state tracking,
    configuration deployment, and rollback are implemented.

    Supports a dry-run/plan mode (-Plan) that reports what would be done
    without making any changes.

.PARAMETER Plan
    Shows what would happen if the script runs. No changes are made.


.PARAMETER Force
    Forces re-installation even if a package appears already installed.

.PARAMETER Restore
    Reserved for a future state-manifest-based restore; currently exits with
    code 5 and makes no changes.

.PARAMETER Uninstall
    Reserved for a future hash-checked uninstall; currently exits with code 6
    and makes no changes.

.EXAMPLE
    .\scripts/install.ps1 -Plan
    Shows what would be installed and configured without making changes.

.EXAMPLE
    .\scripts/install.ps1
    Exits with code 3 because installation is not implemented yet.

.EXAMPLE
    .\scripts/install.ps1 -Restore
    Exits with code 5 because restore is not implemented yet.

.EXAMPLE
    .\scripts/install.ps1 -Uninstall
    Exits with code 6 because uninstall is not implemented yet.

.NOTES
    Plan exits 0 after a read-only catalog review. Installation exits 3,
    restore exits 5, and uninstall exits 6 until those operations are implemented.

    Exit codes:
    0 - Success
    1 - General error
    2 - Prerequisite check failed
    3 - Installation failed
    4 - Validation failed
    5 - Restore failed
    6 - Uninstall failed
#>

[CmdletBinding()]
param(
    [switch]$Plan,
    [switch]$Force,
    [switch]$Restore,
    [switch]$Uninstall
)

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
$SCRIPT_DIR   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$REPO_ROOT    = Split-Path -Parent $SCRIPT_DIR
$CONFIG_DIR   = Join-Path $REPO_ROOT "configs"
$CATALOG_FILE = Join-Path $CONFIG_DIR "packages.yaml"
$MOORISHELL_DATA = Join-Path $env:LOCALAPPDATA "MooriShell"
$BACKUP_DIR   = Join-Path $MOORISHELL_DATA "backups"
$LOG_FILE     = Join-Path $MOORISHELL_DATA "logs", "provision.log"
$MIN_PS_MAJOR = 7
$MIN_PS_MINOR = 3

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
$script:LogEntries = @()

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Level] $message"
    $script:LogEntries += $entry
    if ($script:VerboseLogging) {
        Write-Host $entry
    }
}

function Write-LogFile {
    $logDir = Split-Path -Parent $LOG_FILE
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    $script:LogEntries | Out-File -FilePath $LOG_FILE -Encoding utf8
}

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

function Test-Prerequisites {
    <#
    .SYNOPSIS
        Checks that the host environment meets minimum requirements.
    .RETURNVALUE
        Boolean. $true if all checks pass, $false otherwise.
    #>
    Write-Log "Checking prerequisites..." "INFO"

    $allOk = $true

    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -lt $MIN_PS_MAJOR -or
        ($psVersion.Major -eq $MIN_PS_MAJOR -and $psVersion.Minor -lt $MIN_PS_MINOR)) {
        Write-Log "PowerShell $($MIN_PS_MAJOR).$($MIN_PS_MINOR)+ required. Found $($psVersion.Major).$($psVersion.Minor)." "ERROR"
        $allOk = $false
    } else {
        Write-Log "PowerShell $($psVersion.Major).$($psVersion.Minor) OK" "INFO"
    }

    # Check internet connectivity (simple DNS resolution test)
    try {
        $test = [System.Net.Dns]::GetHostEntry("github.com")
        Write-Log "Internet connectivity: OK" "INFO"
    } catch {
        Write-Log "Internet connectivity check failed. Some downloads may fail." "WARN"
    }

    # Check for required executables
    $requiredExes = @("pwsh.exe")
    foreach ($exe in $requiredExes) {
        if (-not (Get-Command -Name $exe -ErrorAction SilentlyContinue)) {
            Write-Log "Required executable not found: $exe" "ERROR"
            $allOk = $false
        } else {
            Write-Log "Executable found: $exe" "INFO"
        }
    }

    return $allOk
}

function Parse-YamlCatalog {
    <#
    .SYNOPSIS
        Reads the dependency catalog YAML and returns a list of package objects.
    #>
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        Write-Log "Catalog file not found: $Path" "ERROR"
        return @()
    }

    $content = Get-Content -Path $Path -Raw -ErrorAction Stop

    # Strip YAML comments (lines starting with #)
    $lines = $content -split "`n" | Where-Object { $_.TrimStart() -notmatch "^#" }
    $yamlText = $lines -join "`n"

    if (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue) {
        try {
            $data = ConvertFrom-Yaml -InputObject $yamlText -ErrorAction Stop
            if ($data -is [System.Array]) { return @($data) }
            if ($null -ne $data) { return @($data) }
            throw "YAML catalog was empty."
        } catch {
            Write-Log "Failed to parse YAML: $($_.Exception.Message)" "ERROR"
            return @()
        }
    }

    # Parse the catalog's constrained flat-list format without third-party
    # modules. Nested YAML and advanced YAML features are intentionally rejected.
    $packages = [System.Collections.Generic.List[object]]::new()
    $current = $null
    foreach ($line in ($content -split "`r?`n")) {
        $trimmed = $line.Trim()
        if (-not $trimmed -or $trimmed.StartsWith('#')) { continue }
        if ($trimmed -match '^-[ ]+id:[ ]*(?<value>[^ ]+)$') {
            if ($null -ne $current) { $packages.Add([pscustomobject]$current) }
            $packageId = $Matches['value']
            $current = [ordered]@{ id = $packageId }
            continue
        }
        if ($null -eq $current -or $trimmed -notmatch '^(?<key>[A-Za-z_][A-Za-z0-9_-]*):[ ]*(?<value>.*)$') {
            Write-Log "Unsupported YAML catalog syntax near: $trimmed" "ERROR"
            return @()
        }
        $fieldKey = $Matches['key']
        $fieldValue = $Matches['value'].Trim()
        if ($fieldValue -match '^"(?<quoted>.*)"$') { $fieldValue = $Matches['quoted'] }
        $current[$fieldKey] = $fieldValue
    }
    if ($null -ne $current) { $packages.Add([pscustomobject]$current) }
    return @($packages.ToArray())
}

function Test-PackageInstalled {
    <#
    .SYNOPSIS
        Checks whether a package appears to be installed.
    .PARAMETER Package
        A package object from the catalog.
    .RETURNVALUE
        Boolean. $true if the package appears installed.
    #>
    param([object]$Package)

    # Heuristic: check if the package name appears as an executable in PATH
    $exeName = $Package.name + ".exe"
    if (Get-Command -Name $exeName -ErrorAction SilentlyContinue) {
        return $true
    }

    # Also check common install locations
    $commonPaths = @(
        Join-Path $env:LOCALAPPDATA "Programs" $Package.name
        Join-Path $env:ProgramFiles $Package.name
        Join-Path ${env:ProgramFiles(x86)} $Package.name
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }

    return $false
}

# ---------------------------------------------------------------------------
# Main execution
# ---------------------------------------------------------------------------

function Main {
    param([switch]$Plan,
          [switch]$VerboseLogging,
          [switch]$Force,
          [switch]$Restore,
          [switch]$Uninstall)

    $exitCode = 0

    try {
        Write-Log "========================================" "INFO"
        Write-Log "MooriShell Provisioning Started" "INFO"
        Write-Log "========================================" "INFO"

        # Step 2: Load dependency catalog
        Write-Log "Step 2: Loading dependency catalog" "INFO"
        $packages = Parse-YamlCatalog -Path $CATALOG_FILE
        if ($packages.Count -eq 0) {
            Write-Log "No valid packages found in catalog; aborting without changes." "ERROR"
            return 2
        }
        Write-Log "Loaded $($packages.Count) package(s) from catalog." "INFO"

        # These operations must never report success until they use the
        # manifest and hash-checked state model specified by ADR-006.
        if ($Uninstall) {
            Write-Log "Uninstall is not implemented; no changes made." "ERROR"
            return 6
        }
        if ($Restore) {
            if ($Plan) {
                Write-Log "[PLAN] Restore is not implemented; no changes made." "INFO"
                return 0
            }
            Write-Log "Restore is not implemented; no changes made." "ERROR"
            return 5
        }

        # Plan mode is intentionally offline and has no side effects.
        if ($Plan) {
            foreach ($pkg in $packages) {
                Write-Log "[PLAN] Would inspect package $($pkg.id) ($($pkg.name)); installation is not configured." "INFO"
            }
            Write-Log "Plan complete. No backup, configuration, package, or log files were created." "INFO"
            return 0
        }

        # Step 1: Prerequisite check (only for actual operations)
        Write-Log "Step 1: Prerequisite check" "INFO"
        if (-not (Test-Prerequisites)) {
            Write-Log "Prerequisite check failed. Aborting." "ERROR"
            return 2
        }
        Write-Log "Prerequisite check passed." "INFO"

        # Installation is intentionally disabled until validated artifact URLs,
        # signatures/checksums, ownership-aware detection, and state tracking exist.
        Write-Log "Package installation is not implemented. No changes made." "ERROR"
        return 3

    } catch {
        Write-Log "Unhandled error: $($_.Exception.Message)" "ERROR"
        Write-LogFile
        return 1
    }
}

$script:VerboseLogging = $VerbosePreference -ne "SilentlyContinue"
$exitCode = Main -Plan:$Plan -VerboseLogging:$script:VerboseLogging -Force:$Force -Restore:$Restore -Uninstall:$Uninstall
exit $exitCode
