# Projektstart: NWB Verwaltung – Nahwärme-Abrechnung

Du entwickelst eine professionelle, eigenständige Verwaltungs- und Abrechnungssoftware für Betreiber von Nahwärmeanlagen.

Die Anwendung heißt vorläufig **NWB Verwaltung**.

Arbeite als erfahrener Ruby-on-Rails-Architekt und Entwickler für kaufmännische Verwaltungssoftware.

Wichtigste Ziele:
1. Fachlich korrekte Abrechnungen
2. Datenschutz und Sicherheit
3. Einfache, verständliche Bedienung
4. Wartbare, nachvollziehbare Architektur
5. Reproduzierbarer Docker-Betrieb
6. Hoher Automatisierungsgrad ohne unnötige Komplexität

## 1. Bestehende GitHub-Projekte untersuchen

### Joomla-Kundenportal – verbindliche API-Referenz

Repository: https://github.com/Titanyus/NWBKunden

**Lies zuerst den aktuellen Stand des Repositories.**

Besonders wichtig:

- `AGENTS.md`
- `README.md`
- `docs/PROJECT_STATUS.md`
- `docs/v0.4/README.md`
- `docs/v0.4/api-vertrag.md`
- `docs/v0.4/openapi.json`
- `docs/v0.4/sicherheit.md`
- `docs/v0.4/betrieb.md`
- `docs/v0.4/examples/`
- Aktuelle Testimplementierungen der API

Die Joomla-Komponente `com_nahwaerme` besitzt bereits eine funktionierende Snapshot-API.

Die Rails-Software soll diese vorhandene Schnittstelle verwenden.

**Erfinde keine neue API, wenn der vorhandene Vertrag die Funktion bereits abdeckt.**

Die bestehende API-Version 1.0 sieht unter anderem vor:

- Vollständige Bestandsmeldungen je Quelle, Anlage und Kunde
- Vorbereitung von Übertragungen
- Separate Übermittlung von PDF-Dokumenten
- Abschließende atomare Veröffentlichung
- Versionsnummern zur Verhinderung veralteter Daten
- Wiederholbare Übertragungen ohne Duplikate
- Kontrollierten Rückzug nicht mehr bereitzustellender Daten

Die tatsächliche Implementierung im aktuellen Repository ist verbindlich. Prüfe sie gegen die Dokumentation.

Das Joomla-Repository ist ausschließlich lesend zu verwenden. Verändere dort nichts ohne gesonderten Auftrag.

Falls der Zugriff auf das private Repository fehlt, melde dies ausdrücklich. Keine Schnittstelle auf Grundlage von Vermutungen implementieren.

### Bestehendes Rails-Referenzprojekt

Repository: https://github.com/Titanyus/IFF

Dieses Projekt dient ausschließlich als technische Referenz für:

- Ruby on Rails mit Hotwire
- PostgreSQL
- Docker Compose
- Sicherheits- und Berechtigungsregeln
- Modulare Architektur
- Testkonzepte und Codex-Guardrails

Übernimm sinnvolle technische Prinzipien, aber keine Fachlogik der Frühförderungsverwaltung.

## 2. Technologiestack

Verwende:

- Ruby on Rails
- Hotwire / Turbo / Stimulus
- PostgreSQL
- Docker Compose
- Serverrenderte, responsive Verwaltungsoberfläche
- Automatisierte Rails-Tests
- RuboCop, Brakeman und Dependency-Sicherheitsprüfungen

Orientiere dich an den bewährten Versions- und Docker-Konventionen des IFF-Projekts. Prüfe konkrete Versionskompatibilität und fixiere die verwendeten Versionen.

Keine zusätzliche SPA, keine Microservices und keine unnötigen JavaScript-Frameworks.

Die Anwendung soll als eigenständiger Docker-Stack portabel betrieben werden können.

## 3. Betreiber und Anlagenverwaltung

Eine Installation gehört genau einem Nahwärmebetreiber.

Keine SaaS-Plattform und keine zentrale Verwaltung unterschiedlicher Betreiber.

Die Anwendung muss eine oder viele Anlagen verwalten können, beispielsweise 50 oder mehr.

Ein Verwaltungsbenutzer kann für mehrere Anlagen berechtigt sein.

Die Berechtigungen gelten serverseitig, nicht nur in der Oberfläche.

Für jede Anlage werden gespeichert:

- Name und Anschrift
- Grundlegende technische Informationen
- Trassen beziehungsweise Versorgungsabschnitte
- Angeschlossene Haushalte beziehungsweise Anschlüsse
- Verfügbare Tarife
- Zugeordnete Kunden und Verträge
- Portalverbindungen für die Datenübertragung

## 4. Kunden, Anschlüsse und Verträge

Verwalte:

- Kundenstammdaten
- Anschrift und Kontaktdaten
- Verbrauchsstellen und Anschlüsse
- Trassenzugehörigkeit
- Wärmezähler und Zählernummern
- Vertragsbeginn und Vertragsende
- Tarifzuordnung
- Jährliche und zusätzliche Zählerablesungen
- Zahlungsart und Kennzeichen für Lastschriftvereinbarung
- Interne Kommentare und besondere Vereinbarungen

Trenne Kunde, Anschluss, Vertrag und Zähler als eigenständige fachliche Objekte.

Ein Kunde kann mehrere Anschlüsse besitzen.

Historische Eigentümer-, Vertrags-, Tarif- und Zählerwechsel müssen nachvollziehbar bleiben.

Keine überflüssigen Stammdaten oder Funktionen auf Vorrat entwickeln.

## 5. Tarifverwaltung

Tarife bestehen aus zeitlich gültigen Konditionen.

Unterstütze insbesondere:

- Arbeitspreis je kWh
- Grundpreis
- Mehrere Tarife je Anlage
- Tarifwechsel einzelner Kunden
- Unterjährige Preisänderungen
- Zeitlich begrenzte Sonderkonditionen
- Kostenfreie Zeiträume
- Feste und prozentuale Rabatte

Tarifversionen dürfen historische Abrechnungen nicht nachträglich verändern.

Keine generische, frei programmierbare Regel-Engine entwickeln.

## 6. Zählerstände und Verbrauch

Regulär erfolgt eine jährliche Zählerablesung.

Der Verbrauch ergibt sich aus der Differenz der maßgeblichen Zählerstände unter Berücksichtigung dokumentierter Zählerwechsel.

**Verbindliche Regel bei unterjährigen Änderungen verbrauchsabhängiger Preise:**

Es muss eine passende Zwischenablesung zum Wechselstichtag vorliegen.

Keine geschätzte, saisonal gewichtete oder automatisch kalendertäglich verteilte Verbrauchsmenge verwenden.

Fehlt eine erforderliche Zwischenablesung, darf die betroffene Abrechnung nicht freigegeben werden.

Für kostenlose verbrauchsabhängige Zeiträume gilt derselbe Grundsatz: Der erlassene Verbrauch muss anhand geeigneter Ablesungen bestimmbar sein.

Reine Grundpreisänderungen oder feste Geldgutschriften benötigen keine zusätzliche Verbrauchsablesung, sofern ihre Berechnungsregeln festgelegt sind.

## 7. Jahresabrechnung und Abschläge

Die Abrechnungssoftware ersetzt die bisherige Excel-Abrechnung.

Die fachlichen Formeln müssen anhand anonymisierter historischer Excel-Abrechnungen geprüft und dokumentiert werden.

Unterstütze:

- Jährliche Abrechnungszeiträume
- Verbrauchskosten
- Grundgebühren
- Gültige Tarifversionen
- Sonderkonditionen
- Abschlagsplanung
- Tatsächlich geleistete Zahlungen
- Nachzahlungen und Guthaben
- Rechnungsprüfung und Freigabe

Abschläge werden gleichmäßig auf die vorgesehenen Zahlungstermine verteilt.

Es findet keine saisonale Gewichtung der Abschläge statt.

Geplante Abschläge und tatsächlich bezahlte Abschläge müssen getrennt gespeichert werden.

Verwende exakte Dezimalarithmetik für Geldbeträge.

Lege Rundungsregeln ausdrücklich fest.

Keine stillschweigenden Annahmen über Umsatzsteuer, Zahlungsfälligkeiten oder weitere Abrechnungsregeln treffen.

## 8. Gutschriften, Vergünstigungen und Entschädigungen

Unterstütze:

- Feste Erstattungsbeträge
- Prozentuale Nachlässe
- Kostenfreie Zeiträume
- Vergünstigungen für einzelne Kunden
- Vergünstigungen für ausgewählte Kunden
- Vergünstigungen für ganze Trassen
- Vergünstigungen für komplette Anlagen

Typische Anlässe:

- Technische Versorgungsstörungen
- Kulanz
- Startaktionen
- Individuelle Vereinbarungen

Die Verwaltung muss vor einer Sammelaktion alle betroffenen Kunden und die finanziellen Auswirkungen prüfen können.

Unterscheide fachlich zwischen:

- Rabatt beziehungsweise Entgeltminderung
- Rechnungskorrektur
- Eigenständiger Entschädigung
- Tatsächlicher Rückzahlung

Keine pauschale steuerliche Behandlung dieser unterschiedlichen Vorgänge annehmen.

Bereits freigegebene Rechnungen dürfen nicht stillschweigend geändert werden.

## 9. ZUGFeRD-E-Rechnungen

Die Software soll ZUGFeRD-/Factur-X-Rechnungen erzeugen können.

Dabei entsteht ein lesbares PDF/A-3 mit eingebetteten strukturierten Rechnungsdaten.

Prüfe geeignete bestehende Ruby-Bibliotheken.

Bevorzuge eine gepflegte, dokumentierte Lösung. Falls mehrere Werkzeuge nötig sind, halte die Integration möglichst klein.

Anforderungen:

- Geeignetes ZUGFeRD-Profil, vorzugsweise EN 16931
- Versionskompatibilität nachweisen
- Einheitlicher Rechnungsdatensatz für PDF und XML
- Unabhängige XML-/EN-16931-Validierung
- Prüfung des PDF/A-3-Formats
- Dokumentierte Validierungsergebnisse
- Unterstützung geeigneter Korrekturdokumente

Eine erzeugte PDF-Datei darf nicht allein deshalb als gültige E-Rechnung bezeichnet werden, weil XML eingebettet wurde.

Rechnungen werden vor der Veröffentlichung menschlich freigegeben.

Freigegebene Rechnungen und ihre ursprünglichen Daten bleiben nachvollziehbar erhalten.

## 10. Banksoftware statt Bankanbindung

Keine direkte Bankanbindung implementieren.

Kein eigenes Onlinebanking, keine eigenständige SEPA-Einreichung und keine automatische Bankkommunikation.

Später kann ein Export für eine externe Banksoftware vorgesehen werden.

Das konkrete Exportformat wird erst nach Auswahl der verwendeten Banksoftware festgelegt.

## 11. Joomla-Portalverbindungen

Die Rails-Anwendung soll mehrere unabhängige Joomla-Portale bedienen können.

Portalverbindungen sind eigene Verwaltungsobjekte, unabhängig von den Anlagen.

Eine Portalverbindung kann mehreren Anlagen zugeordnet werden.

Eine Anlage kann bei Bedarf mehrere Portalverbindungen besitzen.

Je Portalverbindung werden insbesondere verwaltet:

- Zieladresse
- API-Zugang
- Zugeordnete Anlagen
- Verbindungsstatus
- Letzte erfolgreiche Übertragung
- Fehlerstatus
- Übertragungsprotokoll

Geheimnisse müssen geschützt gespeichert werden.

Die Synchronisierung erfolgt ausschließlich über die tatsächlich dokumentierte Joomla-API.

Implementiere hierfür eine dauerhafte Rails-Outbox, die auch fehlgeschlagene Übertragungen nachvollziehbar und sicher wiederholen kann.

Beachte insbesondere:

- Stabile UUIDs für Quelle, Anlage, Kunde, Anschluss und Dokument
- Vollständige Kundenbestände statt unkontrollierter Einzelupdates
- Monoton steigende Revisionen je Kundenbereich
- Unveränderliche Übertragungspakete bei Wiederholungen
- Getrennte Übertragungsbelege pro Portalziel
- Dokumentenintegrität durch SHA256 und Dateigröße
- Sicherheitsgrenzen und Mengenlimits der Joomla-API
- Statusabfragen und kontrolliertes Wiederholen
- Schutz vor SSRF bei konfigurierbaren Portaladressen
- Kein Versand unfertiger oder nicht freigegebener Rechnungen

Joomla bleibt ein passiver Empfänger.

Keine Rechnungsberechnungen in Joomla ausführen.

## 12. Sicherheit und Datenintegrität

Verbindliche Regeln:

- Keine echten Kundendaten in Entwicklung oder Tests
- Keine Zugangsdaten im Repository
- Alle Benutzerrechte serverseitig prüfen
- Zugriff auf mehrere Anlagen explizit autorisieren
- Keine Einsicht in unberechtigte Anlagen
- Finanzielle Änderungen nachvollziehbar protokollieren
- Keine freigegebenen Rechnungen still überschreiben
- Keine destruktiven Migrationen ohne Freigabe
- Keine automatischen Löschungen historischer Abrechnungsoriginale
- Keine produktiven Datenimporte oder Veröffentlichungen während der Entwicklung
- Keine unnötigen externen Cloud-Dienste
- Datenschutz und spätere Aufbewahrungsregeln berücksichtigen

## 13. Verbindliche Codex-Arbeitsweise

Erstelle eine `AGENTS.md` und einen projektspezifischen Codex-Skill.

Orientiere dich an den Entwicklungsstandards des IFF-Projekts.

Arbeite in kleinen, nachvollziehbaren Schritten.

Vor wesentlichen Änderungen an Architektur, Sicherheitsmodell und Datenmodell zuerst die Auswirkungen dokumentieren.

Jede fachliche Berechnungsfunktion braucht automatisierte Referenztests.

Bei fehlenden Geschäftsregeln keine scheinbar korrekten Berechnungsmethoden erfinden.

Führe Tests tatsächlich aus und dokumentiere die Ergebnisse.

## 14. Erster konkreter Entwicklungsauftrag

Beginne mit einer Bestandsaufnahme der beiden GitHub-Referenzprojekte.

Erstelle anschließend im neuen Rails-Projekt:

1. `AGENTS.md` mit verbindlichen Entwicklungsregeln
2. Codex-Skill für die Nahwärme-Verwaltung
3. Technische Architektur und fachliches Datenmodell
4. Verbindliche API-Referenz auf NWBKunden
5. Dokumentation der bereits entschiedenen Abrechnungsregeln
6. Liste noch offener kaufmännischer Entscheidungen
7. Docker-Compose-Entwicklungsumgebung
8. Rails-/Hotwire-Grundanwendung mit PostgreSQL
9. Benutzeranmeldung und grundlegende Anlagenberechtigungen
10. Erste einfache Verwaltungsoberfläche zur Anlage und Auswahl mehrerer Nahwärmeanlagen
11. Synthetische Testdaten für einen kleinen Betreiber und einen größeren Betreiber mit 50 Anlagen in getrennten Testinstallationen
12. Automatisierte Tests für Anmeldung, Berechtigungen, Datenintegrität und Docker-Start

Erstelle zunächst nur diesen funktionsfähigen Grundaufbau.

Danach plane die nächsten Entwicklungsschritte für:

- Kunden und Anschlüsse
- Tarife und Zählerablesungen
- Jahresabrechnung und Abschläge
- Gutschriften und Entschädigungen
- ZUGFeRD-Rechnungserstellung
- Joomla-Outbox und API-Anbindung

Die existierende Joomla-API soll frühzeitig mit einem synthetischen Rails-Integrationstest geprüft werden, bevor echte Rechnungsfunktionen darauf aufbauen.

**Am Ende des ersten Auftrags erwarte ich:**

- Eine lauffähige Rails-Anwendung in Docker
- Eine funktionierende Verwaltung mehrerer Anlagen
- Eine dokumentierte Architektur
- Ein nachvollziehbares Datenmodell
- Automatisierte Tests und deren tatsächliche Ergebnisse
- Eine Übersicht der offenen fachlichen Fragen
- Einen Vorschlag für den nächsten kleinen Entwicklungsauftrag

Entwickle nicht sofort die gesamte Abrechnungssoftware.

Die erste Version muss eine saubere Grundlage für die späteren fachlichen Funktionen schaffen.