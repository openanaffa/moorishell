[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$scriptPath = Join-Path $PSScriptRoot 'install.ps1'

function Assert-Equal {
    param([object]$Actual, [object]$Expected, [string]$Message)
    if ($Actual -ne $Expected) {
        throw "$Message (expected '$Expected', got '$Actual')"
    }
}

$tokens = $null
$parseErrors = $null
[System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$tokens, [ref]$parseErrors) | Out-Null
Assert-Equal ($parseErrors.Count) 0 'PowerShell parser reported errors'

$content = Get-Content -Raw $scriptPath
$entryPoint = [regex]::Match($content, '(?s)\$script:VerboseLogging\s*=.*?\z').Value
if (-not $entryPoint) { throw 'Script entry point was not found.' }

# Load definitions without invoking Main; override process exit so the test host
# is never terminated by the script's CLI exit statement.
$definitions = $content.Substring(0, $content.IndexOf('$script:VerboseLogging ='))
Invoke-Expression $definitions
$packages = Parse-YamlCatalog -Path (Join-Path $repoRoot 'configs/packages.yaml')
Assert-Equal $packages.Count 4 'Expected four catalog packages'
Assert-Equal ([bool](Test-Catalog -Packages $packages)) $true 'Catalog should satisfy schema'
Assert-Equal @($packages | Where-Object status -ne 'manual').Count 0 'Unvalidated packages must remain unmanaged'
Assert-Equal @($packages | Where-Object { $_.artifact_url -or $_.checksum }).Count 0 'Inventory-only packages must have no install artifact or checksum'

# Invalid managed records must fail schema validation.
$badPackage = [pscustomobject]@{
    id='bad'; name='Bad'; source='https://example.invalid'; version_policy='pinned'; version='1'
    install_scope='user'; package_manager='direct'; install_method='direct_download'; category='test'
    status='managed'; artifact_url=$null; checksum=$null; executable=$null
}
Assert-Equal ([bool](Test-Catalog -Packages @($badPackage))) $false 'Managed record without artifact integrity data must fail'

# Exercise CLI outcomes in child PowerShell processes, keeping tests isolated.
$powerShellExe = (Get-Process -Id $PID).Path
$plan = & $powerShellExe -NoProfile -File $scriptPath -Plan -Verbose 2>&1
Assert-Equal $LASTEXITCODE 0 'Plan mode should succeed'
if (($plan -join "`n") -notmatch 'manual/unmanaged') { throw 'Plan output did not identify manual packages.' }

$restore = & $powerShellExe -NoProfile -File $scriptPath -Restore 2>&1
Assert-Equal $LASTEXITCODE 5 'Restore must fail safely until implemented'

$uninstall = & $powerShellExe -NoProfile -File $scriptPath -Uninstall 2>&1
Assert-Equal $LASTEXITCODE 6 'Uninstall must fail safely until implemented'

Write-Output 'All provisioning safety tests passed.'
