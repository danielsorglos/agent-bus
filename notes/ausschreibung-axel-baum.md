# AUSSCHREIBUNG — Baum-Kulisse fuer Axel (Grafik/Webdesign)

Auftraggeber: Daniel, 06.08.2026. Diese Notiz ist der vollstaendige Auftrag —
wer sie liest, kann ohne Rueckfragen anfangen. Technische Vorarbeit und
Pruefwerkzeug: daniel-1.

## Was gebraucht wird

Eine BAUM-KULISSE, in der Axels vorhandener Ast steckt. Axel selbst und der
Ast werden NICHT veraendert — sie sind eingefroren (AXEL_SPRITE_APPROVED_V2,
von Daniel am 28.07. freigegeben). Gezeichnet wird nur die Umgebung.

Zweck: der groessere Auftritt der Marke (Webseiten-Held, Social, Startbild).
Fuer kleine Stellen (App-Oberflaeche, Chips) bleibt es beim Ast allein.

## Warum das KEIN zweites Maskottchen ist

Ast und Baum sind dieselbe Szene in zwei Zoomstufen. Klein: Axel haengt am
Ast. Gross: derselbe Axel am selben Ast — nur ist jetzt der Baum mit im Bild.
Es wird nichts hinzuerfunden, es wird herausgezoomt. (Das unterscheidet den
Auftrag vom fruehen CRT-Flugschiff, das eine andere Figur war.)

## HARTE VORGABEN — nicht verhandelbar

1. ECHTES RASTER. 1 Bildpunkt = 1 Rasterpunkt. Keine Kantenglaettung, keine
   Verlaeufe, keine halbtransparenten Kanten, keine Drehung.
   HINTERGRUND: Die erste Axel-Vorlage sah aus wie Pixelart, war aber keine —
   gemessen war der haeufigste Abstand zwischen Farbwechseln 3 Punkte, mit
   Ausreissern bei 4, 5, 7, 9, 11. Aus so einer gemalten Illustration laesst
   sich kein sauberes Sprite herausrechnen. Genau das darf nicht wieder
   passieren.

2. KEINE BILD-KI. Aus demselben Grund: KI-Bilder sehen aus wie Pixelart,
   haben aber kein sauberes Raster und treffen die Palette nicht.
   Werkzeuge der Wahl: Aseprite, Piskel, GraphicsGale, Photoshop mit
   abgeschalteter Interpolation.

3. NUR DIESE PALETTE (aus dem Datenpaket, 14 sichtbare Farben):
     Rinde/Holz dunkel   K  #2B211A     (Kontur)
                mittel   k  #4A3628
                warm     H  #8A5A2B
     Fell/Struktur       F  #7A6654  ·  f  #A9957F
     Hell/Bauch          C  #E9DFC9  ·  c  #CFC3AA  ·  W  #F6F2E8
     Erdig/Akzent        B  #9B5A18  ·  b  #D79A4A
     Kuehl/Auge          G  #6F93AE  ·  g  #A9C3D6  ·  N  #17243A
     BLATTGRUEN          L  #5E7B3C
   Fuer Rinde also K/k/H (+ F/f fuer Struktur), fuer Blattwerk L.
   Neue Farben NUR nach Ruecksprache mit Daniel — die Palette ist Teil der
   Markenidentitaet und gilt fuer alle Kulissen.

4. ANDOCKMASSE (aus dem Datenpaket gemessen, Sprite ist 64 x 56):
   - Der waagerechte Ast belegt ZEILEN 4 bis 10, ueber x 2 bis 61.
     Zeile 4: x 3-60 (Oberkante, Kontur K)
     Zeile 5-8: x 2-61 (Holzkoerper)
     Zeile 9-10: Unterkante
   - An BEIDEN Enden haengen Blattbueschel nach unten, Zeilen 10 bis 16,
     links etwa x 3-9, rechts etwa x 54-62.
   - Ein STAMM dockt seitlich an, auf Hoehe der Zeilen 4-10: links bei x 2
     oder rechts bei x 61. Der Ast ist bewusst als AUSSCHNITT gezeichnet und
     hat dort dunkle Endkappen (K) — die duerfen vom Stamm ueberdeckt werden.
   - Axels Koerper reicht bis Zeile 55 (Fuesse). Unter ihm ist Platz frei.

5. KEINE ANIMATION. Der Baum steht, Axel bewegt sich. Es wird genau EIN Satz
   Pixel gebraucht, keine Bildfolgen.

6. AXEL BLEIBT LESBAR. Der Baum ist Kulisse, nicht Hauptdarsteller. Hinter
   Axels Kopf und Gesicht darf keine unruhige Struktur liegen; dort gehoert
   eine ruhige Flaeche oder Freiraum hin.

## Lieferformat

PNG mit transparentem Hintergrund, 1 Bildpunkt = 1 Rasterpunkt, nur
Palettenfarben. Zielgroesse frei waehlbar, aber das Ast-Raster muss passen
(Axel ist 64 breit; ein Baum von 128-192 Punkten Breite ist ein guter Rahmen).
Dazu bitte angeben, an welcher Stelle im Bild Axels 64x56-Sprite sitzt.

## SELBST PRUEFEN VOR DER ABGABE

    node ops/axel-kulisse-pruefen.mjs <deinbild.png>

Meldet jede halbtransparente Kante, jede Farbe ausserhalb der Palette und
jede Vorskalierung (mit dem Faktor zum Herunterrechnen). Rueckgabe 0 =
sauber. Mit `--matrix` gibt es zusaetzlich die Zeichenmatrix aus, in der die
Kulisse spaeter im Repo liegt.
Gegenprobe, dass das Werkzeug richtig misst: Axels eigenes Sprite
(app/client/public/maskottchen/crt/neutral.png) geht sauber durch.

## ZWEITE, KLEINERE DESIGNFRAGE IM SELBEN AUFTRAG

Mit dem Wegfall des Roehrengehaeuses verliert die STATUSANZEIGE ihren Platz.
Sie zeigt genau EIN Zeichen (! ? … X) und sass bisher in der Linse des
Geraets. Wo sitzt sie kuenftig? Drei Wege stehen zur Wahl:
  a) die vorhandene Begleiter-Drohne schwebt ueber Axel (ist gebaut, haengt
     an nichts, bleibt markenkonform) — Vorschlag daniel-1
  b) eine Sprechblase im selben Pixelraster (neu zu zeichnen)
  c) gar kein Zeichen, nur Mimik (am ruhigsten, verliert aber die klare
     Ansage "hier passiert gerade X")
Bitte mit Begruendung entscheiden oder Daniel eine Empfehlung vorlegen. Ohne
diese Entscheidung bleibt die Stelle in der App bewusst leer.

## Abnahme

1. `axel-kulisse-pruefen.mjs` meldet keine Beanstandung.
2. Axel sitzt sichtbar IM Baum, sein Ast geht in den Stamm ueber.
3. Gesicht und Umriss bleiben auf jedem Untergrund lesbar.
4. In 1:1-Groesse (nicht vergroessert) ist noch erkennbar, dass es ein Baum
   ist — sonst ist die Struktur zu fein fuers Raster.
5. Freigabe durch Daniel ueber den Heute-Reiter (vorschlag_create).

## Zusammenhang

Gesamtlage und Vorgeschichte: Notiz `axel-ast-variante`.
Uebergeordnete Aufgabe: t-51acb7eb7bce.
