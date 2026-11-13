# Entwicklungsauftrag 02 – Umsetzung und neue Prüfergebnisse

Stand: 13.11.2026. Grundlage: BRIEF_02.md. Ausschließlich synthetische Daten.

## Umgesetzt

- Einmalige Kundenstammdaten mit stabiler UUID; je Anlage eigene Kundennummer,
  Zahlungsart, Lastschriftkennzeichen und Aktivstatus. Suche nach Firma, Vor-/
  Nachname (auch vollständigem Namen) oder Kundennummer; Aktivfilter und Seiten.
- Anschlüsse mit UUID, Adresse, Status, Inbetriebnahme und Trassenzuordnung.
- Trassen mit Name, Kennung und Beschreibung.
- Wärmelieferverträge mit stabiler Kundenzuordnung, Zeitgrenzen, Status und
  Bemerkungen. Keine Überschneidungen aktiver/beendeter Hauptlieferverträge.
- Wärmezähler, exakte kumulative Ablesungen, beliebig viele Zwischenablesungstage,
  atomarer Wechsel mit Schluss-/Anfangswert und nachvollziehbare Korrekturketten.
- Geschützte Historie mit Benutzer, Zeitpunkt und Vorher-/Nachherwerten; keine
  Löschrouten. Gemeinsame Kundendaten nur bei Zugriff auf alle Zuordnungen editierbar.
- Responsive, servergerenderte Hotwire-Oberfläche in der bestehenden Anlagenwahl.
- Additive Migration; PostgreSQL-Intervallconstraints und zusammengesetzte
  Fremdschlüssel verhindern Überlappungen bzw. fremde Anlagenzuordnungen.
- INFO-Logging und Parameterfilter für Kontakt-/Geschäftsdaten einschließlich
  Suchtext und Login-E-Mail; Prüfung mit tatsächlich aufgezeichneten Requestlogs.

## Tatsächlich ausgeführte Prüfungen

| Prüfung | Ergebnis |
|---|---|
| Rails-Gesamtsuite | **50 Tests, 320 Assertions, 0 Fehlschläge, 0 Fehler, 0 Skips**; bisherige 20 Grundaufbau-Tests enthalten |
| RuboCop | 55 Ruby-Dateien, keine Verstöße |
| Brakeman 8.1.0 | 0 Fehler, 0 Sicherheitswarnungen |
| Dependency-Audit | keine bekannten Schwachstellen; Advisory-DB 305f8b079a23bf95d00c881842f366bb8db19f35 |
| Zeitwerk | Eager Loading erfolgreich |
| Kunden-/Berechtigungstests | mehrere Anschlüsse und Anlagen je Kunde, gleiche Nummern in verschiedenen Anlagen, fremde und manipulierte IDs, gemeinsame Kunden, anlagenbeschränkte Suche/Filter, XSS und Massenparameter geprüft |
| Vertrags-/DB-Tests | historische Kundenbindung, inklusive Datumsgrenzen, Überschneidungen sowie Fremdschlüssel auch bei umgangenen Modellvalidierungen geprüft |
| Ablese-/Wechseltests | Präzision, negative/ungültige Werte, Duplikate, Chronologie, belegte Rückgänge, ursprüngliche Werte bei Korrekturen, unveränderliche Historie, Actor, Audit und vollständiger Rollback eines fehlgeschlagenen Wechsels geprüft |
| Stammdaten-Browser | komplette Erstellung/Bearbeitung von Kunde, Trasse, Anschluss, Vertrag, Zähler, Zwischenablesung, Korrektur, Wechsel und Kundensuche erfolgreich |
| Mobil/Desktop | Detail- und Formularseiten bei 390 und 1280 Pixeln; kein horizontaler Überlauf und keine JavaScriptfehler |
| Große Installation | Stammdaten-Browserablauf mit bestehendem 50-Anlagen-Betreiber erfolgreich |
| Docker-Neubuild ohne Quellcode-Mount | compose.build.yaml gebaut und als eigenständiger Teststack erfolgreich gestartet; Stammdatenablauf darin bestanden |
| Frische Installation | separater neuer PostgreSQL-Datenpfad, Schema/Extension/Seeds, Docker-Healthchecks, HTTP-Smoke und Stammdaten-Browser erfolgreich |
| Update eines bestehenden Images | altes Grundaufbau-Image mit bestehender DB durch Neubuild/Start aktualisiert; automatische additive Migration erfolgreich |
| Alte Daten nach Migration | SHA-256 über Betreiber, Anlagen, Benutzer (einschl. Passwortdigest), Rechte und alte Auditfelder vor/nach Migration unverändert; mit 3 und 50 Anlagen geprüft |
| Neue Daten nach Neustart | vollständige Prüfsumme über vorhandene Grund-/Stammdaten, Verträge, Zähler, ursprüngliche/korrigierte Ablesungen und Audit vor/nach regulärem Web-Neustart plus erneutem db:migrate unverändert; HTTP-Smoke anschließend bestanden |
| Bisherige Browserfunktionen | Login, Anlagenwahl, Hotwire, Logout, getrennte kleine/große Sitzungen und 40 Farb-/Kontrastkombinationen bestanden |
| Bestehender Rails → Joomla-Test | 1 Test, 13 Assertions, 0 Fehler/Fehlschläge/Skips; keine neue API und kein produktiver Versand |

Die Vergleichsprüfsummen für die alten Grundaufbaudaten waren:

- 3 Anlagen: cbb734fd32e0eceab2d5ff3e0d31b3f36c8f966c716e0eefa00e5aab478bef47
- 50 Anlagen: 71634a3b7d7a0bbadd23f9f65bb21f38f0a9f74ebc3538a7eea14c793eefd99a

Prüfsummen enthalten keine veröffentlichten Zugangsdaten oder personenbezogenen
Datensätze. Rohdaten und private Konfigurationen bleiben außerhalb Git.

## Geänderte Bereiche

- `db/migrate/20261113000200_create_master_data.rb`, `db/schema.rb`: sieben neue
  Tabellen, optionale Auditfelder, Indizes/FKs/Checks und Intervallconstraints.
- `app/models/`: Customer, CustomerMembership, RouteSection, Connection,
  SupplyContract, HeatMeter, MeterReading sowie Beziehungen in Plant/Operator.
- `app/services/master_data/`: transaktionale Speicherung, Audit, Ablesekorrektur
  und Zählerwechsel. Keine Verbrauchs- oder Geldberechnung.
- Anlagenbezogene Controller und Views, bestehende Anlagendetailseite,
  Farbsystem-kompatibles CSS, Routen und datensparsame Logkonfiguration.
- `test/models/master_data_test.rb`, `test/integration/master_data_access_test.rb`,
  synthetische Testhelfer und `scripts/master_data_smoke.py`.
- Originalauftrag, Architektur-/Berechtigungsentscheidungen, Anleitung, Fachfragen
  und Roadmap unter `docs/` sowie README.

## Wiederholen und Dockhand aktualisieren

Standardprüfungen laut README; die Rails-Suite umfasst automatisch die neuen
Tests. Der Stammdaten-Browserlauf legt eindeutige synthetische Datensätze an:

```sh
python3 scripts/master_data_smoke.py
python3 scripts/master_data_smoke.py --env-file /workspace/nwb-large.env --port 3001
```

In Dockhand den Git-Stand von main aktualisieren und den **bestehenden** Stack mit
compose.build.yaml neu bauen/ausspielen. `.env`, Stackname und Datenpfad erhalten.
`db:prepare` führt die neue Migration automatisch aus. Kein GHCR-Zugang, kein
Datenreset, keine neuen Geheimnisse und keine manuelle Seed-Ausführung erforderlich.
Getestet wurde dieser Ablauf lokal mit Docker/Compose, nicht auf dem externen
Dockhand-Host. GitHub-CI-Ergebnisse nach Push werden hier nicht vorweggenommen.

## Grenzen und offene Entscheidungen

MASTER_DATA_DESIGN.md erläutert bewusst gewählte Datumsgrenzen, Zahlungs-/
Statuskataloge und die Berechtigung für gemeinsame Kunden. Uhrzeitgenaue
Mehrfachwechsel, zusätzliche Messzwecke und Regeln für Zählerüberlauf bleiben
offen. Inaktivmarkierung beendet keine Verträge automatisch. Das Audit ist kein
Schutz gegen Datenbankadministratoren. Neue Tabellen werden nicht mit echten
Kundendaten befüllt. Native Joomla-Suite unverändert; ihr historischer Upgradepfad
wurde hier nicht erneut getestet.

Keine Tarife, Jahres-/Abschlagsrechnung, ZUGFeRD, Gutschriften, Bankanbindung oder
produktive Joomla-Synchronisation implementiert. Als Schritt 3 wird eine kleine,
versionierte Tarifverwaltung mit datierten Zuordnungen empfohlen, zunächst ohne
Jahresberechnung. Vor Geldberechnungen müssen Excel-Referenzen sowie Steuer- und
Rundungsregeln freigegeben sein. Kein Image-Publish, externer Deploy oder
Veröffentlichung der Cloud-Umgebung wurde ausgeführt.
