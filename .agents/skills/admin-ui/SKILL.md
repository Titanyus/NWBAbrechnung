---
name: admin-ui
description: Verbindlicher Desktop-UI-Standard für neue und bestehende NWB-Verwaltungsansichten, Tabellen, Formulare und UI-Reviews.
---

Aktuelle Pilot-Abgrenzung hat Vorrang: zunächst nur die Vertragsverwaltung nach
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
