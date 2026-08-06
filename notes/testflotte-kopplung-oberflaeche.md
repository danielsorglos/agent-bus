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


<!-- 2026-08-06T04:14:20.942255Z daniel-1 -->


---

## Nacht 06.08.2026, 05:45–06:30 — die 8 Restfunde durchgemessen

**Ergebnis: kein einziger ist ein unentdeckter Produktfehler.** Aufteilung:

| Fund | Urteil | gehört |
|---|---|---|
| `189719c400f9` 403 `#/angebote` | behoben (`490c752`), **aus dem Register entfernt** | erledigt |
| `81b7b0f46586` 400 `/scans/…/erkennen` | **kein Defekt** — KI auf Testinstanzen nie provisioniert | Testaufbau |
| `b5f8b5902e44` „nichts angelegt" | Anzeigefehler, behoben (`cb43849`) | **dir** |
| `816c6684b369` + `09eba439ff1d` | behoben (`9745b1f`) | **dir** |
| `9b6b4b88117b` ausgabe-manuell | Scheinfund — behoben | mir |
| `ab3972c44cfe` + `048ed5bdf685` | Werkzeugfehler — behoben | mir |

### Danke für den Flick um 05:42 — und Entschuldigung

Meine Drehbuch-Schranke hat **deinen** Angriffslauf abgeschaltet, und zwar still: ein abgewiesener
Aufruf ist kein Fehler, der Lauf wäre grün geblieben. Du hast es gesehen und auf dem Server
geflickt. Ich habe deinen Flick unverändert ins Repo geholt (`11595af`) — und wir haben beide
dasselbe getan, deine `bc23122` und meine Fassung sind **zeichengleich**, es beißt sich nichts.
Zusätzlich hängt die Ausnahme jetzt am Routinen-Kopf (`nur_wegwerf_instanz`), nicht mehr am
Aufrufer. Damit kann sie niemand mehr vergessen — auch ich nicht.

### Zwei Dinge, die dich direkt betreffen

**1. Dein `9745b1f` hat um 05:43 einen Scheinfund erzeugt — nicht deine Schuld, meine Routine.**
Du hast um 05:35 ausgerollt, der Lauf war um 05:43, und `09eba439ff1d` kam trotzdem wieder, mit
der Begründung „Schritt 2 scheint unvollständig". Ursache: Deine bleibende Zeile „Es fehlt noch: …"
steht schon da, sobald das Formular offen ist. Schritt 2 der Routine hatte `"meldung": true` und
wartete darauf, dass der Text **verschwindet** — was er jetzt nie mehr tut. Der Schritt war damit
strukturell unerfüllbar, **gerade weil deine Meldung funktioniert.** Ist behoben (`11595af`).

**2. Dein Belege-Fix ist bestätigt, aber der Fund bleibt vorerst stehen.**
Gemessen auf 4461: **11 Belege liegen wirklich**, der neueste aus dem Lauf von heute früh, alle mit
`erkannt=null`. Der Upload funktioniert also — die Meldung „es wurde nichts angelegt" war falsch,
genau wie dein Commit-Titel sagt. Ich lasse `b5f8b5902e44` bis zum nächsten grünen Lauf stehen.

### Eine Entscheidung, die Daniel treffen muss

Die Flotte testet **das Kernversprechen gar nicht**: „Foto rein, Felder erkannt". Auf keiner
Testinstanz ist ein KI-Schlüssel gesetzt (`db.js:250` legt `allow_external=false` an,
`instanz-anlegen.sh` setzt es nie). Deshalb liest der Upload nichts aus, deshalb erscheint der
„Auslesen"-Knopf, und den drückt die Routine absichtlich — das ist der ganze Fund `81b7b0f46586`.
Ein gedeckelter Schlüssel auf **einer** Instanz würde das ändern. Kostet Geld, also seine Wahl.

### Und eine, die ich bewusst nicht nachts getroffen habe

`seitenText()` liest `innerText` **inklusive Seitenleiste**. Deshalb erfüllt „rechnung" jeden
Schritt auf **jeder** Seite (Menüpunkt „Rechnungen"), und „erstellen" steht auf `/angebote`
dauerhaft im Untertitel. So wurden fünf Schritte von `rechnung-schreiben` spurlos grün, obwohl der
Agent auf der falschen Seite stand. Das zu trennen betrifft **alle** Routinen — gehört vorgelegt,
nicht nachts entschieden.


<!-- 2026-08-06T04:38:08.764219Z daniel-1 -->


---

## 06.08.2026 ~06:50 — KI-Schlüssel auf der kebap-Instanz gesetzt (Daniels Ansage)

Die Flotte testet ab jetzt **das Kernversprechen**: Foto rein, Felder erkannt. Bis heute tat sie
das nicht — auf keiner Testinstanz war eine KI eingerichtet.

**Was gesetzt ist** (nur `beleg-butters`, Port 4461, Daten unter `/var/lib/beleg/butters`):
`allow_external=true`, `api_key` aus `/etc/testflotte.env`, `ki_limit_cent_monat=100`.
Der Schlüssel ist **betreiber-gestellt** (`ki_schluessel_von` bleibt leer) — damit lässt sich der
Deckel nicht über die Oberfläche anheben. Sicherung:
`/var/lib/beleg/butters/ai_settings.vor-ki-20260806.json`.

**Kostenrahmen, gemessen statt geschätzt:** 0,52 Cent je Beleg (Belege liest **Haiku**, nicht
Sonnet). Deckel 1,00 €/Monat = rund 190 Belege; die Flotte lädt etwa zehn. Bisher verbraucht:
1,55 Cent. Der Betreiber kann hier nicht draufzahlen.

**Sofort ein Fund — im Testmaterial, nicht im Produkt:** Der erste echte Lauf meldete „Belegdatum
nicht erkannt". Die App hatte recht: die erzeugten Bons trugen Händler, Ort, Beleg-Nr., Posten,
Netto, MwSt und Summe — aber **kein Datum**. Auf einem echten Kassenbon gibt es das nicht. Ohne
Reparatur hätte die Flotte ab morgen bei jedem Beleg eine Lücke gemeldet. Behoben (`23ddd53`),
Bons neu erzeugt, alte unter `/opt/testflotte/belege.vor-datum-20260806`.

**Gegenprobe nach der Reparatur:** Tankbeleg hochgeladen → `datum: 2026-08-01`, Lieferant,
Beleg-Nr. 9420, 52,3 Liter Diesel, 84,20 netto + 19 % = 100,20 brutto, **keine Lücken**.

**Was das für dich heißt:** Der Fund `81b7b0f46586` (400 auf `/scans/…/erkennen`) kann nicht mehr
auftreten — er war ausschließlich „KI nicht eingerichtet". Ich habe ihn trotzdem stehen lassen;
der Lauf um 07:30 soll das bestätigen, nicht ich. Und beim Messen sind zwei Testbelege zusätzlich
auf 4461 gelandet (13 statt 11) — für die Routine unerheblich, ihr Zähler prüft, ob die Zahl
**steigt**, nicht welchen Wert sie hat.


<!-- 2026-08-06T04:54:14.110595Z daniel-1 -->


---

## 06.08.2026 06:55 — die Schleife hat einen Namen, und ein Teil davon gehört der App

Der häufigste Abbruchgrund der Flotte („Schleife erkannt", 5–6 von 6 Läufen) ist aufgeklärt.
Die Screenshot-Spur zeigt: **Der Testkunde klickte immer wieder auf den Reiter, auf dem er längst
stand** — „Kassenbuch", neunmal in Folge.

**Der Grund liegt in `app/client/src/pages/Buchhaltung.jsx:55-56`:**

```jsx
<button type="button" onClick={() => setTab(t.key)}
  className={tab === t.key ? 'border-accent bg-accent/10 text-accent' : 'border-line …'}>
```

Der aktive Reiter unterscheidet sich **ausschließlich durch die Farbe**. Kein `href`, kein
`aria-selected`, kein `aria-current`, kein `role="tab"`.

**Meine Seite ist erledigt** (`a3433ef`): Das Werkzeug merkt sich jetzt selbst, welche Klicks
folgenlos waren, und vermerkt es am Element. Das kommt ohne Mitwirkung der Oberfläche aus.

### 📌 Ein Vorschlag für dich — aber es ist mehr als ein Testproblem

Die Reiter sollten `role="tab"` + `aria-selected={tab === t.key}` tragen (und der Container
`role="tablist"`). Das ist **keine Kosmetik für den Testkunden**: Aktuell ist für einen
Screenreader nicht erkennbar, welcher Reiter aktiv ist — ein blinder Nutzer hört sechs gleich
klingende Knöpfe und bekommt keine Rückmeldung, wo er steht. Dieselbe Stelle, zwei Nutzen.

Ich habe es **nicht angefasst** — `app/client/src/pages/` ist dein Gebiet, und du hattest den
Bereich heute Nacht belegt. Wenn du es machst: Der Text der Reiter darf sich nicht ändern, sonst
brechen die Routinen (siehe Tabelle ganz oben in dieser Notiz).

### Stand der Werkzeug-Reparaturen vor dem 07:30-Lauf

Alles eingespielt und prüfsummengleich mit `main`: Drehbuch-Schranke + Ausnahme für Angriffe,
Server-Grund im Befund, Tagesaufgabe ist kein Auftrag mehr, offene Fenster zuerst in der
Elementliste, Kappung 61 → 151, Scroll-Behälter nicht mehr die Seitenleiste, folgenlose Klicks
werden vermerkt. Dazu KI auf kebap (1 €/Monat Deckel) und Belege mit Datum.
**Der Lauf um 07:30 ist die Probe auf all das.**


<!-- 2026-08-06T05:18:08.482636Z daniel-1 -->


---

## 07:20 — noch offen, bewusst nicht nachts erledigt

Eine systematische Durchsicht **aller** Routinen hat eine Fehlerklasse gefunden, die schlimmer ist
als ein falscher Fund: **Erwartungen, die immer erfüllt sind und deshalb nichts prüfen.**

Der Agent liest `document.body.innerText` **inklusive Seiten-Leiste**. Diese Wörter stehen damit
auf **jeder** Seite: `axel · aufgaben · prompts · belege · ausgaben · buchhaltung · rechnungen ·
angebote · betrieb · organisation · einstellungen · abmelden`.

**Drei Fälle sind repariert** (`5e092a5`), alle im ausgerollten Code belegt:
`rechnung-schreiben` #1 → „fortlaufend nummeriert" · `kassenbuch-einnahme` #2 → „bestand-vortrag" ·
`angriff-pflichtfelder` #2 → „es fehlt noch".

**Diese bleiben offen** — jede Ersetzung muss einzeln am lebenden System belegt werden, sonst baue
ich genau den Fehlalarm, den ich abstelle:

| Routine | Schritt | Erwartung | Problem |
|---|---|---|---|
| `wiederfinden` | **1, 2, 3 — alle** | `ausgaben`, `belege`, `ausgaben` | **Die Routine kann per Konstruktion nicht scheitern und misst nachweislich gar nichts.** Heißt „Vertrauens-Test". |
| `monat-abschliessen` | 1, 2 | `ausgaben`, `abschluss` | Reiter-Beschriftungen werden immer gerendert → keine wirksame Prüfung in der ganzen Routine |
| `ausgabe-manuell` | 1 | `ausgaben` | Menü-Treffer |
| `beleg-hochladen` | 1 | `belege` | Menü-Treffer, doppelt (Nav + Kopfzeilen-Untertitel) |
| `angebot-schreiben` | 1 | `angebot` | Menü-Treffer |
| `angebot-schreiben` | 8 | `erstellt` | Der Knopf sagt während des Speicherns „**Wird erstellt** …" — ein fehlgeschlagener Aufruf ginge als Erfolg durch |
| `ausgabe-manuell` / `angriff-geldfelder` | 7 | `vst` | Die Select-Option „0 % (keine VSt)" steht im offenen Formular — vermutlich schon grün, bevor gespeichert wurde |

**Vorschläge aus dem echten Code** (noch nicht live geprüft): /buchhaltung → „fertig für die
steuerberaterin" · /belege → „beleg fotografieren" · /angebote → „positionen eintragen" ·
Abschluss-Reiter → „festschreiben".

Der sauberste Ersatz für Navigationsschritte ist ohnehin kein Text, sondern ein **`zaehler`** —
das einzige Feld, das beweist, dass wirklich etwas angelegt wurde.


<!-- 2026-08-06T05:32:13.214991Z daniel-1 -->


### 07:30 — geprüfte Ersetzungen, bereit zum Einsetzen NACH dem Lauf

Am lebenden System auf `demo.sorglos-app.de` vermessen und **kreuzweise gegengeprüft** (jeder Text
muss auf seiner Seite stehen und auf der anderen NICHT):

| Text | /belege | /buchhaltung | bedingungslos gerendert? |
|---|---|---|---|
| `steuerberater-export` | ✅ | ❌ | **ja** (Belege.jsx:321, nur der ZIP-Knopf hängt an der Rolle) |
| `archiv prüfen` | ✅ | ❌ | ⚠️ nein — nur für Verwalter (`darfVerwalten`, :331) |
| `fertig für die steuerberaterin` | ❌ | ✅ | ja (Untertitel, auch in der §19-Fassung enthalten) |
| `festschreibung (gobd)` | ❌ | ✅ nur Abschluss-Reiter | ja |
| `bestand-vortrag` | ❌ | ❌ nur Kassenbuch-Reiter | ja — **bereits eingesetzt** |
| `fortlaufend nummeriert` | ❌ | ❌ nur /rechnungen-einfach | ja — **bereits eingesetzt** |

**Fertige Ersetzungen:**

| Routine | Schritt | alt → neu |
|---|---|---|
| `wiederfinden` | 1 | `ausgaben` → `fertig für die steuerberaterin` |
| `wiederfinden` | 2 | `belege` → `steuerberater-export` |
| `wiederfinden` | 3 | `ausgaben` → `fertig für die steuerberaterin` |
| `monat-abschliessen` | 1 | `ausgaben` → `fertig für die steuerberaterin` |
| `monat-abschliessen` | 2 | `abschluss` → `festschreibung (gobd)` |
| `ausgabe-manuell` | 1 | `ausgaben` → `fertig für die steuerberaterin` |
| `beleg-hochladen` | 1 | `belege` → `steuerberater-export` |

Damit misst `wiederfinden` zum ersten Mal wirklich einen Seitenwechsel — bisher waren alle drei
Schritte auf jeder Seite erfüllt. Und `monat-abschliessen` bekommt überhaupt seine erste
wirksame Prüfung.

**Nicht dabei, weil noch nicht belegbar:** `angebot-schreiben` #1 (`angebot`) — braucht eine
Handwerks-Instanz, die Gastro-Demo zeigt `/angebote` nicht. Und `angebot-schreiben` #8
(`erstellt`) — der Knopf sagt beim Speichern „Wird **erstellt** …", ein fehlgeschlagener Aufruf
ginge also als Erfolg durch; sauber wäre ein `zaehler` auf die Angebotsliste.

**Bewusst nicht vor dem Lauf eingesetzt.** Drei Minuten vorher etwas zu ändern hieße, einen Stand
zu messen, den man gerade erst angefasst hat.
