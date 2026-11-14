# NWB Verwaltung

Eigenständiger Grundaufbau für einen Nahwärmebetreiber mit mehreren Anlagen.
Rails/Hotwire, PostgreSQL und Docker Compose. Ausschließlich synthetische Daten;
noch keine Abrechnung, E-Rechnung oder Portalveröffentlichung.

## Start

Docker Engine und Compose V2, Python 3 für lokale Hilfsskripte.

```sh
bin/dev-env
docker compose build
docker compose up -d --wait
docker compose exec -T -e NWB_LOAD_DEMO=1 web bin/rails db:seed
```

Der Entwicklungsserver bindet ausschließlich Loopback auf Port 3000. Anmeldung:
`admin@example.test` oder `verwaltung@example.test`, Passwort aus der lokalen
Datei `.env` (DEMO_PASSWORD). Nicht in Chats, Logs oder Git kopieren.
Admin sieht im kleinen synthetischen Betreiber drei Anlagen, Verwaltung zwei.
Keine öffentliche Registrierung. Neue Benutzer werden bewusst per Rails-Konsole
angelegt und Anlagen einzeln über PlantPermission zugewiesen. Alle Konten ohne
Zuordnungen sehen keine Anlagen; Administratorstatus allein gibt keinen Lesezugriff.

Die `.env` wird exklusiv mit Modus 0600 erzeugt und nie überschrieben.
Seeds verändern vorhandene Konten/Passwörter nicht. Serverstart migriert additiv,
legt aber keine Testdaten an. Nicht mit echten Daten betreiben.

Hinter dem Cloud-HTTPS-Proxy:

```sh
docker compose -f compose.yaml -f compose.cloud.yaml build
```

Der Build mountet das kombinierte CA-Bundle nur temporär. TLS-Verifikation bleibt
aktiv. Kein Ruby/Bundle auf dem Host erforderlich. `Gemfile.lock` ist verbindlich;
normaler Build verwendet BUNDLE_FROZEN. Versionsupdates bewusst prüfen.

## Zweite, getrennte Testinstallation mit 50 Anlagen

Eigenes Compose-Projekt, eigener Port, eigenes Volume und eigene Konfiguration.
Beispiel für eine **neue** lokale Datei außerhalb Git:

```sh
python3 bin/dev-env /tmp/nwb-large.env
# In /tmp/nwb-large.env DEMO_SIZE=large und NWB_PORT=3001 setzen.
docker compose --env-file /tmp/nwb-large.env -p nwb-large up -d --build --wait
docker compose --env-file /tmp/nwb-large.env -p nwb-large exec -T -e NWB_LOAD_DEMO=1 web bin/rails db:seed
python3 scripts/smoke.py --env-file /tmp/nwb-large.env --port 3001
```

Der große Betreiber hat 50 Anlagen; Verwaltung ist 25 davon zugeordnet.
Nicht einfach DEMO_SIZE innerhalb eines bestehenden Betreiber-Datenbestands ändern.
Seeds sind für eine ausgewählte Testinstallation wiederholbar, kein Importwerkzeug.

## Prüfungen

```sh
docker compose exec -T -e RAILS_ENV=test web bin/rails db:prepare
docker compose exec -T -e RAILS_ENV=test web bin/rails test
docker compose exec -T web bin/rails zeitwerk:check
docker compose exec -T web bundle exec rubocop
docker compose exec -T web bundle exec brakeman --no-pager
docker compose exec -T web bundle exec bundler-audit check --update
python3 scripts/smoke.py
# Optional: Python Playwright und /usr/bin/chromium installiert
python3 scripts/browser_smoke.py
```

Integrationstests verwenden ausschließlich nwb_test, getrennt von Demodaten.
CSRF ist nur für Rails-Testrequests deaktiviert; der HTTP-Smoke-Test prüft den
aktiven Schutz im Entwicklungsserver. Die CI führt Build, Start, Tests und
Sicherheitsprüfungen aus; Branchschutz muss separat eingerichtet werden.

## Echter Joomla-Vertragstest

Siehe [API-Referenz](docs/API_REFERENCE.md). Die vorhandene Joomla-Testsuite auf
einer externen synthetischen Kopie des festgehaltenen Commits einrichten und
`test_nahwaerme_api.py --fresh` laufen lassen. Referenzrepository nicht verändern.
Der explizite Rails-Vertragstest läuft im Netzwerk-Namespace dieses synthetischen
Joomla-Containers; vertrauenswürdiges Testzertifikat und Fixture-Token werden nur
als schreibgeschütztes Verzeichnis `/fixture` eingehängt:

```sh
docker run --rm --network container:nwb-api-joomla-1 --tmpfs /app/log \
  --mount type=bind,src="$PWD",dst=/app,readonly \
  --mount type=bind,src=/workspace/nwb-api-runtime,dst=/fixture,readonly \
  -e RAILS_ENV=test -e POSTGRES_PASSWORD=synthetic-unused \
  -e SECRET_KEY_BASE=synthetic-test-only-not-for-deployment \
  -e NWB_SYNTHETIC_PORTAL_TEST=1 -w /app nwbabrechnung-web \
  bundle exec ruby integration/portal_contract_test.rb
```

Der Test nutzt keine DB und keinen Produktivzugang. Fixture-Datei
`api-test-credentials.json` kommt aus der Joomla-eigenen synthetischen Testfixture;
keine Tokens ausgeben. Kein produktiver Portalclient oder Outbox ist implementiert.

## Betrieb und Grenzen

`docker compose stop` und `docker compose up -d --wait` erhalten Daten. Keine
Volumes löschen oder Datenbanken zurücksetzen. Vor produktiven Migrationen
Backup/Restore und Auswirkungen prüfen. Prozesse überleben Cloud-Snapshots nicht;
Dienste bei Bedarf mit obigem Startbefehl starten. Keine Veröffentlichung durch
Setup, Serverstart oder Git-Push. Die Compose-Konfiguration ist für Entwicklung,
nicht für ungeprüften Produktivbetrieb.

Anmeldung: bcrypt, CSRF, zwölfstündige widerrufbare Sitzungen, generische Fehler,
Rate-Limit pro IP im einzelnen Webprozess. Für mehrere Prozesse braucht der
Rate-Limiter einen geteilten Cache. Kein MFA, Mailversand oder Passwort-Reset.
Audit-Einträge schützen auf Modellebene vor Änderung; DB-Administratoren können
sie verändern. Keine Behauptung manipulationssicherer Archivierung oder DSGVO-Abnahme.

- [Architektur und Datenmodell](docs/ARCHITECTURE.md)
- [Entschiedene Regeln](docs/BILLING_RULES.md)
- [Offene kaufmännische Fragen](docs/OPEN_QUESTIONS.md)
- [Joomla-API und Referenzbelege](docs/API_REFERENCE.md)
- [Nächste Schritte](docs/ROADMAP.md)
- [Prüfergebnisse](docs/TEST_RESULTS.md)
- [Abgleich mit dem Originalauftrag](docs/REQUIREMENTS_CHECK.md)
- [Ursprünglicher Projektauftrag](docs/PROJECT_BRIEF.md)
- [Entwicklungsregeln](AGENTS.md)

## Farbthemes

Unter **Darstellung** stehen NWB Billenhausen, Smaragd, Ozean und Schiefer sowie Hell/Dunkel zur
Verfügung. Die Vorlagen orientieren sich an modernen Emerald-/Blue-/Slate-
Paletten; es wird keine zusätzliche Theme-Bibliothek geladen. Eine eigene
Akzentfarbe ist möglich. Schrift und Layout ändern sich dabei nicht. Die Auswahl
bleibt lokal in diesem Browser, auch bei Navigation und erneutem Öffnen. Sie wird
nicht mit Benutzerkonten oder anderen Geräten synchronisiert. Text auf Buttons
und Linkfarben werden für mindestens 4,5:1 Kontrast angepasst; dies ersetzt keine
vollständige Barrierefreiheitsabnahme.

Browser-Regression: `python3 scripts/theme_smoke.py` (Playwright/Chromium).

NWB Billenhausen ist die Standardvorlage mit Dunkelgrün, Gold und Weiß/Grün-Schwarz. Dunkelgrün `#2B421F` und Gold `#CEA449` stammen aus dem am 13.11.2026 gelesenen Homepage-Stylesheet.

Cloud-Dependency-Audit mit temporär eingehängtem vertrauenswürdigem CA-Bundle:

```sh
docker run --rm \
  --mount type=bind,src="$PWD",dst=/app,readonly \
  --mount type=bind,src=/etc/ssl/certs/ca-certificates.crt,dst=/run/ca.pem,readonly \
  -e SSL_CERT_FILE=/run/ca.pem -e GIT_SSL_CAINFO=/run/ca.pem \
  nwbabrechnung-web bundle exec bundler-audit check --update
```

Der verwendete Rails-Stand ist 8.1.4.1: ein Sicherheits-Patch gegenüber IFFs
8.1.4. Neue Advisories werden weiterhin durch den Audit geprüft.

GitHub-Verteilung und Test-Host: [GitHub-Image-Anleitung](docs/GITHUB_IMAGE.md).
Die [Image-Compose-Datei](compose.image.yaml) verwendet standardmäßig
`/opt/nwbabrechnung/postgres` als lokalen Datenbankpfad, ohne Quellcode-Mount.
Der manuelle Actions-Workflow lädt erst nach erfolgreichen Prüfungen nach GHCR.

Konkrete Dockhand-Einstellungen: [192.168.5.6:2601 und /opt/nwbabrechnung](docs/DOCKHAND.md).

## Herkunft dieser Arbeitskopie

Dieser Stand wurde aus einem Chat-Export rekonstruiert. Ergänzte Programmfragmente,
fehlende Originaldateien und die erneute Dependency-Auflösung sind in
[RECOVERY.md](docs/RECOVERY.md) dokumentiert. Nur die neuen Ergebnisse in
[TEST_RESULTS.md](docs/TEST_RESULTS.md) gelten als Prüfbeleg dieser Arbeitskopie.

Direkter Build auf dem Testserver ohne GHCR: Im Dockhand-Git-Stack
`compose.build.yaml` auswählen; Details in [DOCKHAND.md](docs/DOCKHAND.md).

## Stammdatenverwaltung (Entwicklungsauftrag 02)

Nach Auswahl einer berechtigten Anlage führen **Kunden**, **Anschlüsse**,
**Zähler**, **Verträge** und **Trassen** zu den neuen Bereichen. Kunden lassen sich
suchen, nach Aktivstatus filtern und bearbeiten. Bereits sichtbare Kunden können
weiteren berechtigten Anlagen zugeordnet werden, ohne ihre Kontaktstammdaten zu
kopieren. Kundennummer und Zahlungsangaben gelten für die jeweilige Anlage.

Verträge bilden die Kundenzuordnung im Zeitverlauf ab. Zähler werden mit Anfangswert
angelegt. Für einen Wechsel auf der Zählerdetailseite **Zähler wechseln** wählen:
Schluss- und Anfangswert werden gemeinsam gespeichert. **Ablesung korrigieren**
erhält den alten Wert und verlangt eine Begründung. Keine Löschfunktionen,
Tarifberechnung oder Jahresabrechnung.

Entscheidungen und Grenzen: [Stammdatenarchitektur](docs/MASTER_DATA_DESIGN.md).
Originalauftrag: [BRIEF_02.md](docs/BRIEF_02.md).
Neue automatisierte Browserprüfung (legt nur neue, eindeutig benannte synthetische
Datensätze an; bestehende Testdatensätze werden nicht gelöscht):

```sh
python3 scripts/master_data_smoke.py
python3 scripts/master_data_smoke.py --env-file /workspace/nwb-large.env --port 3001
```

### Dockhand aktualisieren

Im bestehenden Git-Stack Branch `main` aktualisieren und `compose.build.yaml`
neu ausspielen/bauen. Stackname, Datenpfad und bestehende `.env`-Werte beibehalten.
Der vorhandene Startbefehl `db:prepare` führt die additive Stammdatenmigration aus.
Die Standardextension `btree_gist` wird für konkurrierungssichere Zeitintervalle
benötigt und ist im verwendeten PostgreSQL-17-Image verfügbar. Nicht gleichzeitig
einen zweiten Datenbankcontainer am selben PostgreSQL-Verzeichnis starten.
Es braucht weder einen GHCR-Upload noch neue Geheimnisse. Kein Datenreset und
keine manuelle Ausführung der Seeds zum Aktualisieren erforderlich.

Aktuelle Umsetzung, Dateibereiche und Prüfergebnisse: [Auftrag 02](docs/STEP_02_RESULTS.md).

## Vertragsverwaltung als Desktop-Pilot

Die Vertragsverwaltung verwendet eine unabhängig scrollbare Vertragsliste und
rechts eine per Turbo aktualisierte Akte. Suche/Filter gelten serverseitig für
alle berechtigten Verträge; nachgeladen wird in begrenzten 30er-Schritten.
Prüfergebnisse, Screenshots und bewusste Abgrenzungen: [Pilot-Review](docs/ui-contracts/REVIEW.md).
Die freigegebene Fortsetzung ergänzt die Anlagenübersicht, Anlagen-Stammdatenbearbeitung
und gemeinsame Live-Suche in sämtlichen bestehenden Suchleisten. Details und
Screenshots: [Anlagen und Live-Suche](docs/ui-plants/REVIEW.md).
Die bestehende Vertragserstellung und sonstige Fachlogik bleiben erhalten.

## Anlagen und strukturierte Anschriften

Anlagen lassen sich direkt pro Zeile bearbeiten; Stammdaten, automatische
Kennzahlen und Trassen stehen im selben Arbeitsplatz. Trassen haben keine Suche.
Anlagen, Kunden und Hausanschlüsse verwenden getrennte Pflichtfelder für
Straße/Hausnummer, PLZ und Ort. Die einmalige Migration ersetzt wie beauftragt
bisherige Demoadressen durch Beispielwerte. Details, Tests und Screenshots:
[Anlagen-/Trassen-Review](docs/ui-plant-routes/REVIEW.md).
