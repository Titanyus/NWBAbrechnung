# Anlagen, Trassen und strukturierte Anschriften

Stand: 14.11.2026. Ausgangsstand: 33ba4b8. Verbindlicher Auftrag:
`docs/PLANT_ROUTES_BRIEF.md` plus anschließende Präzisierungen im Chat.

## Gelieferte Oberfläche

Die Anlagenübersicht behält Tabelle, Live-Suche, Sortierung und Anlagenwahl.
Markierung, Radiobuttons und der vorgelagerte Bearbeitungsbutton entfallen.
„Bearbeiten“ steht direkt pro Zeile; der Anlagenname öffnet denselben Arbeitsplatz.
„Anlage auswählen“ bleibt eine getrennte Aktion und öffnet die Vertragsverwaltung;
die globale Anlagenwahl bleibt ebenfalls unverändert.

Anlegen und Bearbeiten verwenden dasselbe Layout und dieselben Komponenten:
kompakter Kopf mit Speichern/Abbrechen, Stammdaten links, Kennzahlen rechts und
die Trassentabelle darunter. Neue Anlagen zuerst speichern, dann direkt dort
Trassen ergänzen. Trassen werden in einem kleinen Turbo-Editor erstellt und
bearbeitet. Eigene Trassen-Transaktionen aktualisieren Tabelle und Kennzahlen,
überschreiben aber keine ungespeicherten Anlagenstammdaten. Fehler erscheinen im
Editor und erhalten die Eingaben. Es gibt keine Löschaktion.

Die zuletzt ausdrücklich abgewählte Trassensuche und ihr Einführungstext sind
entfernt. Keine Seitennavigation bei üblichen kleinen Listen. Nur oberhalb von
100 Trassen wird eine begrenzte nächste Seite angeboten; kein stilles Abschneiden.
Die übrigen bestehenden Suchen verwenden weiterhin die gemeinsame Live-Suche.

## Adressen: eine Quelle, drei Pflichtfelder

Bei Anlagen, Kunden und Hausanschlüssen werden Straße/Hausnummer, PLZ und Ort
getrennt erfasst. Dasselbe Partial `shared/_address_fields.html.erb` gilt sowohl
für die normalen Formulare als auch für die Inlinebearbeitung in der Vertragsakte.
Die bisherigen doppelten Kunden-/Anschlussformularfelder sind zusammengeführt.

`StructuredAddress` normalisiert Rand-Leerzeichen und prüft vollständige,
einzeilige Komponenten. PLZ wird als Text gespeichert und behält führende Nullen;
keine nicht beauftragte Länder-/Fünfziffernregel. Datenbankprüfungen sichern die
Pflichtfelder zusätzlich. Die Anzeige `address` setzt die drei Komponenten zusammen;
es gibt keine zusätzliche gespeicherte Freitextadresse. Suche und Adresssortierung
arbeiten auf den neuen Spalten. Kein automatischer Adressparser.

**Migration 20261114000100:** Der Betreiber hat ausdrücklich bestätigt, dass nur
entbehrliche Demodaten existieren und keine bisherigen Adressen erhalten werden
müssen. Die Migration benennt `address` in `street` um, ergänzt `postal_code` und
`city` und ersetzt bestehende Anschriften durch „Demostraße 1 / 00000 Demoort“.
Diese Ersetzung erfolgt einmalig beim Update. UUIDs, Betreiberzuordnungen,
Verträge, Zähler, Ablesungen und andere Beziehungen werden dabei nicht geändert.
Die Demo-Seeds und die explizit freigegebene UI-Fixture erzeugen getrennte Felder.
Ein Rollback setzt die dann aktuellen Komponenten wieder als Freitext zusammen;
die verworfenen ursprünglichen Demoadressen werden dadurch nicht wiederhergestellt.

Anlagenstatus und Leistung wurden nicht neu erfunden. Dafür fehlen weiterhin
modellierte Felder. Bestehende Anschriften bestehen jetzt ausschließlich aus den
drei ausdrücklich beauftragten Feldern. Keine Änderung an Abrechnung oder Joomla.

## Zählweise und Rechte

„Verträge gesamt“ zählt ausdrücklich alle Statuswerte: aktiv, Entwurf, beendet und
storniert. Anlagenwerte stammen aus den jeweiligen Beziehungen. Trassenwerte zählen
Hausanschlüsse und deren sämtliche Verträge anhand der aktuellen Trassenzuordnung
am Anschluss. Historische Verträge werden nicht umgeschrieben. Keine Haushaltszahl,
keine manuelle Kennzahleingabe, keine Multiplikation durch Join-Vervielfachung.

Serverseitiger Anlagenscope bleibt für alle Zugriffe verbindlich. Stammdaten einer
Anlage ändern nur zugeordnete Administratoren. Zugeordnete Verwaltungsbenutzer
behalten ihre vorhandenen Trassenrechte, bekommen aber keine Anlagen-Schreibrechte.
Fremde Trassen-IDs bleiben ausgeschlossen. Bestehende Restrict-/FK-Regeln und das
Fehlen einer DELETE-Route schützen belegte Trassen. Audit bleibt wirksam.

## Gestaltung und visuelle Prüfung

Das Referenzbild wurde hinsichtlich Gruppierung, Feldbreiten, Platznutzung und
Trassentabelle umgesetzt. Header, Seitenleiste, Buttons, Rahmen und Felder verwenden
die vorhandenen Theme-Tokens; kein neuer Hex-Farbwert und keine neue Bibliothek.
Kein Platzhalter für fehlenden Status/Leistung und keine Übernahme der blauen Palette.

Neue Screenshots bei 1280 × 800, 1440 × 900, 1920 × 1080 und 2560 × 1440 liegen
unter `screenshots/after` (Neuanlage, Bearbeitung, Anlagenliste, Vertragsansicht).
Bei 1440 × 900 sind Stammdaten, Kennzahlen und eine Trasse gemeinsam sichtbar;
keine horizontale Seitenausdehnung in den vier Größen. Die Aufnahme zeigt bewusst
synthetische Prüfdaten mit einem Hausanschluss und vier Vertragsstatuswerten.

`screenshots/before` übernimmt die vorhandenen Anlagenübersicht-Aufnahmen des
vorherigen Prüflaufs. Das sind historische Vergleichsbilder, keine nachträglich
hergestellten Vorher-Aufnahmen der neuen Maske. Die Demodaten wurden inzwischen
explizit geändert und im Browser um neue Testanlagen ergänzt; kein identischer
Datenbestand für einen numerischen Vorher-/Nachher-Vergleich behauptet.

## Tatsächlich ausgeführte Prüfungen

- Rails: **84 Tests, 576 Assertions**, keine Fehler oder Fehlschläge.
- Neue Modell-/DB-Prüfungen für alle drei Adressobjekte, fehlende/mehrzeilige
  Komponenten, Normalisierung, führende PLZ-Nullen und Datenbankumgehungsversuche.
- Integration: gemeinsame Maske, direkte Bearbeitung, leere Neuanlage, vier
  Vertragsstatus, korrekte Hausanschlusszahl, Trassenanlage/-änderung, Audit,
  Fehlerwerte, fremde IDs, Rechteentzug und Löschschutz. Große Trassenliste begrenzt.
- Browser `plant_routes_smoke.py`: neue Anlage, Route mit Servervalidierungsfehler,
  Route anlegen/bearbeiten, ungespeicherte Anlagenwerte erhalten, Kunde und Haus mit
  getrennten Adressen, vier Vertragsstatus anlegen, Zählergebnisse, direkte Bearbeitung,
  Anlagenwahl pro Zeile und im Header; keine JavaScript-Fehler.
- Browser `plant_live_search_smoke.py`: bestehende Live-Suchen, Tippbündelung, Fokus,
  verzögerte Antwort, Reset, Ablauf der Sitzung und acht Theme-/Modus-Kombinationen.
- Bestehender Vertrags-Browsertest: Nachladung, Filter/Scrollstand, Aktenbearbeitung,
  Ablesefehler und exakte Ablesewerte weiterhin erfolgreich.
- `master_data_smoke.py`: Kunden-/Anschluss-/Vertragsanlage, Änderungen, Ablesekorrektur,
  atomarer Zählerwechsel sowie vier Desktopbreiten über die Fachseiten erfolgreich.
- RuboCop ohne Beanstandungen, Brakeman ohne Warnungen, Zeitwerk erfolgreich,
  aktueller Bundler-Audit ohne bekannte Schwachstellen.
- Docker-Build und Upgrade mit `compose.build.yaml` erfolgreich. Gebautes Image ohne
  Quellmount gestartet. Die Adressmigration lief auf dem bisherigen Testbestand.
  Vor/nach Update unverändert: 3 Anlagen, 3 Kunden, 3 Anschlüsse, 3 Trassen,
  3 Verträge und 15 Ablesungen. Neue Adressspalten sind befüllt; alte Adressspalte
  nicht mehr vorhanden. Keine vollständige Accessibility-Abnahme behauptet.

JSON-Browserprotokolle: `workspace-checks.json` und `browser-checks.json`.

## Geänderte Bereiche und Auslieferung

Controller/Concern für Anlagen und Trassen, gemeinsame Views/Komponenten,
Adress-Concern in drei Modellen, Migration/Schema, serverseitige Suchen, Seeds,
synthetische Fixtures, Browser-/Integrationstests und UI-Regeln. Die veraltete
Zeilenmarkierungssteuerung wurde entfernt. Keine neuen Produktabhängigkeiten.

Dockhand: bestehenden Git-Stack auf `main` aktualisieren und mit `compose.build.yaml`
neu bauen/ausspielen. `db:prepare` führt die Adressmigration aus. Datenpfade und
Umgebungsvariablen bleiben bestehen. **Bisherige Demoadressen werden ersetzt.**
