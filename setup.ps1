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
Write-Host "    python: $($python.Source)"

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
Schreibe-Utf8 (Join-Path $ClonePath 'identity.json') (@{ agent_id = $AgentId } | ConvertTo-Json)

$registry = Join-Path $ClonePath 'agents.json'
if (Test-Path $registry) {
  $reg = Get-Content $registry -Raw | ConvertFrom-Json
  if (-not ($reg.agents | Where-Object { $_.id -eq $AgentId })) {
    Warnung "'$AgentId' steht nicht in agents.json. Trag dich dort ein und pushe, sonst finden dich die anderen nicht als Empfaenger."
  }
}

# --- MCP-Server registrieren -------------------------------------------------
$eintrag = [ordered]@{
  command = $python.Source
  args    = @($ServerScript)
  env     = [ordered]@{ BUS_REPO = $ClonePath; BUS_AGENT_ID = $AgentId }
}

if ($Scope -eq 'Project') {
  $ziel = Join-Path (Get-Location) '.mcp.json'
  Schritt "Registriere in $ziel (projektweit)"
  if (Test-Path $ziel) { $conf = Get-Content $ziel -Raw | ConvertFrom-Json } else { $conf = [pscustomobject]@{} }
  if (-not $conf.PSObject.Properties['mcpServers']) {
    $conf | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([pscustomobject]@{})
  }
}
else {
  $ziel = Join-Path $env:USERPROFILE '.claude\settings.json'
  Schritt "Registriere in $ziel (global)"
  if (Test-Path $ziel) {
    Copy-Item $ziel "$ziel.bak" -Force
    Write-Host "    Sicherung: $ziel.bak"
    $conf = Get-Content $ziel -Raw | ConvertFrom-Json
  }
  else {
    New-Item -ItemType Directory -Force (Split-Path $ziel) | Out-Null
    $conf = [pscustomobject]@{}
  }
  if (-not $conf.PSObject.Properties['mcpServers']) {
    $conf | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([pscustomobject]@{})
  }
}

if ($conf.mcpServers.PSObject.Properties[$ServerName]) {
  $conf.mcpServers.PSObject.Properties.Remove($ServerName)
}
$conf.mcpServers | Add-Member -NotePropertyName $ServerName -NotePropertyValue ([pscustomobject]$eintrag)
Schreibe-Utf8 $ziel ($conf | ConvertTo-Json -Depth 12)

# --- Selbsttest --------------------------------------------------------------
Schritt 'Selbsttest (ohne Push)'
$env:BUS_AGENT_ID = $AgentId
$env:BUS_REPO = $ClonePath
$env:BUS_NO_PUSH = '1'
& $python.Source $ServerScript --selftest
$env:BUS_NO_PUSH = $null

Write-Host ''
Write-Host "Fertig. Starte Claude Code neu, dann teste dort: bus_whoami" -ForegroundColor Green
if ($Scope -eq 'Project') {
  Write-Host "Hinweis: .mcp.json gilt nur in $(Get-Location)." -ForegroundColor DarkGray
}
