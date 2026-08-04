<#
.SYNOPSIS
  Startet den sorgl.OS-Team-Reiter — die Weboberflaeche des agent-bus.

.EXAMPLE
  .\team.ps1                     # oeffnet http://127.0.0.1:8787 im Browser
  .\team.ps1 -Ich mensch-edgar   # bei Edgar
  .\team.ps1 -Port 9000

.NOTES
  Der Server bindet nur an 127.0.0.1 — der Bus ist nicht aus dem Netz erreichbar.
  Wer bist du: aus identity.json ("mensch": "daniel") oder per -Ich.
#>
param(
  [string]$Ich,
  [int]$Port = 8787,
  [int]$Intervall = 20,
  [switch]$KeinBrowser
)

$ErrorActionPreference = 'Stop'

$python = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $python) { $python = (Get-Command python3 -ErrorAction SilentlyContinue) }
if (-not $python) { throw 'Python nicht gefunden. Installieren: https://www.python.org/downloads/' }

$server = Join-Path $PSScriptRoot 'bus_web.py'
if (-not (Test-Path $server)) { throw "bus_web.py nicht gefunden neben $PSScriptRoot" }

if (-not (Test-Path (Join-Path $PSScriptRoot 'identity.json'))) {
  Write-Host "!!  Dieser Klon hat keine identity.json — lauf zuerst setup.ps1." -ForegroundColor Yellow
}

$belegt = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($belegt) {
  throw "Port $Port ist schon belegt (PID $($belegt.OwningProcess)). Laeuft der Reiter bereits? Sonst -Port anders waehlen."
}

$argumente = @($server, '--port', $Port, '--intervall', $Intervall)
if ($Ich) { $argumente += @('--ich', $Ich) }
if ($KeinBrowser) { $argumente += '--kein-browser' }

$env:BUS_REPO = $PSScriptRoot
& $python.Source @argumente
