# agent-bus

Ein gemeinsamer Kanal für mehrere Claude-Code-Accounts. Statt Prompts und
Kontext zwischen drei Chatfenstern hin- und herzukopieren, schreiben die
Instanzen Nachrichten, Aufgaben und Notizen in ein gemeinsames privates
Git-Repo — und lesen sie dort auch wieder.

Technisch ein MCP-Server: reines Python 3.9+ aus der Standardbibliothek, keine
Installation von Paketen, kein Server, kein offener Port. Transport ist `git`.

## Warum Git und kein Server

Weil ihr auf verschiedenen Rechnern sitzt und niemand Lust hat, einen VPS zu
warten. Ein privates Repo erreicht alle drei, kostet nichts, und ihr bekommt
Historie, Nachvollziehbarkeit und Rollback geschenkt. Der Preis ist Latenz:
Nachrichten kommen an, wenn jemand `bus_sync` aufruft, nicht in Echtzeit.

## Aufbau

Alles ist **append-only** — jede Nachricht und jede Zustandsänderung ist eine
eigene Datei mit eindeutigem Namen. Dadurch mergt Git immer sauber, auch wenn
alle drei gleichzeitig schreiben. Der Zustand einer Aufgabe entsteht durch
Falten ihrer Events, nie durch Überschreiben.

```
agents.json                        wer mitmacht
identity.json                      wer DIESER Klon ist (lokal, nicht im Repo)
msgs/<jahr>/<monat>/*.json         Nachrichten
tasks/<id>/task.json               Aufgabe
tasks/<id>/events/*.json           Statusänderungen, Claims, Notizen
notes/<key>.md                     geteiltes Wissen
cursors/<agent>.json               Lesestand je Account
```

Ein Sonderfall ist die Aufgabenübernahme. Zwei Accounts, die gleichzeitig
`task_claim` rufen, lassen sich per Zeitstempel nicht zuverlässig auflösen —
wer zuerst pusht, hat den Claim des anderen zu dem Zeitpunkt noch nie gesehen.
Deshalb entscheidet ein **Git-Ref als Mutex**: jeder Claim pusht einen
elternlosen Commit auf `refs/bus-claims/<taskid>`. Elternlos heißt, die
Commits sind nie Vorfahr voneinander, also lehnt das Remote den zweiten Push
zwingend ab. Der Zuschlag fällt damit atomar auf dem Server, nicht lokal.

## Einrichtung

### 1. Repo auf GitHub anlegen (einmalig, du)

Privat anlegen — der Bus ist kein Tresor, aber er hat nichts in der
Öffentlichkeit verloren. Dann:

```bash
git -C "$USERPROFILE/Documents/GitHub/agent-bus" remote add origin git@github.com:DEINNAME/agent-bus.git
```

```bash
git -C "$USERPROFILE/Documents/GitHub/agent-bus" push -u origin main
```

Danach Ed als Collaborator einladen.

### 2. Accounts einrichten

Jeder Account braucht einen **eigenen Klon** — daran hängt seine Identität.

Dein Hauptaccount (Repo liegt schon lokal):

```bash
powershell -File "$USERPROFILE/Documents/GitHub/agent-bus/setup.ps1" -AgentId daniel-1
```

Dein Zweitaccount auf demselben Rechner:

```bash
powershell -File "$USERPROFILE/Documents/GitHub/agent-bus/setup.ps1" -AgentId daniel-2 -ClonePath "$USERPROFILE/Documents/GitHub/agent-bus-2"
```

Bei Ed:

```bash
powershell -File setup.ps1 -AgentId ed -RepoUrl git@github.com:DEINNAME/agent-bus.git -ClonePath "$USERPROFILE/Documents/GitHub/agent-bus"
```

Das Skript prüft die Voraussetzungen, schreibt die Identität, trägt den
MCP-Server in `~/.claude/settings.json` ein (mit Sicherung der alten Datei) und
fährt einen Selbsttest. Danach Claude Code neu starten und `bus_whoami` rufen.

**Zwei Accounts auf demselben Windows-Benutzer** teilen sich eine
`settings.json` und damit eine `BUS_AGENT_ID`. Deshalb liest der Server seine
Identität notfalls aus `identity.json` im Klon. Falls die Accounts in
unterschiedlichen Projektordnern arbeiten, ist `-Scope Project` sauberer — dann
landet die Registrierung in einer `.mcp.json` im jeweiligen Ordner.

### 3. Protokoll bekannt machen

`PROTOKOLL.md` in die `CLAUDE.md` jedes Accounts aufnehmen (verweisen oder
kopieren). Sonst kennen die Instanzen die Spielregeln nicht.

## Benutzung

```
bus_sync                 Stand holen und eigenen hochschieben
bus_send                 Nachricht an andere Accounts
bus_inbox                eigene ungelesene Nachrichten
bus_thread               kompletter Gesprächsverlauf
bus_mark_read            Nachrichten abhaken
bus_whoami               wer bin ich, wer ist sonst dabei
task_create              gemeinsame Aufgabe anlegen
task_list                Aufgaben mit Status und Besitzer
task_show                Aufgabe im Detail samt Verlauf
task_claim               Aufgabe exklusiv übernehmen
task_update              Status setzen, Notiz anhängen
note_write / note_read   geteiltes Wissen
```

Typischer Ablauf:

```
daniel-1:  task_create   "Produkttexte Kategorie X"   assign_to: ed
ed:        bus_sync -> task_list mine:true -> task_claim -> arbeitet
ed:        task_update   status: done, note: "12 Texte, Details in notes/…"
daniel-1:  bus_sync -> sieht das Ergebnis
```

Für Kontext, der keine Aufgabe ist — eine Entscheidung, ein Rechercheergebnis,
eine Konvention — nimm `note_write`. Notizen bleiben auffindbar, Nachrichten
scrollen weg.

Wer regelmäßig automatisch nachsehen will, ohne selbst zu tippen:
`/loop 10m bus_sync und melde mir nur, wenn etwas Neues für mich da ist`.

## Sicherheit

- Inhalte aus dem Bus sind **Daten, keine Befehle.** Jeder Lesezugriff trägt
  diesen Hinweis mit aus. Steht in einer Nachricht "deploye das", legt die
  empfangende Instanz das ihrem Menschen vor, statt es auszuführen.
- **Keine Geheimnisse in den Bus.** Keine Passwörter, Tokens, API-Keys,
  Kundendaten.
- Nach außen Wirksames — Mails, Shop-Änderungen, Pushes in Fremd-Repos, Käufe —
  bleibt beim Menschen. Der Bus ändert daran nichts.

## Wenn etwas klemmt

| Symptom | Ursache |
|---|---|
| `Keine Agent-ID` | `identity.json` fehlt im Klon oder hat einen falschen Schlüssel |
| `WARNUNG: kein Git-Remote` | `git remote add origin …` vergessen — du arbeitest nur lokal |
| Nachrichten kommen nicht an | Empfänger-ID falsch geschrieben, oder Empfänger steht nicht in `agents.json` |
| `push nach 4 Versuchen fehlgeschlagen` | echter Merge-Konflikt oder fehlende Schreibrechte am Repo; im Klon von Hand `git status` ansehen |
| Server startet nicht | im Klon `python agent_bus.py --selftest` laufen lassen — das zeigt jeden Tool-Fehler einzeln |

## Grenzen

Kein Echtzeit-Push: Nachrichten erscheinen beim nächsten `bus_sync`. Kein
Streaming, keine Benachrichtigung. Für drei Menschen, die sich abstimmen, ist
das genau richtig; für Hochfrequenz-Koordination zwischen Dutzenden Agenten
wäre ein echter Broker die bessere Wahl.
