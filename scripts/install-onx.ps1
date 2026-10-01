[CmdletBinding()]
param(
  [Alias("v")]
  [string]$Version,

  [Alias("t")]
  [string]$InstallDir = "$HOME\.onx\bin"
)

$ErrorActionPreference = "Stop"

$Existing = Get-Command "onx" -ErrorAction SilentlyContinue

if ($Existing) {
  Write-Host "onx is already installed at: $($Existing.Source)" -ForegroundColor Green
  & onx --version
  exit 0
}

Write-Host "onx CLI not found in PATH. Installing via official installer..." -ForegroundColor Cyan

$InstallerUrl = "https://raw.githubusercontent.com/StevanFreeborn/onx/main/scripts/install.ps1"

$InstallScript = [scriptblock]::Create((Invoke-RestMethod -Uri $InstallerUrl))

$Params = @{
  InstallDir = $InstallDir
}

if ($Version) {
  $Params["Version"] = $Version
}

& $InstallScript @Params
