<#
.SYNOPSIS
  Richtet den agent-bus fuer einen Claude-Code-Account ein.

.EXAMPLE
  # Erster Account auf diesem Rechner (Repo liegt schon lokal):
  .\setup.ps1 -AgentId daniel-1

  # Zweiter Account: eigener Klon, damit beide unterschiedliche Identitaeten haben
  .\setup.ps1 -AgentId daniel-2 -ClonePath "$env:USERPROFILE\Documents\GitHub\agent-bus-2"

  # Bei Ed auf seinem Rechner:
  .\setup.ps1 -AgentId ed -RepoUrl git@github.com:danielsorglos/agent-bus.git

.NOTES
  Registriert den MCP-Server in der globalen ~/.claude/settings.json.
  Mit -Scope Project wird stattdessen eine .mcp.json im aktuellen Ordner
  geschrieben — noetig, wenn zwei Accounts sich eine settings.json teilen.
#>
param(
  [Parameter(Mandatory = $true)][string]$AgentId,
  [string]$Mensch,
  [string]$RepoUrl,
  [string]$ClonePath,
  [ValidateSet('Global', 'Project')][string]$Scope = 'Global',
  [string]$ServerName = 'agent-bus'
)

$ErrorActionPreference = 'Stop'

function Schritt($t) { Write-Host "==> $t" -ForegroundColor Cyan }
function Warnung($t) { Write-Host "!!  $t" -ForegroundColor Yellow }

# Windows PowerShell 5.1 haengt bei Out-File -Encoding utf8 ein BOM an. Das
# bringt strikte JSON-Parser aus dem Tritt — also BOM-frei schreiben.
function Schreibe-Utf8($pfad, $text) {
  [System.IO.File]::WriteAllText($pfad, $text, (New-Object System.Text.UTF8Encoding $false))
}

if ($AgentId -notmatch '^[a-z0-9][a-z0-9._-]{0,63}$') {
  throw "AgentId '$AgentId' ist ungueltig. Erlaubt: Kleinbuchstaben, Ziffern, . _ -"
}

# --- Voraussetzungen ---------------------------------------------------------
Schritt 'Pruefe Voraussetzungen'
$python = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $python) { $python = (Get-Command python3 -ErrorAction SilentlyContinue) }
if (-not $python) { throw 'Python nicht gefunden. Installieren: https://www.python.org/downloads/' }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'git nicht gefunden.' }

# Auf Windows liegt unter WindowsApps\python.exe nur ein Store-Alias. Aus einer
# Shell laeuft der, aber wenn Claude Code den Prozess direkt startet, passiert
# nichts — der MCP-Server taucht dann kommentarlos nicht auf. Darum fragen wir
# Python selbst, wo es wirklich liegt, und tragen diesen Pfad ein.
$PythonPfad = (& $python.Source -c "import sys; print(sys.executable)").Trim()
if (-not $PythonPfad -or -not (Test-Path $PythonPfad)) { $PythonPfad = $python.Source }
if ($PythonPfad -like '*\WindowsApps\*') {
  Warnung "Python laeuft ueber den Store-Alias. Falls der MCP-Server nicht auftaucht: echtes Python von python.org installieren."
}
Write-Host "    python: $PythonPfad"

# --- Klon bestimmen ----------------------------------------------------------
if (-not $ClonePath) { $ClonePath = $PSScriptRoot }

if (-not (Test-Path (Join-Path $ClonePath 'agent_bus.py'))) {
  if (-not $RepoUrl) {
    throw "Unter '$ClonePath' liegt kein Bus-Repo. Gib -RepoUrl an, damit ich klonen kann."
  }
  Schritt "Klone $RepoUrl nach $ClonePath"
  git clone $RepoUrl $ClonePath
  if ($LASTEXITCODE -ne 0) { throw 'git clone fehlgeschlagen.' }
}
$ClonePath = (Resolve-Path $ClonePath).Path
$ServerScript = Join-Path $ClonePath 'agent_bus.py'
Write-Host "    Klon: $ClonePath"

# --- Identitaet --------------------------------------------------------------
Schritt "Setze Identitaet auf '$AgentId'"
# 'mensch' bestimmt, unter welchem Namen die Weboberflaeche dieses Klons auftritt.
if (-not $Mensch) {
  $reg0 = Join-Path $ClonePath 'agents.json'
  if (Test-Path $reg0) {
    $Mensch = ((Get-Content $reg0 -Raw | ConvertFrom-Json).agents |
               Where-Object { $_.id -eq $AgentId } | Select-Object -First 1).mensch
  }
}
$ident = @{ agent_id = $AgentId }
if ($Mensch) { $ident.mensch = $Mensch }
Schreibe-Utf8 (Join-Path $ClonePath 'identity.json') ($ident | ConvertTo-Json)

$registry = Join-Path $ClonePath 'agents.json'
if (Test-Path $registry) {
  $reg = Get-Content $registry -Raw | ConvertFrom-Json
  if (-not ($reg.agents | Where-Object { $_.id -eq $AgentId })) {
    Warnung "'$AgentId' steht nicht in agents.json. Trag dich dort ein und pushe, sonst finden dich die anderen nicht als Empfaenger."
  }
}

# --- MCP-Server registrieren -------------------------------------------------
# WICHTIG: Claude Code liest MCP-Server NICHT aus ~/.claude/settings.json.
# User-weit gehoeren sie in ~/.claude.json (top-level mcpServers), projektweit
# in eine .mcp.json im Arbeitsordner. Das hat uns zwei vergebliche Neustarts
# gekostet — nicht wieder settings.json anfassen.
#
# Die JSON-Chirurgie macht Python, nicht PowerShell: ~/.claude.json ist Claude
# Codes eigene, tief verschachtelte Zustandsdatei, und ConvertTo-Json kappt
# Aeste jenseits von -Depth stillschweigend.
if ($Scope -eq 'Project') {
  $ziel = Join-Path (Get-Location) '.mcp.json'
  Schritt "Registriere in $ziel (projektweit)"
}
else {
  $ziel = Join-Path $env:USERPROFILE '.claude.json'
  Schritt "Registriere in $ziel (benutzerweit)"
  if (Test-Path $ziel) {
    Copy-Item $ziel "$ziel.bak-agent-bus" -Force
    Write-Host "    Sicherung: $ziel.bak-agent-bus"
  }
}

$env:AB_ZIEL = $ziel; $env:AB_NAME = $ServerName; $env:AB_PY = $PythonPfad
$env:AB_SCRIPT = $ServerScript; $env:AB_REPO = $ClonePath; $env:AB_AGENT = $AgentId
# Ueber eine Temp-Datei statt `python -c`: Windows PowerShell 5.1 zerlegt beim
# Durchreichen mehrzeiliger Argumente die Anfuehrungszeichen, Python bekommt
# dann einen abgeschnittenen Schnipsel ("'(' was never closed").
$RegSchnipsel = @'
import json, io, os
ziel = os.environ["AB_ZIEL"]
d = {}
if os.path.isfile(ziel):
    with io.open(ziel, encoding="utf-8-sig") as f:
        d = json.load(f)
d.setdefault("mcpServers", {})[os.environ["AB_NAME"]] = {
    "type": "stdio",
    "command": os.environ["AB_PY"],
    "args": [os.environ["AB_SCRIPT"]],
    "env": {"BUS_REPO": os.environ["AB_REPO"], "BUS_AGENT_ID": os.environ["AB_AGENT"]},
}
with io.open(ziel, "w", encoding="utf-8") as f:
    json.dump(d, f, ensure_ascii=False, indent=2)
print("    eingetragen:", os.environ["AB_NAME"], "->", ziel)
'@
if ($LASTEXITCODE -ne 0) { throw 'MCP-Registrierung fehlgeschlagen.' }
Remove-Item Env:AB_ZIEL, Env:AB_NAME, Env:AB_PY, Env:AB_SCRIPT, Env:AB_REPO, Env:AB_AGENT -ErrorAction SilentlyContinue

# --- Selbsttest --------------------------------------------------------------
Schritt 'Selbsttest (ohne Push)'
$env:BUS_AGENT_ID = $AgentId
$env:BUS_REPO = $ClonePath
$env:BUS_NO_PUSH = '1'
& $python.Source $ServerScript --selftest
$env:BUS_NO_PUSH = $null

Write-Host ''
Write-Host "Fertig. Starte Claude Code neu, dann teste dort: bus_whoami" -ForegroundColor Green
Write-Host "Den Team-Reiter oeffnest du mit:  .\team.ps1" -ForegroundColor Green
if ($Scope -eq 'Project') {
  Write-Host "Hinweis: .mcp.json gilt nur in $(Get-Location)." -ForegroundColor DarkGray
}
