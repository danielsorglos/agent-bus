# Axel-Kanon — GEHAEUSE GESTRICHEN (Stand 06.08.2026)

**Fuer alle drei Konten verbindlich. Wer nach dieser Notiz an Axel arbeitet, baut nach dem
neuen Stand — aeltere Vorlagen mit Gehaeuse sind ungueltig, nicht "noch nicht umgebaut".**

## Daniels Entscheidung von heute (woertlich)
"flugschiff soll raus. das soll nun die letzte version von axel sein, weg mit dem bildschirm,
der kam bislang bei keinem gut an"

Das CRT-Roehrengehaeuse faellt ERSATZLOS weg: kein Gehaeuse, keine Antriebsduese, keine
Schubwellen, kein Glas, keine Scanlines, keine Drehknoepfe, kein sorgl.OS-Schriftzug auf dem
Geraet. "Letzte Version" heisst: Zielzustand, nicht Zwischenschritt.

## Axel besteht ab jetzt aus ZWEI Teilen
1. **Pixel-Faultier** 64x56, eingefroren als AXEL_SPRITE_APPROVED_V2. Es IST die Figur, nicht
   mehr der Inhalt eines Bildschirms. Nicht neu zeichnen, keine Bild-KI, nur skalieren und
   platzieren — und zwar ganzzahlig.
2. **Begleiter-Drohne**, an nichts befestigt. Ruhezustand = Pixel-Sonnenbrille mit Mund.
   Bei einem Zustand ausschliesslich EIN Zeichen: ! ? … X. Nie beides. Wechsel per 70ms
   Quetsch-Tausch (scaleY 0.08 -> 1). Zeichen als eigene Vektorformen, NIE als Schriftzeichen.
   Die Drohne traegt die Statusanzeige, seit das Gehaeuse sie nicht mehr aufnimmt — von Daniel
   selbst vorgegeben ("dass sich das gesicht der drohne aendert und dann ein X ? … kommt").

## Baum-Kulisse — von Daniel freigegeben ("sieht richtig geil aus")
lifeos/ops/axel-baum.mjs erzeugt ops/axel-paket/kulisse/axel-baum.png (160x112, transparent),
Faultier dockt bei x=48 / y=20 an. Deterministisch, nur Palettenfarben.
Abnahme: node ops/axel-kulisse-pruefen.mjs  (Exit 0 = rastertreu, nur Palette, keine weichen Kanten)
Commit b0b1179 auf stand/daniel-1.

## Fallen, die schon Zeit gekostet haben
- Keine --custom-property-Schreibvorgaenge im rAF-Takt. Das war die BELEGTE Ursache des
  Tablet-Ruckelns (Style-Recalc ueber ~200 SVG-Knoten), nicht die SVG-Filter (Paint war 3,9%).
- Sprite nur ganzzahlig vergroessern, sonst Matsch.
- Statuszeichen als Schriftzeichen sacken auf der Schriftlinie ab.
- MCP-Vorschau meldet bei der Landingpage 0x0 — Abnahme ueber node ops/landing-messlauf.mjs
  (4 Pflichtbreiten + Flugabnahme), nicht ueber die Browser-Vorschau.

## Was gerade laeuft (daniel-1)
Vollstaendige Inventur aller 27 betroffenen Dateien plus drei Umbau-Entwuerfe mit Jury.
Offene Kernfrage: an Axels Bildschirm haengt die Demo/"der Fernseher" (axel-demo.tsx) —
wenn der Bildschirm faellt, braucht diese Funktion eine neue Buehne. Wird Daniel als
Entscheidung vorgelegt, nicht still weggeraeumt.

NICHT ANFASSEN ohne Absprache mit daniel-1: landing/src/components/landing/axel-*.*,
landing/src/routes/axel.tsx, landing/src/styles/axel-figur.css — dort laeuft der Umbau.
