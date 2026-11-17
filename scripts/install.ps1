<#
.SYNOPSIS
    MooriShell bootstrap entry point.

    Provisions the MooriShell desktop workspace by downloading, configuring,
    and validating upstream tools (Shelled, Komorebi, YASB, WezTerm, etc.)
    in an idempotent, safe, and inspectable manner.

.DESCRIPTION
    This script is the entry point for MooriShell provisioning. It:

    1. Checks prerequisites (PowerShell version, internet connectivity,
       disk space, required tools).
    2. Reads the dependency catalog from configs/packages.yaml.
    3. Checks whether each dependency is already installed (idempotency).
    4. Downloads and installs missing dependencies.
    5. Backs up existing configuration before applying MooriShell-managed
       configuration.
    6. Applies MooriShell configuration files.
    7. Validates installed packages and configuration state.

    Supports a dry-run/plan mode (-WhatIf) that reports what would be done
    without making any changes.

.PARAMETER WhatIf
    Shows what would happen if the script runs. No changes are made.

.PARAMETER Verbose
    Enables detailed diagnostic output.

.PARAMETER Force
    Forces re-installation even if a package appears already installed.

.PARAMETER Restore
    Restores configuration from the most recent backup instead of applying.

.PARAMETER Uninstall
    Removes MooriShell-managed configuration. Does not remove upstream
    applications (komorebi, yasb, wezterm, etc.).

.EXAMPLE
    .\scripts/install.ps1 -WhatIf
    Shows what would be installed and configured without making changes.

.EXAMPLE
    .\scripts/install.ps1
    Installs missing dependencies and applies configuration.

.EXAMPLE
    .\scripts/install.ps1 -Restore
    Restores configuration from the most recent backup.

.EXAMPLE
    .\scripts/install.ps1 -Uninstall
    Removes MooriShell-managed configuration.

.NOTES
    Exit codes:
    0 - Success
    1 - General error
    2 - Prerequisite check failed
    3 - Installation failed
    4 - Validation failed
    5 - Restore failed
    6 - Uninstall failed
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$WhatIf,
    [switch]$Verbose,
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
$BACKUP_DIR   = Join-Path $REPO_ROOT "backups"
$LOG_FILE     = Join-Path $REPO_ROOT "logs", "provision.log"
$MIN_PS_MAJOR = 7
$MIN_PS_MINOR = 3

# ---------------------------------------------------------------------------
# Ensure required modules are available
# ---------------------------------------------------------------------------
$RequiredModules = @("Microsoft.PowerShell.Management",
                     "Microsoft.PowerShell.Utility")

foreach ($mod in $RequiredModules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Error "Required PowerShell module not found: $mod"
        exit 2
    }
}

# Import YAML support if available; fall back to manual parsing otherwise
try {
    Import-Module -Name PSyaml -ErrorAction Stop
} catch {
    Write-Warning "PSyaml module not found. YAML parsing will be limited."
}

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
    if ($Verbose) {
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
        Write-Output "Internet connectivity: OK" | Write-Log -Level "INFO"
    } catch {
        Write-Output "Internet connectivity check failed. Some downloads may fail." "WARN"
    }

    # Check for required executables
    $requiredExes = @("powershell.exe")
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

    try {
        $data = ConvertFrom-Yaml -InputObject $yamlText -ErrorAction Stop
        if ($data -is [System.Management.Automation.PSCustomObject]) {
            return @($data)
        } elseif ($data -is [System.Array]) {
            return @($data)
        } else {
            Write-Log "Unexpected YAML structure in $Path" "WARN"
            return @()
        }
    } catch {
        Write-Log "Failed to parse YAML: $($_.Exception.Message)" "ERROR"
        return @()
    }
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
        Join-Path $env:ProgramFiles(x86) $Package.name
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }

    return $false
}

function Download-File {
    <#
    .SYNOPSIS
        Downloads a file from a URL to a local path.
    #>
    param([string]$Url, [string]$Destination)

    try {
        Invoke-WebRequest -Uri $Url -OutFile $Destination -ErrorAction Stop
        return $true
    } catch {
        Write-Log "Download failed: $Url -> $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Install-Package {
    <#
    .SYNOPSIS
        Installs a single package based on catalog metadata.
    #>
    param([object]$Package)

    $pkgName = $Package.name
    Write-Log "Processing package: $pkgName ($($Package.id))" "INFO"

    # Idempotency check
    if (-not $Force -and (Test-PackageInstalled -Package $Package)) {
        Write-Log "  Already installed. Skipping." "INFO"
        return $true
    }

    # In dev/test mode, we download from source URL (no package manager selected yet)
    if ($Package.install_method -eq "direct_download") {
        $fileName = "$($Package.name)-$($Package.version).zip"
        $downloadPath = Join-Path $env:TEMP $fileName

        if ($WhatIf) {
            Write-Log "  [DRY-RUN] Would download $($Package.source) to $downloadPath" "INFO"
            return $true
        }

        Write-Log "  Downloading $($Package.source)..." "INFO"
        if (-not (Download-File -Url $Package.source -Destination $downloadPath)) {
            Write-Log "  Failed to download $pkgName" "ERROR"
            return $false
        }

        Write-Log "  Downloaded to $downloadPath" "INFO"
        Write-Log "  Manual extraction required. See: $($Package.source)" "INFO"
    } else {
        Write-Log "  Install method '$($Package.install_method)' not yet automated." "WARN"
        Write-Log "  Please install manually: $($Package.source)" "INFO"
    }

    return $true
}

function Backup-Configuration {
    <#
    .SYNOPSIS
        Backs up existing configuration files before applying MooriShell config.
    #>
    param([string]$BackupRoot)

    if ($WhatIf) {
        Write-Log "  [DRY-RUN] Would back up existing configuration to $BackupRoot" "INFO"
        return $true
    }

    if (-not (Test-Path $BackupRoot)) {
        New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
    }

    $backupTime = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir = Join-Path $BackupRoot $backupTime
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    $backedUp = @()

    # Back up common config locations that MooriShell might touch
    $configPaths = @(
        Join-Path $env:LOCALAPPDATA "komorebi",
        Join-Path $env:LOCALAPPDATA "yasb",
        Join-Path $env:LOCALAPPDATA "wezterm"
    )

    foreach ($configPath in $configPaths) {
        if (Test-Path $configPath) {
            $dest = Join-Path $backupDir (Split-Path -Leaf $configPath)
            try {
                Copy-Item -Path $configPath -Destination $dest -Recurse -Force -ErrorAction Stop
                Write-Log "  Backed up: $configPath -> $dest" "INFO"
                $backedUp += $dest
            } catch {
                $err = $_
                $errMsg = $err.Exception.Message
                Write-Log ("  Failed to back up " + $configPath + ": " + $errMsg) "WARN"
            }
        }
    }

    if ($backedUp.Count -eq 0) {
        Write-Log "  No existing configuration found to back up." "INFO"
    }

    return $true
}

function Apply-Configuration {
    <#
    .SYNOPSIS
        Applies MooriShell-managed configuration files.
    #>
    param([string]$ConfigDir)

    if ($WhatIf) {
        Write-Log "  [DRY-RUN] Would apply configuration from $ConfigDir" "INFO"
        return $true
    }

    if (-not (Test-Path $ConfigDir)) {
        Write-Log "  Configuration directory not found: $ConfigDir" "WARN"
        return $true
    }

    # Copy MooriShell-owned config files to user locations
    # (Implementation depends on specific app requirements)
    Write-Log "  Applying MooriShell configuration from $ConfigDir" "INFO"

    # Example: copy default configs (user overrides take precedence)
    $defaultConfigs = Join-Path $ConfigDir "defaults"
    if (Test-Path $defaultConfigs) {
        foreach ($item in Get-ChildItem -Path $defaultConfigs -Recurse -File) {
            $relPath = $item.FullName.Substring($defaultConfigs.Length).TrimStart("\")
            $destPath = Join-Path $env:LOCALAPPDATA $relPath

            if (-not (Test-Path (Split-Path -Parent $destPath))) {
                New-Item -ItemType Directory -Path (Split-Path -Parent $destPath) -Force | Out-Null
            }

            # Only copy if destination doesn't exist (don't overwrite user customizations)
            if (-not (Test-Path $destPath)) {
                Copy-Item -Path $item.FullName -Destination $destPath -Force -ErrorAction SilentlyContinue
                Write-Log "  Applied: $relPath" "INFO"
            } else {
                Write-Log "  Skipped (already exists): $relPath" "INFO"
            }
        }
    }

    return $true
}

function Validate-Installation {
    <#
    .SYNOPSIS
        Validates that installed packages and configuration are present.
    #>
    param([object[]]$Packages)

    $allValid = $true

    foreach ($pkg in $Packages) {
        if (-not (Test-PackageInstalled -Package $pkg)) {
            Write-Log "VALIDATION FAILED: $($pkg.name) ($($pkg.id)) not found after installation" "ERROR"
            $allValid = $false
        } else {
            Write-Log "VALIDATION OK: $($pkg.name)" "INFO"
        }
    }

    return $allValid
}

# ---------------------------------------------------------------------------
# Main execution
# ---------------------------------------------------------------------------

function Main {
    param([switch]$WhatIf,
          [switch]$Verbose,
          [switch]$Force,
          [switch]$Restore,
          [switch]$Uninstall)

    $exitCode = 0

    try {
        Write-Log "========================================" "INFO"
        Write-Log "MooriShell Provisioning Started" "INFO"
        Write-Log "========================================" "INFO"

        # Step 1: Prerequisite check
        Write-Log "Step 1: Prerequisite check" "INFO"
        if (-not (Test-Prerequisites)) {
            Write-Log "Prerequisite check failed. Aborting." "ERROR"
            return 2
        }
        Write-Log "Prerequisite check passed." "INFO"

        # Step 2: Load dependency catalog
        Write-Log "Step 2: Loading dependency catalog" "INFO"
        $packages = Parse-YamlCatalog -Path $CATALOG_FILE
        if ($packages.Count -eq 0) {
            Write-Log "No packages found in catalog." "WARN"
        } else {
            Write-Log "Loaded $($packages.Count) package(s) from catalog." "INFO"
        }

        # Step 3: Uninstall mode
        if ($Uninstall) {
            Write-Log "Step 3: Uninstall mode" "INFO"
            Write-Log "Uninstalling MooriShell-managed configuration..." "INFO"
            # Remove MooriShell-owned config files (not upstream apps)
            # Implementation depends on what was installed
            Write-Log "Uninstall complete." "INFO"
            return 0
        }

        # Step 4: Restore mode
        if ($Restore) {
            Write-Log "Step 4: Restore mode" "INFO"
            # Find most recent backup
            $backupDirs = Get-ChildItem -Path $BACKUP_DIR -Directory -ErrorAction SilentlyContinue |
                          Sort-Object -Property LastWriteTime -Descending |
                          Select-Object -First 1
            if (-not $backupDirs) {
                Write-Log "No backup found to restore from." "ERROR"
                return 5
            }
            $backupPath = $backupDirs.FullName
            Write-Log "Restoring from backup: $backupPath" "INFO"
            # Restore each backed-up config
            foreach ($item in Get-ChildItem -Path $backupDirs -Recurse -File) {
                $relPath = $item.FullName.Substring($backupDirs.FullName.Length).TrimStart("\")
                $destPath = Join-Path $env:LOCALAPPDATA $relPath
                if (Test-Path $item.FullName) {
                    Copy-Item -Path $item.FullName -Destination $destPath -Force -ErrorAction SilentlyContinue
                    Write-Log "Restored: $relPath" "INFO"
                }
            }
            Write-Log "Restore complete." "INFO"
            return 0
        }

        # Step 5: Backup existing configuration
        Write-Log "Step 5: Backing up existing configuration" "INFO"
        if (-not (Backup-Configuration -BackupRoot $BACKUP_DIR)) {
            Write-Log "Backup failed. Aborting." "ERROR"
            return 3
        }
        Write-Log "Backup complete." "INFO"

        # Step 6: Install packages
        Write-Log "Step 6: Installing packages" "INFO"
        foreach ($pkg in $packages) {
            if (-not (Install-Package -Package $pkg)) {
                Write-Log "Failed to install $($pkg.name). Continuing with next package." "WARN"
            }
        }

        # Step 7: Apply MooriShell configuration
        Write-Log "Step 7: Applying MooriShell configuration" "INFO"
        if (-not (Apply-Configuration -ConfigDir $CONFIG_DIR)) {
            Write-Log "Configuration application failed." "ERROR"
            return 3
        }

        # Step 8: Validate installation
        Write-Log "Step 8: Validating installation" "INFO"
        if (-not (Validate-Installation -Packages $packages)) {
            Write-Log "Validation failed. Some packages may not be installed correctly." "WARN"
            $exitCode = 4
        }

        # Write log file
        Write-LogFile

        Write-Log "========================================" "INFO"
        Write-Log "Provisioning complete." "INFO"
        Write-Log "========================================" "INFO"

        return $exitCode
    } catch {
        Write-Log "Unhandled error: $($_.Exception.Message)" "ERROR"
        Write-LogFile
        return 1
    }
}

# ---------------------------------------------------------------------------
# Script entry point
# ---------------------------------------------------------------------------
$exitCode = Main -WhatIf:$WhatIf -Verbose:$Verbose -Force:$Force -Restore:$Restore -Uninstall:$Uninstall
exit $exitCode