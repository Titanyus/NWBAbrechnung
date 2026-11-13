# Vertragsverwaltung – Pilot und Prüfbericht

Stand: 14.11.2026 (Europe/Berlin). Vergleichsbasis: c2b7f50.

## Gelieferter Arbeitsablauf

Anlage auswählen, Vertrag serverseitig suchen/filtern und in der linken Liste
wählen. Rechts stehen Kunde, Hausanschluss, Vertrag und aktueller Zähler gemeinsam.
Kontaktdaten, Anschlussdaten, Vertragsdaten und Ablesungen lassen sich im Kontext
bearbeiten. Fehler bleiben am Formular, erfolgreiche Änderungen aktualisieren die
Akte. Historie und komplexe Zählerabläufe sind tatsächliche Detailansichten.

Die Liste hat eine eigene Scrollregion. Initial und je Nachladeanforderung werden
höchstens 30 Verträge ausgeliefert; serverseitig wird ein zusätzliches Element nur
zur Erkennung der nächsten Seite geprüft. Suche und Filter gelten für sämtliche
Verträge der berechtigten Anlage. Signierte zwölf Stunden gültige Cursor sind an
Benutzer, Anlage und Filter gebunden; Berechtigungen werden weiterhin bei jeder
Anfrage geprüft. Auswahl ersetzt nur den rechten Turbo-Frame. Filter, Listen-DOM
und Scrollposition bleiben bestehen. Keine nummerierte Seitennavigation.

## Abgleich mit der Bildreferenz

Übernommen: kompakte Navigation links, Anlagenwahl oben, horizontale Filter,
scrollbare Zweizeilenliste, daneben die Akte mit lokalen Bearbeitungsaktionen.
Bei Full HD stehen drei Informationsgruppen nebeneinander, darunter die Zählerdaten;
bei 1440 px verteilen sich die Gruppen auf zwei Spalten. Die Übersicht enthält
alle wesentlichen Gruppen, ohne Tabwechsel. Standardfarben bleiben das vorhandene
NWB-Grün/Gold; blaue Kopf-/Navigationsflächen orientieren sich an der Referenz.
Bestehende Farbvorlagen und Hell/Dunkel bleiben verfügbar.

Bewusste Abweichungen: nur vorhandene Funktionen; keine erfundenen Abrechnungs-,
Dokument- oder Auswertungsseiten, keine leeren Tabs. Kundensuche ist sekundär unter
„Weitere Stammdaten“. Anlagenwahl wird nicht als zweiter Filter dupliziert.

## Messwerte mit identischen synthetischen Daten

153 Verträge, davon 150 mit dem reproduzierbaren Fixture-Skript. Vorher-Aufnahmen
stammen vom unveränderten veröffentlichten Stand, Nachher-Aufnahmen vom Pilot.
Formular-Browsertests ändern erst nach diesen Aufnahmen ausschließlich Testdaten.

| Größe | vorher sichtbare Einträge | nachher sichtbare Einträge | nachher Zeilenhöhe |
|---|---:|---:|---:|
| 1280 × 800 | 3 | 10 | 52,39 px |
| 1440 × 900 | 6 | 12 | 52,39 px |
| 1920 × 1080 | 6 | 15 | 52,39 px |
| 2560 × 1440 | 12 | 22 | 52,39 px |

Vorher: Kartenraster mit ca. 211,58 px Höhe je Karte und 100 geladenen Verträgen.
Nachher: 30 geladene Listeneinträge, erste Zeile bei 255 px ab Viewportanfang bzw.
199 px unter dem 56-px-Kopf. Keine horizontale Seitenausdehnung in den vier Größen.
Liste und Akte scrollen getrennt. Bei 1280 × 800 benötigt die Akte eigenes Scrollen.
Screenshots liegen in `screenshots/before` und `screenshots/after`; Rohmessungen in
`before-metrics.json` und `after-metrics.json`.

## Ausgeführte Prüfungen

- Rails: 68 Tests, 439 Assertions, keine Fehler oder Fehlschläge. Einschließlich
  negativer Anlagen-/Benutzerzugriffe, Kontextmanipulation, geteilter Kundenrechte,
  Cursor-Manipulation, sicherer Rückwege und exakter Ablesewerte.
- Browser: alle 150 Suchergebnisse in 30er-Schritten ohne Duplikate nachgeladen;
  Filter, URL, Listen-DOM und Scrollposition bei Auswahl und Bearbeitung erhalten.
  Serverseitige Suche findet auch zunächst ungeladene Verträge.
- Kundenbearbeitung, doppelte/zulässige Ablesung, Fehlereingaben, aktualisierter
  Zählerstand, Historie, Zählerdetails und Rückkehr im rechten Bereich geprüft.
- Tastatur: Pfeiltasten/Enter; schnelle Auswahl mit verzögerter früherer Antwort.
  Vier Desktopgrößen plus 960 × 540 CSS-Pixel als Layoutprüfung entsprechend
  200 % Zoom auf Full HD; lange synthetische Firmennamen und acht Farb-/Modus-
  Kombinationen ohne horizontalen Seitenüberlauf. Kein vollständiges Accessibility-Audit.
- RuboCop ohne Beanstandung, Zeitwerk erfolgreich, Brakeman ohne Warnung,
  Bundler-Audit ohne bekannte Schwachstellen (aktueller Advisory-Abgleich).
- `compose.build.yaml` lokal gebaut und bestehenden Teststack ohne Quellmount
  neu gestartet. Beide Dienste gesund, `/up` HTTP 200. Bestandszahlen vor/nach
  Neustart unverändert: 3 Anlagen, 3 Kunden, 3 Verträge, 15 Ablesungen.

Browsernachweise: `browser-checks.json`, `visual-checks.json` und zusätzlicher
Screenshot `screenshots/customer-editor-1440x900.png`. Prüfungsskripte unter
`scripts/contract_browser_smoke.py`, `scripts/contract_visual_checks.py` und
`scripts/capture_contract_ui.py`. Fixture: `NWB_SYNTHETIC_UI=1 bin/rails runner
scripts/ui_fixture.rb` ausschließlich im synthetischen Entwicklungs-/Testbestand.

## Grenzen und weiterer Ausbau

Nur die Vertragsverwaltung wurde umgestellt. Andere Fachseiten, bisherige
Vertragserstellung, Anlagenbearbeitung und Trassenverwaltung bleiben erhalten.
Die zuvor entworfene gemeinsame Neuerstellung und der breite UI-Rollout sind
zurückgestellt. Datenbankschema, Fachmodelle, Geschäftsregeln und Abhängigkeiten
wurden nicht verändert.

Seitennachladung verwendet begrenzte Offset-Abfragen mit stabiler Sortierung.
Bei gleichzeitigen Änderungen kann eine laufende Ergebnisfolge Lücken enthalten;
Duplikate werden im Browser entfernt. Neue Suche/Filterung berechnet die Folge neu.
Es werden keine tausenden Datensätze ungefiltert vorab geladen. Bereits bewusst
nachgeladene Einträge bleiben für Scrollstabilität im DOM; keine Virtualisierung.
Ein bearbeiteter ausgewählter Eintrag aktualisiert seine Beschriftung, die Liste
wird dabei nicht automatisch umsortiert. Für neue Sortierung Suche erneut anwenden.

Auslieferung: GitHub-Stand im bestehenden Dockhand-Git-Stack aktualisieren und mit
`compose.build.yaml` neu bauen/ausspielen. Bestehende Umgebungsvariablen und
Datenpfade beibehalten; kein Volume löschen. Kein GHCR-Pull erforderlich.
