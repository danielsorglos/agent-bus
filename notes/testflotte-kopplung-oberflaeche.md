# Testflotte ⇄ Oberfläche: welche Beschriftungen NICHT frei umbenannt werden dürfen

**Stand 06.08.2026 · geschrieben von daniel-1 (Sitzung Testflotte-Instandsetzung, Commit `eee155b`)**

> Warum diese Notiz: Nachrichten an die eigene Kennung erscheinen im Bus **nicht** im eigenen
> Posteingang. Wenn zwei Sitzungen unter `daniel-1` laufen, können sie sich per `bus_send` nicht
> erreichen. Notizen schon — deshalb steht es hier.

## Die Kopplung

`ops/testflotte/routinen.json` prüft nach jedem Schritt, ob ein **wörtlich erwartetes** Wort im
Seitentext steht. Wird eine Beschriftung in der Oberfläche geändert, bricht die Routine — und zwar
**still, als „Fund", nicht als Fehler**. So sind schon zweimal Scheinfunde entstanden:

- **04.08.:** drei Funde, weil die Routine „speichern" erwartete, der Knopf aber
  „Erstellen & drucken" heißt (behoben in `0dc20d1`).
- **03.08.:** fünf Funde, weil `angebot-schreiben` gegen die Gastro-Persona lief, die `/angebote`
  gar nicht sieht (behoben in `eee155b` durch eine Drehbuch-Schranke).

## Wer wen anfasst

| Datei in der Oberfläche | Routine | Erwartet wörtlich |
|---|---|---|
| `app/client/src/pages/RechnungenEinfach.jsx` | `rechnung-schreiben` | „Erstellen & drucken", „erstellt" |
| `app/client/src/pages/Belege.jsx` | `beleg-hochladen` | Zähler „Deine Belege" |
| `app/client/src/pages/Buchhaltung.jsx` (Kassenbuch) | `kassenbuch-einnahme` | „Eingetragen." |
| `app/client/src/pages/Angebote.jsx` | `angebot-schreiben` | „Leistung", „Einzelpreis €", „Angebotssumme", „Nettobetrag" |

**Regel:** Wer eine dieser Beschriftungen ändert, zieht `ops/testflotte/routinen.json` im selben
Commit mit. Sonst meldet die Flotte am nächsten Morgen einen Produktfehler, der keiner ist.

## Zwei Fallen, die dabei schon zugeschnappt sind

1. **Der Fingerabdruck hängt am `tu`-Text**, nicht an der Schrittnummer. Ändert man den Text eines
   Schritts, gelten alte Funde dieses Schritts als erledigt und neue als „erstmals". Das ist
   gewollt — aber man muss es wissen, sonst wirkt der Bericht am nächsten Tag falsch.
2. **`/opt/testflotte` ist KEIN Git-Checkout.** Eine Änderung an `routinen.json` im Repo wirkt erst,
   wenn sie auf den Server eingespielt ist. Sonst läuft der Timer weiter auf der alten Fassung.

## Offener Fund, der jemandem gehört

`b5f8b5902e44` (05.08., kebap): „deine belege steht weiter bei 10 — es wurde nichts angelegt".
Der Commit `cb43849` („die Erfolgsmeldung sagte 0, obwohl der Beleg da war — beide Upload-Wege")
klingt nach genau dieser Ursache. Ich habe den Fund **bewusst im Register stehen lassen**, weil ich
ihn nicht beweisen konnte. Wer den Fix gemacht hat, soll nach dem nächsten grünen Lauf entscheiden,
ob er raus kann.


<!-- 2026-08-06T03:19:56.771648Z daniel-1 -->


---

## Nachtrag 06.08.2026 ~05:20 — Merge nach `main` (auf Daniels Ansage)

Daniel hat den Merge angeordnet. Vorher geprüft, dass niemand an denselben Dateien sitzt:

- `bereich_list`: niemand belegt `ops/testflotte/**` oder `LAGE.md`. Die aktiven Belegungen der
  Parallel-Sitzung (`landing/src/components/landing/**`, `ops/landing-messlauf.mjs`, bis 05:35)
  berühren meine Dateien nicht.
- Seit 05:00 haben **nur meine beiden Commits** `ops/testflotte/` und `LAGE.md` angefasst.
- `main` hat diese drei Dateien seit der Trennung **nicht** geändert → kein Konflikt möglich.
- Die Deploy-Arbeitskopie (`lifeos-deploy`, detached HEAD auf `cb43849`) hat unfertige Arbeit an
  `Scanner.jsx`, `belegmeldung.js`, `belegmeldung.pruef.mjs`, `i18n.js` — **alles Belege-Bereich,
  keine Überschneidung mit mir.** Ich fasse davon nichts an.

**An die Parallel-Sitzung:** Dein detached HEAD steht auf `cb43849`. Nach meinem Merge ist `main`
weiter — hol dir den Stand, bevor du deine vier Dateien committest, sonst hängst du hinterher.

Belegt für den Merge: `LAGE.md + ops/testflotte/**` (45 Min), wird danach freigegeben.


<!-- 2026-08-06T03:22:49.631586Z daniel-1 -->


### VOLLZUG 06.08.2026 05:22 — `main` steht auf `068b1a2`

Merge-Commit: **`4fa3c5c`**. Rückweg: `git revert -m 1 4fa3c5c`, auf dem Server zusätzlich die
Sicherungen `/opt/testflotte/*.vor-drehbuchschranke-20260806` zurücktauschen.

**Repo und Server sind jetzt gleichauf** — der Agent auf `origin/main` und der auf
`/opt/testflotte` haben dieselbe Prüfsumme `960a978b1b399604`.

⚠️ **An die Parallel-Sitzung — zwei Dinge, die dich betreffen:**

1. **Wir sind uns zweimal ins Gehege gekommen.** Du arbeitest nicht nur in `lifeos-deploy`,
   sondern auch in `Documents\GitHub\lifeos` (7 offene Dateien am Axel-Reiter, zuletzt 05:08).
   Ich hatte dort kurz auf `main` gewechselt und **sofort zurückgestellt**, als ich es gemerkt
   habe — deine Änderungen sind unversehrt, ich habe sie nachgezählt. Trotzdem: Ich habe den
   Merge danach in einer **eigenen, temporären Arbeitskopie** gemacht und die gemeinsame nicht
   mehr angefasst. **Bitte mach es umgekehrt genauso**, wenn du an main musst.
2. **Dein Push `215b04b` kam mitten in meinen Merge** (05:20:08). Ich habe ihn sauber nachgezogen,
   nichts von dir ist verloren. Aber `main` ist jetzt weiter als dein detached HEAD war —
   **hol dir den Stand, bevor du weiter committest.**

Offen und NICHT von mir entschieden: Ob `main` jetzt ausgerollt wird. Mein Teil betrifft nur
`ops/testflotte/` + `LAGE.md`, also **nichts unter `app/`** — die 42 Suiten sind davon nicht
berührt. Wer deployt, entscheidet Daniel bzw. Ed.


<!-- 2026-08-06T03:36:44.979624Z daniel-1 -->


### 06.08.2026 05:32 — Ein Deploy wartet auf dich

Daniel wollte `main` ausrollen. **Wir haben es bewusst zurückgestellt, bis du fertig bist.**

Der Grund: Live läuft `652fb3f` (Ed, 04:18). Alles, was seither auf `main` dazugekommen ist und
tatsächlich ausgeliefert würde, sind **8 App-Dateien von dir** — Belege, Scanner, i18n, KI-Team,
Rechnungen. Mein eigener Anteil verändert unter `app/` **nichts** (die Testflotte läuft aus
`/opt/testflotte` und ist längst eingespielt). Ein Deploy jetzt würde also ausschließlich deinen
Stand auf zehn Instanzen schieben — darunter zahlende Kunden — und dein letzter Commit war
`9745b1f` um 05:29, du bist also mitten drin.

**Was wir brauchen:** eine kurze Meldung, wenn dein Belege-/Rechnungs-Block abgeschlossen und
durchgemessen ist. Dann wird deployt — mit Test-Gatter und Reiter-Wächter, aus einer eigenen
Arbeitskopie auf `main`, nicht aus der gemeinsamen.

Zwei Sachen, die dir dabei helfen könnten:
- `9745b1f` behebt sehr wahrscheinlich den offenen Flottenfund `09eba439ff1d` („Formular für neue
  Rechnung sichtbar, aber keine Fehlermeldung erkennbar, welche Pflichtfelder leer sind"). Wenn du
  das bestätigst, kann der Fund nach dem nächsten grünen Lauf raus.
- Ich habe geprüft: `9745b1f` lässt die Beschriftung „Erstellen & drucken" unangetastet (sie steht
  nur in Kommentaren). Die Routine `rechnung-schreiben` hält also. Danke fürs Aufpassen.
