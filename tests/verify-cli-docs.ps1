[CmdletBinding()]
param(
  [string]$OnxPath
)

$ErrorActionPreference = "Stop"

function Get-ClapCommands {
  param(
    [string]$HelpText
  )

  $Commands = @()
  $InCommandsSection = $false

  foreach ($Line in ($HelpText -split "`r?`n")) {
    if ($Line -match '^Commands:') {
      $InCommandsSection = $true
      continue
    }

    if ($InCommandsSection) {
      if ($Line -match '^[A-Z][a-zA-Z0-9 ]*:' -or $Line.Trim() -eq "") {
        
        if ($Line.Trim() -ne "") {
          break
        }

        continue
      }

      if ($Line -match '^\s{2}([a-z0-9][a-z0-9\-_]*)\s+(.+)$') {
        $CmdName = $Matches[1].Trim()

        if ($CmdName -ne "help") {
          $Commands += $CmdName
        }
      }
    }
  }

  return $Commands
}

if (-not $OnxPath) {
  $Cmd = Get-Command "onx" -ErrorAction SilentlyContinue

  if ($Cmd) {
    $OnxPath = $Cmd.Source
  }
}

if (-not $OnxPath -or -not (Test-Path $OnxPath)) {
  Write-Error "Could not locate onx executable. Ensure 'onx' is in PATH or provide -OnxPath <path_to_onx>."

  exit 1
}

Write-Host "Deriving commands dynamically from onx binary at: $OnxPath" -ForegroundColor Cyan

$RootHelp = & $OnxPath --help | Out-String
$TopCommands = Get-ClapCommands -HelpText $RootHelp

if ($TopCommands.Count -eq 0) {
  Write-Error "Failed to dynamically discover any commands from '$OnxPath --help'."

  exit 1
}

Write-Host "Discovered top-level commands: $($TopCommands -join ', ')" -ForegroundColor Gray

$CommandHierarchy = @{}

foreach ($cmd in $TopCommands) {
  $CmdHelp = & $OnxPath $cmd --help | Out-String
  $SubCommands = Get-ClapCommands -HelpText $CmdHelp

  $CommandHierarchy[$cmd] = $SubCommands

  if ($SubCommands.Count -gt 0) {
    Write-Host "  -> ${cmd}: $($SubCommands -join ', ')" -ForegroundColor Gray
  } else {
    Write-Host "  -> ${cmd} (standalone command)" -ForegroundColor Gray
  }
}

$DocFile = Join-Path $PSScriptRoot "..\references\cli-reference.md"

if (-not (Test-Path $DocFile)) {
  Write-Error "cli-reference.md not found at $DocFile"

  exit 1
}

$DocText = Get-Content $DocFile -Raw
$HasErrors = $false

foreach ($cmd in $CommandHierarchy.Keys) {
  $SubCommands = $CommandHierarchy[$cmd]

  if ($SubCommands.Count -eq 0) {
    $Pattern = "onx $cmd"

    if ($DocText -notmatch [regex]::Escape($Pattern)) {
      Write-Warning "Documentation drift! Command '$Pattern' is not documented in $DocFile"

      $HasErrors = $true
    }
  } else {
    foreach ($sub in $SubCommands) {
      $Pattern = "onx $cmd $sub"

      if ($DocText -notmatch [regex]::Escape($Pattern)) {
        Write-Warning "Documentation drift! Subcommand '$Pattern' is not documented in $DocFile"

        $HasErrors = $true
      }
    }
  }
}

if ($HasErrors) {
  Write-Error "CLI docs verification failed due to drift."

  exit 1
}

Write-Host "`nAll dynamically derived commands and subcommands from the onx binary are documented in cli-reference.md!" -ForegroundColor Green
