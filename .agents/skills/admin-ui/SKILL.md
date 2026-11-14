---
name: admin-ui
description: Verbindlicher Desktop-UI-Standard für neue und bestehende NWB-Verwaltungsansichten, Tabellen, Formulare und UI-Reviews.
---

Aktueller Folgeauftrag hat Vorrang vor der ursprünglichen Pilotbegrenzung:
Anlagenübersicht und Stammdatenbearbeitung verwenden dieselben Desktop-Komponenten
wie die Vertragsverwaltung. Alle bestehenden Suchen reagieren live serverseitig:
Text nach 300 ms, Dropdown sofort, alte Antworten verwerfen, Fokus erhalten.
Keine einzelnen Komponenten/Styles pro Feld oder Button; gemeinsame Tabellen-,
Feld-, Fehler-, Aktions- und Layoutbausteine wiederverwenden. Farben ausschließlich
aus vorhandenen Theme-Variablen; NWB-Header und Seitenleiste verwenden das bestehende
Grün, Aktionen Gold, Flächen Weiß. Keine neuen unabhängigen Farbcodes.
Leistungsdaten sind nicht modelliert: „nicht erfasst“ statt erfundener Berechnung.

Neuester Anlagen-/Trassenauftrag: direkte Bearbeitung statt Markierung; gemeinsame
Anlagenmaske mit Kennzahlen und integrierter Trassentabelle. Trassensuche samt
Einführungstext ausdrücklich entfernen. Verträge gesamt umfasst alle Statuswerte.
Anschriften überall über `shared/address_fields` in Straße/Hausnummer, PLZ, Ort
aufteilen; Pflichtfelder und gemeinsame Modell-/DB-Prüfung. PLZ immer Text.
Keine zusätzliche Freitextadressquelle. Änderung der bisherigen Demodaten ist
vom Betreiber ausdrücklich freigegeben. Keine neuen Status-/Leistungsfelder.

Aktuell ergänzt: „Anlage löschen“ rechts oben für zugeordnete Administratoren,
nur nach ausdrücklicher Bestätigung und nur ohne Fachdaten. Audit erhalten,
keine Löschkaskade. „Anlage speichern“ führt zur Übersicht zurück.

Vertragserstellung jetzt rechts im bestehenden Arbeitsplatz: bewusst vorhandene
oder neue Kunden/Anschlüsse wählen; gemeinsame Feldpartials und strukturierte
Adressen verwenden. Suchergebnisse auf 20 plus ggf. die Auswahl begrenzen. Zähler
nur im Anschlusskontext, kein automatischer Wechsel. Atomare Speicherung inkl.
Audit, Fehlerwerte und linke Liste/Filter erhalten. Keine neue Nummerierungsregel.
Alle Feld-IDs müssen auch neben globalen Filtern eindeutig sein.
Helle Seitenfläche aus vorhandenen Theme-Tokens dunkler ableiten, weiße Kästen und
bestehende Dunkelwerte erhalten; Kontrastberechnung muss beide Flächen beachten.

## Globale Abstände (aktueller Folgeauftrag)

Alle angemeldeten Verwaltungsseiten verwenden die gemeinsame Desktop-Hülle und
`shared/page_heading`; die Anmeldung bleibt eigenständig. Außenabstände wie bei
Verträgen: oben/unten 12 px, links/rechts 16 px; Titelzeile mindestens 36 px,
danach 8 px. Meldungen folgen dem Titel, damit dieser beim Speichern nicht springt.
Innenabstände wie bei „Anlage anlegen“: Kästen 16 px, Abschnitte 16 px auseinander,
Formularraster horizontal/vertikal 12 px, Aktionsgruppen 12 px. Werte zentral in
`admin_contracts.css`, keine Modul- oder Feldvarianten. Rahmenlose Gruppen erhalten
keine zusätzlichen Innenabstände. Ablesung und Zählerwechsel nutzen dieselben
Formularpartials innerhalb und außerhalb der Vertragsakte. Tabellenzellen und
zweizeilige Auswahllisten behalten ihre jeweiligen kompakten Maße (40/52 px).

Ursprüngliche Pilot-Abgrenzung (historischer Stand): zunächst nur die Vertragsverwaltung nach
Bildreferenz als Master-Detail-Ansicht umsetzen und prüfen. Übrige Seiten nicht
parallel umgestalten. Linke Liste begrenzt nachladen, Filter serverseitig, Akte
rechts per Turbo aktualisieren und Listenscrollstand erhalten. Übersicht zeigt
alle wichtigen Gruppen gemeinsam. Kein Kunden-Hauptbereich und keine leeren Tabs.


1. Vor UI-Arbeiten AGENTS.md, docs/UI_GUIDELINES.md und den konkreten Auftrag lesen.
2. Neuester Auftrag hat Vorrang: Desktop 1280–2560 px; keine Smartphone-Navigation.
   Arbeitsablauf vor Implementierung kurz beschreiben, dann logisch gruppieren.
3. Bestand und Fachablauf prüfen. Modelle/UUIDs/Rechte erhalten; begrenzte sichere
   Controller-/Formkoordination und Anlagenbearbeitung gemäß UI_REBUILD_PLAN.md
   sind erlaubt. Keine unnötigen Migrationen oder neuen Fachregeln.
4. Strukturierte Listen als kompakte semantische Tabellen mit gemeinsamem Partial;
   Tokens, Status-Badges, Datums-/Decimal-Helfer und Seitenkopf wiederverwenden.
5. Hauptbereiche Anlagen und Verträge, globale Anlagenwahl genau einmal.
   Vertragsakte führt Kunde/Anschluss/Vertrag/Zähler zusammen; Trassen nur bei Anlagen.
   Kontextbearbeitung in der Akte; atomare Neuerstellung ist zurückgestellt.
   Hauptaktion und schmale horizontale Filtertoolbar, übrige Aktionen lokal priorisieren.
   Keine großen, fast leeren Karten, keine dekorativen Dashboards oder SPA.
6. Formulare logisch gruppieren, Desktopspalten und volle Inhaltsbreite nutzen;
   Labels, required, Eingabewerte, Fehlermeldungen und sichere Aktionen erhalten.
7. Keyboard, sichtbaren Fokus, Tabellenköpfe, Beschriftungen, Kontraste und lange
   Inhalte prüfen. Keine wichtigen Daten abschneiden oder nur durch Farbe erklären.
8. Vorher-/Nachher-Screenshots mit gleichen synthetischen Daten bei 1280 × 800,
   1440 × 900, 1920 × 1080 und 2560 × 1440. Zeilen-/Scrollhöhe, Breite und
   Filteranordnung messen; Abläufe A–D, Keyboard, Zoom und Berechtigungen prüfen.
9. Bestehende Funktions-/Berechtigungstests ausführen. UI-Selektoren nur an neue
   Semantik anpassen; keine fachlichen Assertions entfernen oder abschwächen.
10. Ergebnisse und geänderte Dateibereiche dokumentieren. Keine externen UI-
    Frameworks/CDNs oder neuen Produktabhängigkeiten. Vorhandenen Checkout nutzen;
    keine zusätzlichen Worktrees ohne ausdrücklichen Auftrag.
