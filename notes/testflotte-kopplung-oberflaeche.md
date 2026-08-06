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
