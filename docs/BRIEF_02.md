# NWB Verwaltung – Entwicklungsauftrag 02
## Kunden, Verträge, Anschlüsse und Zählerverwaltung

### 1. Ausgangslage

Die Ruby-on-Rails-Anwendung „NWB Verwaltung“ wurde in Schritt 1 eingerichtet.

Das Projekt verwendet:
- Ruby on Rails mit Hotwire
- PostgreSQL
- Docker Compose
- Eine bestehende Benutzeranmeldung
- Anlagenverwaltung mit Berechtigungen
- Verbindliche Codex-Guardrails

**Wichtig:** Lies zuerst `AGENTS.md`, die vorhandenen Skills, die Architekturentscheidungen und das bestehende Datenmodell.

Untersuche die bereits implementierten Funktionen, bevor du Änderungen vornimmst.

Erweitere ausschließlich die bestehende Anwendung. Keine Neuentwicklung, keine unnötigen Frameworks oder zusätzlichen Abhängigkeiten.

### 2. Ziel dieses Entwicklungsschritts

Implementiere eine vollständige, aber bewusst einfach gehaltene Stammdatenverwaltung für:

1. Kunden
2. Verbrauchsstellen und Hausanschlüsse
3. Wärmezähler
4. Zählerablesungen
5. Wärmelieferverträge
6. Trassen beziehungsweise Versorgungsabschnitte

Die Funktionen müssen mit einer Anlage genauso funktionieren wie mit 50 oder mehr Anlagen.

### 3. Kundenverwaltung

Für jeden Kunden sollen folgende Informationen verwaltet werden können:

- Eindeutige interne UUID
- Optionale Kundennummer
- Vorname und Nachname beziehungsweise Firmenname
- Anschrift
- Telefon
- E-Mail-Adresse
- Interne Bemerkungen
- Zahlungsart
- Kennzeichen, ob eine Lastschriftvereinbarung vorliegt
- Aktiv- beziehungsweise Inaktivstatus

Kunden müssen bearbeitet, gesucht und gefiltert werden können.

Ein Kunde kann mehrere Verbrauchsstellen und Verträge besitzen.

Kundendaten dürfen nicht unnötig dupliziert werden.

Berücksichtige Privatpersonen und Unternehmen als mögliche Rechnungsempfänger.

Eine Kundennummer muss nicht über alle Anlagen hinweg eindeutig sein. Verwende interne UUIDs für technische Beziehungen.

### 4. Anlagen und Trassen

Ergänze die vorhandene Anlagenverwaltung um Trassen beziehungsweise Versorgungsabschnitte.

Eine Anlage kann mehrere Trassen besitzen.

Eine Trasse enthält:
- Bezeichnung
- Optionale interne Kennung
- Zugehörige Nahwärmeanlage
- Optionale Beschreibung

Verbrauchsstellen können einer Trasse zugeordnet werden.

Die Trassenzuordnung muss später für Auswertungen und gezielte Entschädigungen bei Versorgungsstörungen nutzbar sein.

Implementiere noch keine komplexe geografische Netzplanung.

### 5. Verbrauchsstellen und Anschlüsse

Verbrauchsstellen sind eigenständige Objekte.

Erfasse:
- Stabile UUID
- Anlagenzugehörigkeit
- Zugehörige Trasse
- Anschlussnummer
- Anschlussadresse
- Datum der Inbetriebnahme
- Technischer Status
- Optionale Bemerkungen

Eine Verbrauchsstelle kann über die Jahre unterschiedlichen Kunden zugeordnet sein.

Vermeide deshalb eine Architektur, bei der ein Kundenwechsel die historische Zuordnung und alte Rechnungen verändert.

Eine Verbrauchsstelle kann über ihre Lebensdauer mehrere Wärmezähler besitzen.

### 6. Wärmezähler

Für jeden Wärmezähler sollen gespeichert werden:

- Eindeutige interne UUID
- Zählernummer
- Verbrauchsstelle
- Einbaudatum
- Ausbaudatum, falls vorhanden
- Einheit, vorzugsweise kWh
- Optionaler Kommentar

Ein Zählerwechsel muss nachvollziehbar sein.

Historische Zähler und ihre Ablesungen dürfen nicht durch den Einbau eines neuen Zählers überschrieben werden.

Prüfe, dass an einer Verbrauchsstelle nicht unbeabsichtigt mehrere gleichzeitig aktive Hauptzähler für denselben Messzweck existieren.

### 7. Zählerablesungen

Erfasse für jede Ablesung:

- Zugehöriger Wärmezähler
- Ablesedatum
- Zählerstand
- Ableseart: Jahresablesung, Zwischenablesung, Einbau, Ausbau oder Korrektur
- Optionaler Kommentar
- Erfassungszeitpunkt und erfassender Benutzer

Der Zählerstand ist ein kumulativer Messwert.

Verbrauchswerte werden aus den relevanten Ablesungen berechnet und dürfen nicht mit Zählerständen verwechselt werden.

Verwende exakte Dezimalwerte, keine Float-Berechnungen.

Implementiere Plausibilitätsprüfungen:

- Keine negativen Zählerstände.
- Keine versehentlich doppelt erfassten Ablesungen.
- Keine unplausiblen rückläufigen Zählerstände ohne dokumentierten Sonderfall.
- Chronologisch nachvollziehbare Ablesungen.
- Bei einem Zählerwechsel müssen die notwendigen Schluss- und Anfangswerte vorhanden sein.

Korrekturen müssen nachvollziehbar bleiben.

**Wichtig für spätere Tarifänderungen:**

Die Software muss beliebig viele fachlich notwendige Zwischenablesungen innerhalb eines Jahres speichern können.

Bei Änderungen verbrauchsabhängiger Preise benötigen wir später eine Ablesung zum jeweiligen Wechselstichtag.

Noch keine Tarif- oder Jahresabrechnungslogik implementieren.

### 8. Wärmelieferverträge

Verträge bilden die zeitliche Beziehung zwischen Kunde und Verbrauchsstelle.

Erfasse:

- Stabile Vertrags-UUID
- Kunde beziehungsweise Rechnungsempfänger
- Verbrauchsstelle
- Vertragsnummer
- Vertragsbeginn
- Optionales Vertragsende
- Vertragsstatus
- Optionale Bemerkungen

Eine Verbrauchsstelle kann nacheinander mehrere Verträge besitzen, aber keine unbeabsichtigten zeitlichen Überschneidungen aktiver Hauptlieferverträge.

Ein Vertragsende darf historische Verbräuche oder Rechnungszuordnungen nicht verändern.

Die Tarifzuordnung wird im nächsten Entwicklungsschritt ergänzt.

### 9. Benutzeroberfläche

Erstelle eine übersichtliche, responsive Verwaltungsoberfläche mit Hotwire.

Gewünschter Aufbau:

**Anlage auswählen → Kunden / Anschlüsse / Zähler / Verträge**

Ein Mitarbeiter mit Zugriff auf mehrere Anlagen kann zwischen seinen berechtigten Anlagen wechseln.

Benötigte Funktionen:
- Kundenliste mit Suche
- Kundendetailansicht
- Zugehörige Verbrauchsstellen anzeigen
- Verträge anzeigen und bearbeiten
- Zähler einer Verbrauchsstelle anzeigen
- Zählerablesungen erfassen
- Historische Ablesungen ansehen
- Trassen verwalten

Die Bedienung soll auch für kaufmännische Mitarbeiter ohne technische Kenntnisse verständlich sein.

Nutze einfache, klare Formulare und aussagekräftige Fehlermeldungen.

Keine unnötigen Dashboards oder komplexen Auswertungen entwickeln.

### 10. Berechtigungen und Datenschutz

Sämtliche Datenabfragen und Änderungen müssen auf die Anlagen begrenzt sein, für die der angemeldete Mitarbeiter berechtigt ist.

Verbindliche Anforderungen:

- Serverseitige Zugriffskontrolle bei jeder Aktion
- Kein Zugriff auf fremde Anlagen durch manipulierte URLs
- Keine Datenlecks durch Suchfunktionen oder verschachtelte Ressourcen
- Keine unkontrollierten Massenänderungen
- Keine automatische endgültige Löschung historischer Daten
- Nachvollziehbare Änderungen an Verträgen, Zählern und Ablesungen
- Keine personenbezogenen Daten in Standardlogs
- Ausschließlich synthetische Testdaten

Bestehende Benutzerrollen und Berechtigungsmechanismen weiterverwenden.

Keine zweite Benutzerverwaltung implementieren.

### 11. Vorbereitung auf die Joomla-API

Das bestehende Joomla-Portal befindet sich im Repository:

https://github.com/Titanyus/NWBKunden

Lies insbesondere:
- `docs/v0.4/api-vertrag.md`
- `docs/v0.4/openapi.json`
- `docs/v0.4/README.md`

Die Joomla-API verwendet stabile externe Kennungen für Quellen, Anlagen, Kunden, Verbrauchsstellen und Rechnungsdokumente.

Berücksichtige diese Kennungen bereits im Datenmodell.

**Wichtig:** Verwende für die spätere Synchronisation stabile UUIDs, die durch Änderungen von Namen, Kundennummern oder Adressen nicht ungültig werden.

Implementiere in diesem Schritt noch keine vollständige Datenübertragung.

### 12. Automatisierte Tests

Erstelle Tests insbesondere für:

1. Kunde mit mehreren Verbrauchsstellen.
2. Kunde mit Verbrauchsstellen in unterschiedlichen Anlagen.
3. Unterschiedliche Kunden mit derselben Kundennummer in verschiedenen Anlagen.
4. Verbrauchsstelle mit mehreren historischen Verträgen.
5. Verhinderung unzulässiger Vertragsüberschneidungen.
6. Wärmezählerwechsel mit historischen Ablesungen.
7. Jährliche und zusätzliche Zwischenablesungen.
8. Plausibilitätsprüfung rückläufiger Zählerstände.
9. Mitarbeiter mit Berechtigung für mehrere Anlagen.
10. Unberechtigter Zugriff auf eine fremde Anlage.
11. Manipulierte Kunden-, Vertrags- und Zähler-IDs.
12. Erhalt vorhandener Daten bei Docker-Neustart und Migration.

Führe die Tests tatsächlich aus und dokumentiere die Ergebnisse.

### 13. Entwicklungsgrenzen

Nicht Bestandteil dieses Schritts:

- Tarifberechnung
- Jahresabrechnung
- Abschlagsberechnung
- ZUGFeRD-Erstellung
- Gutschriften
- Entschädigungen
- SEPA oder Bankanbindung
- Produktive Joomla-Synchronisation
- Komplexe Statistiken

Keine Funktionen aus späteren Entwicklungsschritten vorziehen.

### 14. Abschluss und Abnahme

Am Ende erwarte ich:

- Funktionierende Stammdatenverwaltung
- Funktionierende Vertrags- und Zählerverwaltung
- Responsive Verwaltungsoberfläche
- Versionierte Datenbankmigrationen
- Ausgeführte automatische Tests
- Erfolgreichen Docker-Start
- Zusammenfassung der geänderten Dateien
- Dokumentation offener fachlicher Fragen
- Empfehlung für Entwicklungsschritt 3

**Wichtig:** Bestehende Daten und Funktionen aus Schritt 1 müssen vollständig erhalten bleiben.

Arbeite in kleinen nachvollziehbaren Änderungen. Triff keine stillen Grundsatzentscheidungen über Datenmodell, Berechtigungen oder historische Zuordnungen.

Ziel ist eine belastbare Stammdatenbasis für die spätere Nahwärmeabrechnung, keine überdimensionierte Verwaltungsplattform.