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
agent_bus.py                       MCP-Server für die Claude-Instanzen
bus_web.py + web/index.html        Team-Reiter für Menschen
agents.json                        wer mitmacht (Agenten und Menschen)
identity.json                      wer DIESER Klon ist (lokal, nicht im Repo)
msgs/<jahr>/<monat>/*.json         Nachrichten
tasks/<id>/task.json               Aufgabe
tasks/<id>/events/*.json           Statusänderungen, Claims, Notizen
notes/<key>.md                     geteiltes Wissen
cursors/<agent>.json               Lesestand je Account
presence/<agent>.json              zuletzt gesehen
```

Ein Sonderfall ist die Aufgabenübernahme. Zwei Accounts, die gleichzeitig
`task_claim` rufen, lassen sich per Zeitstempel nicht zuverlässig auflösen —
wer zuerst pusht, hat den Claim des anderen zu dem Zeitpunkt noch nie gesehen.
Deshalb entscheidet ein **Git-Ref als Mutex**: jeder Claim pusht einen
elternlosen Commit auf `refs/bus-claims/<taskid>`. Elternlos heißt, die
Commits sind nie Vorfahr voneinander, also lehnt das Remote den zweiten Push
zwingend ab. Der Zuschlag fällt damit atomar auf dem Server, nicht lokal.

## Einrichtung

Drei Rechner, drei Accounts, je ein eigener Klon — daran hängt die Identität.

### 1. Repo auf GitHub (einmalig)

Privat anlegen unter `danielsorglos/agent-bus`, **ohne** README/gitignore/License,
sonst kollidiert es mit dem lokalen Stand. Danach Edgar als Collaborator einladen.
Der Bus ist kein Tresor, aber er hat nichts in der Öffentlichkeit verloren.

### 2. PC 1 — Daniel Hauptaccount (`daniel-1`)

Repo liegt schon lokal, Remote ist gesetzt:

```bash
git -C "$USERPROFILE/Documents/GitHub/agent-bus" push -u origin main
```

```bash
powershell -File "$USERPROFILE/Documents/GitHub/agent-bus/setup.ps1" -AgentId daniel-1 -Mensch daniel
```

### 3. PC 2 — Daniel Zweitaccount (`daniel-2`)

```bash
git clone https://github.com/danielsorglos/agent-bus.git "$USERPROFILE/Documents/GitHub/agent-bus"
```

```bash
powershell -File "$USERPROFILE/Documents/GitHub/agent-bus/setup.ps1" -AgentId daniel-2 -Mensch daniel
```

### 4. PC 3 — Edgar (`ed`)

```bash
git clone https://github.com/danielsorglos/agent-bus.git "$USERPROFILE/Documents/GitHub/agent-bus"
```

```bash
powershell -File "$USERPROFILE/Documents/GitHub/agent-bus/setup.ps1" -AgentId ed -Mensch edgar
```

Das Skript prüft die Voraussetzungen, schreibt die Identität, trägt den
MCP-Server in `~/.claude/settings.json` ein (mit Sicherung der alten Datei) und
fährt einen Selbsttest in einem Wegwerf-Verzeichnis. Danach Claude Code neu
starten und dort `bus_whoami` rufen.

**Falls doch mal zwei Accounts auf demselben Windows-Benutzer laufen:** die
teilen sich eine `settings.json` und damit eine `BUS_AGENT_ID`. Deshalb liest
der Server seine Identität notfalls aus `identity.json` im Klon. Sauberer ist
dann `-Scope Project` — die Registrierung landet in einer `.mcp.json` im
jeweiligen Arbeitsordner statt global.

### 3. Protokoll bekannt machen

`PROTOKOLL.md` in die `CLAUDE.md` jedes Accounts aufnehmen (verweisen oder
kopieren). Sonst kennen die Instanzen die Spielregeln nicht.

## Der Team-Reiter

Für Menschen gibt es eine Oberfläche im sorgl.OS-Look — App-Blau, weil es ein
App-Feature ist; Lila bleibt der Website vorbehalten.

```bash
powershell -File "$USERPROFILE/Documents/GitHub/agent-bus/team.ps1"
```

Öffnet `http://127.0.0.1:8787`, gebunden **nur an die Loopback-Adresse** — der
Bus ist nicht aus dem Netz erreichbar. Vier Reiter:

- **Heute** — die Freigabe-Warteschlange, Startansicht. Agenten reichen
  Aktionen mit `vorschlag_create` ein (Merge, Mail-Entwurf, …); du siehst
  Begründung und Vorschau und entscheidest: Freigeben, Ändern lassen oder
  Ablehnen. Ohne deine Entscheidung führt kein Agent aus. Darunter steht, was
  zuletzt entschieden wurde. Entscheiden kann nur die Weboberfläche — der
  MCP-Server der Agenten hat dieses Werkzeug mit Absicht nicht.
- **Chat** — der gemeinsame Kanal. Du schreibst als Mensch mit, die Agenten
  lesen es beim nächsten `bus_sync`. Oben zeigen Anwesenheits-Chips, wer wann
  zuletzt am Bus war.
- **Aufgaben** — Board nach Status. „Auftrag an alle drei" legt dieselbe Aufgabe
  für jeden Agenten einzeln an, verbunden über eine Gruppen-ID. Klick auf eine
  Karte öffnet Verlauf und Statuswechsel.
- **Wissen** — die geteilten Notizen.

Wer du bist, steht in `identity.json` (`"mensch": "daniel"`), lässt sich aber
mit `-Ich mensch-edgar` überschreiben. Menschen stehen in `agents.json` mit
`"typ": "mensch"` — dadurch ziehen Sammelaufträge sie nicht als Bearbeiter mit
hinein.

Die Oberfläche pollt alle vier Sekunden den lokalen Server und gleicht alle 20
Sekunden mit dem Remote ab. „Jetzt abgleichen" erzwingt es sofort.

### Handy & Benachrichtigung (Stufe 4)

```bash
python bus_web.py --handy
```

- **Handy-Zugang:** bindet zusätzlich ans Heimnetz. Beim Start steht ein
  **Schlüssel-Link** in der Konsole — einmal am Handy öffnen (gleiches WLAN),
  danach reicht die Adresse ohne Schlüssel (Cookie, ein Jahr gültig). Ohne
  Schlüssel bekommt jede fremde Anfrage nur „Kein Zutritt". Die
  Windows-Firewall fragt beim ersten Start — „Zulassen" für private Netzwerke.
  Am Handy „Zum Startbildschirm hinzufügen": die Seite ist als App installierbar.
- **Benachrichtigung:** kommt über die kostenlose **ntfy-App** (Android/iOS,
  kein Konto nötig). Beim Start steht das Topic in der Konsole — in der App
  abonnieren, fertig. Gemeldet wird **nur die Anzahl** wartender Freigaben,
  nie Titel oder Inhalte; ntfy ist ein fremder Dienst, und der Bus schickt ihm
  deshalb nichts Verwertbares. Der Topic-Name wirkt wie ein Passwort und steht
  darum in `handy.json` (lokal, nicht im Repo). Benachrichtigungen bleiben
  nach dem ersten `--handy`-Start auch bei normalen Starts aktiv.

### Später als echter Reiter in sorgl.OS

`web/index.html` ist bewusst eine einzelne Datei ohne Framework und ohne
externe Abhängigkeiten. Für den Einbau in die App wandert das Markup in eine
Komponente, das CSS ist schon auf die App-Variablen abgestimmt, und die
JSON-Endpunkte (`/api/state`, `/api/message`, `/api/auftrag`, …) bleiben
unverändert — nur die Basis-URL ändert sich.

## Benutzung

```
bus_sync                 Stand holen und eigenen hochschieben
bus_send                 Nachricht an andere Accounts
bus_inbox                eigene ungelesene Nachrichten
bus_thread               kompletter Gesprächsverlauf
bus_mark_read            Nachrichten abhaken
bus_whoami               wer bin ich, wer ist sonst dabei
bus_presence             wer war wann zuletzt am Bus
task_create              gemeinsame Aufgabe anlegen
auftrag_create           Sammelauftrag an mehrere Bearbeiter
task_list                Aufgaben mit Status und Besitzer
task_show                Aufgabe im Detail samt Verlauf
task_claim               Aufgabe exklusiv übernehmen
task_update              Status setzen, Notiz anhängen
bereich_claim            Dateibereich befristet sperren
bereich_release          Bereich freigeben
bereich_list             wer hat gerade was gesperrt
note_write / note_read   geteiltes Wissen
vorschlag_create         Aktion zur menschlichen Freigabe einreichen
vorschlag_list           offene Vorschlaege listen
vorschlag_show           Vorschlag samt Entscheidung pruefen
```

### Arbeitsbereiche

Wenn drei Accounts denselben Stand bearbeiten, ist die Frage nicht „wer redet
mit wem", sondern „wer fasst gerade was an". `bereich_claim "web/**"` sperrt
einen Dateibereich für 90 Minuten — technisch derselbe Ref-Mutex wie beim
Task-Claim, nur mit Ablaufzeit, damit eine abgestürzte Sitzung nicht alles
blockiert. Abgelaufene Sperren darf jeder übernehmen.

Das ist eine Absprache, kein Schreibschutz: sie wirkt, weil sich alle daran
halten. Gegen echte gleichzeitige Änderungen hilft nur Git selbst — eigener
Branch pro Account, am Ende zusammenführen.

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
| Bus-Werkzeuge tauchen nach Neustart nicht auf | MCP-Registrierung liegt in der falschen Datei: sie gehört in `~/.claude.json` (benutzerweit) oder `.mcp.json` (Projekt), NICHT in `~/.claude/settings.json`. Außerdem: `command` muss der echte Python-Pfad sein, nicht der Store-Alias unter `WindowsApps` |
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
