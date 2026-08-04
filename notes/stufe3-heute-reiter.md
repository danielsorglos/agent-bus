# Stufe 3: Heute-Reiter (Freigaben) in die lifeos-App einbauen

Vorarbeit von daniel-1 am 04.08.2026 — geprueft gegen den Stand von
stand/daniel-1 (Commit 78789d6, KI-Team-Reiter ist drin). Aufwand: klein,
zwei Dateien. Der Bus liefert die Freigaben schon (bus_web /api/state hat
seit Commit 6b10923 ein Feld `freigaben`).

## 1. app/server/routes/kiteam.js — eine Zeile

In der Erlaubnisliste `ERLAUBT` den Endpunkt `entscheidung` ergaenzen:

    const ERLAUBT = new Set(['state', 'message', 'task', 'auftrag',
      'task/update', 'note', 'note/read', 'sync', 'entscheidung'])

Mehr nicht — der generische POST-Durchreicher (`/kiteam/:a`) nimmt ihn dann
mit. Der feste Zielhost 127.0.0.1:8787 bleibt (SSRF-Schutz).

## 2. app/client/src/pages/KiTeam.jsx — Abschnitt 'Heute'

`stand.freigaben` rendern, VOR dem Chat (Startblick des Menschen):

- Offene (ohne `entscheidung`-Feld) als Karten: `by` + `ts` + `titel`,
  `warum` als Text, `vorschau` als <pre> (monospace, scrollbar),
  `stufe` als Badge (hoch=danger 'wirkt nach aussen', mittel=warn
  'gemeinsamer Stand', niedrig=ok 'geringes Risiko').
- Drei Aktionen je Karte + ein Kommentarfeld:
    api.post('/kiteam/entscheidung', { id, entscheidung, kommentar })
  mit entscheidung = 'freigegeben' | 'geaendert' | 'abgelehnt'.
  Clientseitig: 'geaendert' OHNE Kommentar blocken (der Bus lehnt es
  sonst serverseitig ab — Meldung kommt als {fehler} zurueck).
- Entschiedene (neueste zuerst, ~15) kompakt darunter: Entscheidung
  farbig, Titel, wer entschieden hat, Kommentar.
- Zaehler der offenen Freigaben in den Reiter-Titel/Badge (rot).
- Vorbild fuers Verhalten: web/index.html im agent-bus-Repo,
  Funktion zeichneHeute() — 1:1 dieselben Endpunkte und Regeln.

## 3. Deployment-Hinweis (wichtig fuer app.sorglos-app.de)

Der Proxy erreicht NUR 127.0.0.1:8787 — der Reiter funktioniert also nur
dort, wo neben dem App-Server auch bus_web.py laeuft (agent-bus-Klon +
`python bus_web.py --kein-browser`). Auf Geraeten ohne Bus zeigt die Seite
wie bisher die Startanleitung (503 bus-offline). LIFEOS_INTERN=1 bleibt
Pflicht; auf Kunden-Instanzen existiert der Reiter weiterhin nicht (404).

## 4. Abnahme

1. Agent reicht per vorschlag_create einen Test ein (stufe niedrig).
2. Im App-Reiter erscheint er unter 'Heute'; Freigeben verschiebt ihn
   nach 'Was passiert ist'.
3. Zweiter Entscheidungsversuch zeigt die Schon-entschieden-Meldung.
4. 'Aendern lassen' ohne Kommentar wird clientseitig geblockt.
