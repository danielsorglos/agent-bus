# Axel als Ast-Figur statt CRT-Gehaeuse — gemeinsame Faktenlage

Stand 06.08.2026, erhoben von daniel-1 (Sitzung "Claude Code Accounts
Kommunikation") auf Daniels Wunsch. Zwei Sitzungen arbeiten parallel an Axel:
eine an der Webseite (Sitzung "Design inspiration research"), eine an der App.
Diese Notiz haelt die geprueften Fakten, damit niemand doppelt sucht.

## Befund 1 — Axel am Ast EXISTIERT bereits vollstaendig

Nicht neu zu bauen. Im Datenpaket `ops/axel-paket/axel-sprite-data-v2.json`
liegt Axel als Zeichenmatrizen + Palette (KEIN Bild): 64 x 56 Punkte, alle
11 Zustaende (neutral, blink_half, blink_closed, listen, thinking, question,
joy, warning, sad, error, writing). Das Sprite zeigt die GANZE Figur —
Faultier haengt mit beiden Haenden am Ast, Arme, Bauch, Fuesse, Blaetter.
Eigene feste Ast-Ebene (`fixedBranchLayer`); Arme duerfen sie nur ueberdecken.

Selbst ansehen: `node ops/axel-paket.mjs <zielordner>` erzeugt Kontaktbogen
aller 11 Zustaende + neutral in 8-fach. Nichts wird veraendert, reines Rendern.

## Befund 2 — die App wirft das weg

`AxelCrt.jsx` (604 Zeilen) schneidet aus dem Sprite NUR das Gesicht heraus
(42 x 32, Ausschnitt x11 y16) und setzt es in ein gezeichnetes SVG-Roehren-
gehaeuse. Ast, Arme, Bauch, Fuesse sind in der App unsichtbar.
Erzeugt werden die PNGs von `ops/axel-app-export.mjs`.

## Befund 3 — KONFLIKT mit der geltenden Markenregel

`~/.claude/skills/sorglos-brand/SKILL.md` sagt seit 30.07.2026 verbindlich:
"Axel = CRT-Flugschiff mit Pixelgesicht: Roehrengeraet-Koerper, 3 Schubwellen
unten, Begleiter-Drohne mit Pixel-Sonnenbrille. ... Keine Requisiten, keine
Gliedmassen."

Daniels Wunsch vom 06.08. (Gehaeuse weglassen, Axel am Ast zeigen, Arme und
Fuesse animieren) steht dieser Regel direkt entgegen. Das ist KEIN Fehler von
irgendwem — die Regel entstand, WEIL nur das Gesicht gezeigt wurde. Aber sie
muss bewusst geaendert werden, nicht stillschweigend unterlaufen. Und sie gilt
fuer Webseite UND App: aendert nur eine Seite, zerfaellt die Marke in zwei
Figuren.

ENTSCHEIDUNG LIEGT BEI DANIEL. Bis dahin baut niemand die Regel um.

## Befund 4 — technisch waere es einfacher, nicht schwerer

- Heute zwei Aufloesungswelten in einer Figur: SVG-Gehaeuse (glatt, jede
  Groesse) + Pixelsprite (nur ganzzahliger Zoom). Der Grossteil der 604 Zeilen
  in AxelCrt.jsx verwaltet genau diese Spannung. Ohne Gehaeuse: ein Rasterbild.
- Animationsprinzip steht schon im Paket und passt exakt zum Sprite-Sheet-
  Prinzip: "Vollstaendige Sprites austauschen; keine Verformung, kein Rigging."
  Fertige Definitionen fuer idle, blink, thinking, writing sind da.
- `ops/axel-ast-animation.mjs` beweist die Animierbarkeit schon (Schweben,
  Schattenreaktion, Blinzeln, laufende Statuspunkte).
- Sprite Sheet: `kontaktbogen()` in `ops/axel-paket.mjs` fuegt bereits alle
  Zustaende per sharp zu EINEM Bild zusammen — bisher nur als Pruefbogen, ohne
  Koordinaten. Ein App-taugliches Sheet ist von dort ein kleiner Schritt.
  Nutzen: die App laedt heute 11 einzelne PNGs und tauscht die Bildquelle;
  bei 60-ms-Blinzeln ist das die falsche Grundlage.

## Offene Designfrage, falls das Gehaeuse faellt

Das Gehaeuse traegt die STATUSLINSE (genau ein Zeichen: ! ? … X) und den
sorgl.OS-Schriftzug. Ohne Gehaeuse brauchen die einen Platz. Drei Wege:
Sprechblase im Pixelraster / die vorhandene Begleiter-Drohne schwebt ueber
Axel / nur Mimik ohne Statuszeichen. Vorschlag daniel-1: Drohne behalten —
sie ist gebaut, haengt an nichts und bleibt markenkonform.

## Arbeitsteilung (Vorschlag, damit nichts doppelt laeuft)

- Webseite (`landing/src/components/landing/axel-*`): Design-Sitzung
- App (`app/client/src/components/Axel*`, `ops/axel-*`): diese Sitzung
- Markenregel in SKILL.md: erst nach Daniels Entscheidung, dann EINMAL zentral

ACHTUNG Bus-Eigenheit: Beide Sitzungen laufen auf PC 1 und treten hier als
DIESELBE Agent-ID `daniel-1` auf. Ein `bereich_claim` trennt uns also nicht —
die Abstimmung laeuft ueber Direktnachricht zwischen den Sitzungen.
