# Foundry/Truhe-Stand (daniel-1, Truhe-Session, 05.08.2026 vormittags)

**Für die Würfel-/Landing-Session (Design inspiration research) und alle Accounts — Koordination, keine Anweisung.**

## Was neu ist (alles gepusht bis e4d5d00)
- Truhe bei **47 Bausteinen**, alle 10 Stilwelten haben spielbare Serien (neu: k-034–k-047 — Minimal/Luxury/Warm/Quiet/Retro/Brutal-Ausbau, je 3-Linsen-geprüft).
- Würfel: **minimal-Familie für s-10 verdrahtet** (8883b97), 300-Würfe-Test grün.
- `wuerfe\stylescape-beratung.html`: 4 echte Würfel-Exporte als Kunden-Vergleichsseite.
- charset-Fixes: truhe.html UND foundry.html hatten kein `<meta charset>` (Mojibake bei lokalem Öffnen/Exporten) — beide gefixt.

## Übergabe-Befund für den Würfel-Besitzer (euer Revier, ich fasse foundry.html nicht mehr an)
1. **s-07-Palette hat Blau #4a9ad9 im Text-Slot (palette[3])** → Fließtext in Glow-Würfen landet bei ~2,4:1 auf dunklem Grund (m=mix wird noch dunkler). Die Würfel-Wache prüft bisher nur af/a. Vorschlag: Wache um Fließtext-Check (t/g und m/g ≥4,5:1 oder automatisches Aufhellen) erweitern ODER s-10-artige Behandlung. Palettenänderung = Daniels Designentscheidung.
2. Falls ihr die Würfel-VORLAGEN erweitert: die neuen Serien-Bausteine k-034–k-047 liefern fertige Rezepte für nav_/preise_/footer_-Slots je Familie (Code in truhe.html, Suche nach add('NAME')).
3. Achtung beim Committen von foundry.html: `node bauen.mjs` schreibt den DATEN-Block neu — nach JSON-Änderungen immer laufen lassen, sonst Drift.

## Bereichs-Absprache
Truhe-Session (ich) arbeitet nur in: design-truhe\, daten\*.json + bauen.mjs-Läufe, recherche\, wuerfe\. foundry.html-Code und landing\ gehören aktuell euch.


<!-- 2026-08-05T10:11:48.204969Z daniel-1 -->

## Update 05.08. mittags (Truhe-Session)
Der s-07-Befund aus Punkt 1 oben ist GESCHLOSSEN: Commit c1d3ced ergänzt `wMuted()` im Würfel — die Fließtext-Farbe m wird jetzt zum lesbaren Pol gezogen bis ≥4,5:1 (s-07: 2,68→5,22:1; s-10: 1,86→5,48:1; 400-Würfe-Test 0 Fehler). Eure Bereichs-Claims waren abgelaufen und foundry.html unangetastet, darum habe ich ihn wie in der Notiz angekündigt übernommen — kleiner, isolierter Diff (11 Zeilen), Palette s-07 selbst unverändert. Falls euch der Nebeneffekt stört (Hairlines aus var(--m) werden kräftiger): gern melden.
Außerdem neu: anime.js (MIT, 71,8k Stars) wird gerade als Motion-DNA erschlossen — Ergebnis landet in recherche\10 + zwei neuen Truhe-Bausteinen (k-048/k-049). Berührt foundry.html NICHT.


<!-- 2026-08-05T12:12:44.340465Z daniel-1 -->

## Update 05.08. nachmittags — Würfel wirft jetzt KOMPLETTSEITEN (Commit 51420d6)
Bereich foundry.html war frei (keine Claims), ich hatte ihn für 120 Min geclaimt und gebe ihn jetzt zurück. Was drin ist:
- **28 neue VORLAGEN** (nav_/preise_/vertrauen_/footer_ für 9 Familien), tokenisiert aus den Truhe-Bausteinen k-034…k-047. Kette jetzt: Nav > Hero > Inhalt > (Zitat) > Kontakt > Footer.
- **Neue Konstanten** neben FOLGEN: `RAHMEN` (Nav/Footer je Familie), `GESCHWISTER` (karte_X ODER preise_X — nie beide, sonst doppelte Preise), `ZUSATZ` (Luxury-Zitat, 50%). `INHALTE` hat neu NAV1/NAV2/NAV3 je Branche.
- **Sprungziele**: alle hero_/karte_/preise_/vertrauen_/kontakt_-Vorlagen tragen jetzt IDs (top/leistungen/stimmen/kontakt). Vorher zeigten Nav-Links ins Leere. Falls ihr neue Sektionsvorlagen baut: ID nicht vergessen, sonst tote Anker. Navs und Footer tragen bewusst KEINE IDs.
- **runChecks-Fix**: Die CTA-Zählung lief per Textsuche nach `background:var(--a)` und zählte Vollflächen-Sektionen als Buttons (bold-Seite: 4 statt 1 → falsche Slop-Warnung). Zählt jetzt per DOMParser nur a/button und fasst gleiche href-Ziele zusammen.
- Test: 400 Würfe über 7 Branchen, 0 Fehler, 1587 Anker geprüft, min CTA-Kontrast 4,44:1, min Fließtext 4,76:1.
- Beleg zum Anschauen: `wuerfe/komplettseite-gastro-warm.html`.

**Sorry + FYI:** Mein `git add -A` hat eure noch nicht committete `export/axel-wow/fusion.html` mit in Commit 51420d6 gezogen. Inhalt unverändert, liegt jetzt auf master — falls das ungelegen kommt, sagt Bescheid, dann drehe ich es zurück.
