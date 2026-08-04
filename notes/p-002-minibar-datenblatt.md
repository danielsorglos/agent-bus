# p-002 miniBar Pforzheim — Intake-Datenblatt (aus E:\ übertragen)

**Geliefert von daniel-2 am 04.08.2026 für Task t-55687cfa9bdb.**
Quellen ausschließlich: `E:\Sorglos-app\Webseiten-Akquise\minibar-pforzheim\`
(BEFUND.md 30.07. · LOVABLE_AUFTRAG_1/7 · LOVABLE_FINAL.md · UEBERGABE_WAS_ICH_BRAUCHE.md ·
AUFTRAGSBESTAETIGUNG_ENTWURF.md) und `…\Gastro-Bausatz\`.

**Wahrheitsstatus je Angabe:** `belegt` = mit Quelle/Messung im Datenblatt ·
`bestätigt` = vom Inhaber freigegeben · `Annahme` = von uns gesetzt, ungeprüft ·
`offen`/`FEHLT` = steht nirgends.
🚨 **Übergreifende Wahrheit, die alles andere rahmt: Es hat noch KEIN Termin mit dem
Inhaber stattgefunden.** Es gibt daher NICHTS in der Kategorie „bestätigt" — kein Wort
der Seite ist mit dem Betrieb abgestimmt. Wer das übersieht, baut Stylescapes auf Sand.

---

## 1. Konkrete Leistung, Zielkunde, Ort/Umkreis

| Angabe | Wert | Status |
|---|---|---|
| Betrieb | miniBar Pforzheim — Cocktailbar / Nachtbar | belegt |
| Adresse | Berliner Str. 4–6, 75172 Pforzheim | belegt (alle Quellen einig) |
| Öffnung | Fr + Sa ab 19:00, sonst geschlossen | **Annahme** — vier Quellen, vier Zeiten (Google 19–24, Instagram 18–01, oeffnungszeitenbuch 16–01/Sa ab 12, nochoffen „unbekannt"). Wir nahmen bewusst das ENGERE Fenster (Google): zu früh Kommen erzeugt die 1-Stern-Bewertung, zu spät Kommen findet offen. Im Code `ZEITEN_BESTAETIGT=false`, JSON-LD gibt KEINE Zeiten aus. |
| Zielkunde | im Datenblatt nicht als Persona definiert; abgeleitet aus Bau: Gäste vor Ort, Handy-first, Abendpublikum | **FEHLT** (nicht erfunden) |
| Umkreis | Pforzheim; ~70 km von Rheinmünster = **außerhalb des SAFE-Reviers (≤35 km)** — Einspruch steht in BEFUND.md, Daniel hat sich bewusst dafür entschieden | belegt |
| Bekannte Drinks | Lillet Winter · 47 Gin Tonic · Whiskey Sour | belegt (Google-Menü-Highlights) |
| Getränkekarte | **FEHLT** — muss der Inhaber liefern (Foto je Seite oder Datei) |
| Preisniveau | **verworfen** — 1–20 € vs. 1–10 € widersprüchlich, kommt NICHT auf die Seite | belegt-verworfen |

## 2. Der EINE primäre CTA + funktionierender Kontaktweg

| Angabe | Wert | Status |
|---|---|---|
| **Primärer CTA** | **„Anrufen"** — `tel:+4972314439320` (im Sticky-Kopf UND im Hero) | belegt |
| Sekundär | „Route öffnen" (Google-Maps-Link auf die Adresse) | belegt |
| Telefon | 07231 4439320 | belegt (alle Quellen) |
| E-Mail | minibarpforzheim@gmail.com | belegt (2 Quellen) — steht nur in der Fußzeile als `mailto:` |
| WhatsApp | **FEHLT** — nirgends belegt, bewusst nicht gebaut |
| Kein Formular | Kein Bestellsystem, keine Reservierung, kein Newsletter (Auftragsbestätigung: „nicht enthalten") | belegt |
| ⚠️ Kalte Werbe-Mail an den Betrieb | **verboten** (§7 UWG) — Ansprache persönlich oder per Brief | belegt |

## 3. Logo / Farben / Bestandsmarke

| Angabe | Wert | Status |
|---|---|---|
| Logo | **kein Logo vorhanden/übergeben.** Gebaut ist eine reine **Wortmarke**: „miniBar" mit „pforzheim" klein darunter | belegt |
| Rechte am Logo | falls doch eines existiert und von einer Agentur stammt: Rechte liegen dort → nachfragen | belegt (Regel) |
| Hintergrund | `#0B0B0F` | belegt |
| Flächen | `#15151C` | belegt |
| Text / Nebentext | `#F5F5F7` / `#A1A1AA` | belegt |
| Akzent 1 (Magenta) | `#FF2E93` | belegt |
| Akzent 2 (Cyan) | `#22D3EE` | belegt |
| 🚨 Kontrast-Regel | Weiß auf Magenta = **3,1:1 → fällt durch**. Magenta-Knöpfe bekommen **dunklen Text `#0B0B0F` (5,7:1)**. Magenta NIE als Textfarbe auf Dunkel. | belegt, gemessen |
| Schriften | **nur Systemschriften** (Tailwind-Stack). Kein Google Fonts, kein Webfont-Download, kein `@import` | belegt |
| Stimmung | dunkle Nachtbar, Neonlicht Magenta/Türkis | belegt |

## 4. Echte Fotos vorhanden?

**Nein — es gibt KEINE echten Fotos des Betriebs.** Der aktuelle Stand läuft mit
**KI-Platzhaltern**, die im Entwurf als „Beispielbild" gekennzeichnet sind. Status: belegt.

- Vorhanden im Bau: 57 Dateien in `vorschau/assets/` (WebP in mehreren Größen), u. a.
  `bar-1/2/3`, `aperol-spritz`, weitere Getränkebilder + `og-minibar.jpg`.
- **Gebraucht vom Inhaber** (Liste steht fertig in UEBERGABE_WAS_ICH_BRAUCHE.md):
  1 Bild quer für den Kopf (Raum mit Neonlicht, ohne Menschen) · 6 quadratische fürs
  Raster · 4–6 Getränkebilder einzeln vor dunklem Hintergrund.
- 🚨 **Rechte-Lage, bevor irgendein Bild verwendet wird:** eigene Handyfotos = ok ·
  Fotograf/Agentur = Rechte liegen dort, ohne schriftliche Übertragung nicht verwenden ·
  Instagram-Bilder nur, wenn er sie selbst gemacht hat · **Google-Eintrag-Fotos gehören
  meist den Gästen → NICHT verwenden** · erkennbare Gäste brauchen Einwilligung,
  Personal ebenso → am besten Bilder ohne Menschen.
- 🚨 **Übertragungsweg:** NICHT per WhatsApp (rechnet herunter) → AirDrop, WeTransfer/
  Cloud-Ordner, E-Mail mit „Originalgröße", notfalls Handy anschließen.

## 5. Belegbare Vertrauensargumente

| Argument | Status |
|---|---|
| **„4,7 ★ aus 82 Google-Bewertungen"** (mit Link zum Eintrag) — das EINZIGE, das auf die Seite darf | belegt |
| Instagram: instagram.com/minibar_pforzheim · Facebook: facebook.com/minibarpforzheim | belegt |
| „Raucherbar" | belegt über Instagram-Bio (in Auftrag 7 aufgenommen) — im BEFUND vom 30.07. war es noch als unbelegt verworfen; jüngere Quelle gewinnt |
| ❌ Kundenstimmen / Testimonials | **verboten und ersatzlos gestrichen** — der Entwurf sah „sinngemäße" Google-Rezensionen mit Vorname+Initiale vor: das wären **erfundene Zitate echter Menschen**. Bewertungstexte gehören ihren Verfassern; nur die Sternezahl darf genannt werden. |
| ❌ Fremde Beschreibungstexte | z. B. „echtes Juwel unter Pforzheims Bars" (city-pforzheim.com) — urheberrechtlich geschützt, nur als Tonalitäts-Hinweis, nie kopieren |
| ❌ Facebook-Bewertung | widersprüchlich (5,0/15 vs. 4,4/14) → raus |
| ❌ Barrierefreiheit/Rollstuhl | nur ein Google-Symbol, unbestätigt → **bewusst nicht behauptet**, offene Frage an den Inhaber |
| ❌ „Bar und EC-Karte" | unbelegt → raus |

## 6. Stil-No-Gos + gewünschte Wirkung

**Wirkung:** dunkle Nachtbar, ruhig und sachlich; Wirkung soll aus der Menge echter
Fakten entstehen, nicht aus Adjektiven. Status: belegt.

**No-Gos (alle belegt):**
- Verbotene Wörter auf der Leistungsseite: „hochwertig", „modern", „professionell",
  „einzigartig", „Premium"; keine Aufwands- oder Preisangaben, kein Wettbewerbsvergleich.
- **Kein automatisches „Jetzt geöffnet"-Abzeichen** — bei unbestätigten Zeiten wäre genau
  das der Fehler, den die Seite heilen soll.
- Keine externen Anfragen: keine fremden Schriften, keine Karten-Kacheln, keine Skripte
  → **deshalb kein Cookie-Banner nötig** (es wird nichts gespeichert).
- Nie „rechtskonform"/„rechtssicher"/„abmahnsicher" versprechen. Formulierung:
  „mit den üblichen Pflichtseiten nach aktuellen Vorlagen — die finale Prüfung macht Ihr Anwalt."
- Keine Preise auf der Seite · `href="#"` verboten · keine neue Abhängigkeit.
- Öffnungszeiten liegen im Code an **genau einer** Stelle (Hero, Tabelle, Schema lesen daraus).

## 7. Was hat der Inhaber zur Veröffentlichung freigegeben?

**NICHTS. Es gibt keinerlei Freigabe — der Inhaber wurde noch nicht gesprochen.**
Status: belegt (Zustand, nicht Annahme).

- Der Bau steht deshalb auf `ENTWURF = true`, **`noindex, nofollow`** auf allen Seiten,
  inklusive der drei Entwurfsseiten `/quellen`, `/heute`, `/leistung`.
- 🚨 **Fremder Firmenname auf einer von uns veröffentlichten Adresse ist verboten,
  solange der Inhaber nicht zugestimmt hat.** Vorschau-URL mit niemandem außer dem
  Inhaber teilen.
- Übergabe ist bewusst **offline** gedacht (ZIP + `START.txt`, lokaler Start via
  `py -m http.server 8000`), weil der Termin in einer Bar mit schlechtem Empfang stattfindet.

### Die fünf offenen Fragen, die den Abschluss blockieren
1. **Domain `minibar-pforzheim.de` — wer verwaltet sie, gibt es Zugangsdaten?** Erste Frage
   überhaupt. Darauf läuft heute eine **leere WordPress-Installation** („Hello world!",
   „Sample Page", /impressum + /datenschutz + /kontakt je 404, WP 7.0.2, Theme
   twentytwentyfive, Hoster IONOS, 217.72.204.163) — gemessen am 30.07.2026.
   Ohne Zugang kann die fertige Seite nirgendwo hin.
2. **Verbindliche Öffnungszeiten** (erst dann `ZEITEN_BESTAETIGT=true`).
3. **Fotos + Rechte je Bild** (siehe Punkt 4).
4. **Getränkekarte** — und die Entscheidung: Preise auf die Seite oder nicht?
5. **Impressumsdaten**: Firmierung + Rechtsform, Inhabername, Steuer-/USt-IdNr,
   Gaststättenerlaubnis (welche Behörde), ggf. Handelsregister, Hoster für die
   Datenschutzerklärung. Zusatzfrage: Zugang wirklich rollstuhlgerecht? Zweiter
   Ansprechpartner?

### Kaufmännischer Stand (aus AUFTRAGSBESTAETIGUNG_ENTWURF.md, Entwurf — nicht versandt)
- **250 € einmalig** (Firmenstart-Aktion, gilt für die ersten ZWEI Aufträge), regulär
  **890 €** (mehrseitig ab ~3 Seiten — PREISKATALOG hat diese Stufe am Fall miniBar
  entschieden). Untergrenze 500 €, wird nie ausgesprochen. Eine Zahl, keine Spanne.
- 250 € ist auch die Grenze der Kleinbetragsrechnung (§ 33 UStDV) → **ohne Steuernummer
  stellbar**; Pflichtangaben: beide GbR-Namen, Datum, Art/Umfang, Entgelt, § 19-Hinweis.
- Pflege 15 €/Monat, **getrennte, freiwillige** Position, monatlich kündbar.
- Absender muss **beide Namen** tragen: „Gerter & Loraj GbR — Daniel Gerter · Edgar Loraj".
- Domain-Zusage nur MIT Vorbehalt („sobald uns der Zugang vorliegt").

---

## Dateien, die NUR auf E:\ liegen (nicht im lifeos-Repo)

Gegengeprüft: im Repo existiert zu miniBar **einzig**
`Sorglos-app/3_Verkauf_und_Gespraeche/RECHNUNG_MINIBAR_ENTWURF.md`. Alles Folgende ist
ausschließlich lokal auf dem Laptop:

```
E:\Sorglos-app\Webseiten-Akquise\minibar-pforzheim\
  BEFUND.md                      ← Messungen 30.07., verworfene Angaben, Einspruch
  UEBERGABE_WAS_ICH_BRAUCHE.md   ← Zettel für den Termin (Fotos, Karte, Domain)
  AUFTRAGSBESTAETIGUNG_ENTWURF.md
  LOVABLE_AUFTRAG_1.md … _10_ZWEI_SAETZE.md   (11 Auftragsdateien)
  LOVABLE_FINAL.md               ← Übergabepaket-Auftrag, Entwurfsseiten, Zustandsliste
  ZETTEL_FUER_MORGEN.html        ← Druckfassung für den Termin
  vorschau\                      ← gebauter Stand: index.html, /heute /leistung /quellen
                                    /impressum /datenschutz, assets (57 Dateien), fonts,
                                    robots.txt, _headers, START.txt, og-minibar.jpg
  ABNAHME_CLAUDE_01-08\          ← Abnahme-Screenshots 1920 + 390 je Seite, befunde.txt
E:\Sorglos-app\Webseiten-Akquise\Gastro-Bausatz\
  PROMPT_0_HAUSORDNUNG.md · README.md · ABLAUF.md · AUFTRAG_1–4 ·
  AUFSATZ_FRISEUR.md · AUFSATZ_HOTEL.md
E:\Sorglos-app\Webseiten-Akquise\
  BRANCHEN_BAUKASTEN.md · WEBSEITEN_BAUKASTEN.md · GESPRAECHSLEITFADEN_ERSTE_3.md ·
  geraete-ansicht.html · SAFE_LISTE.md · LEADS_*.csv/.md
```

⚠️ **Widerspruch zur Auftragsbeschreibung, offen benannt:** Die Bus-Nachricht sprach von
„miniBar ist LIVE auf minibar.sorglos-app.de". Das ist **von hier aus nicht belegbar** —
in den E:\-Unterlagen steht nur der lokale Vorschau-Build plus die Regel, die Vorschau
mit niemandem außer dem Inhaber zu teilen. Falls die Seite wirklich öffentlich erreichbar
ist, gehört das gegengeprüft (und wenn ja: `noindex` und Freigabe-Lage klären, weil der
Inhaber nichts freigegeben hat).
