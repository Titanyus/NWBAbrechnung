# Dockhand-Test auf 192.168.5.6:2601

## Direkt auf dem Testserver bauen (ohne GHCR)

Den vorhandenen Git-Stack in Dockhand bearbeiten:

- Repository: `https://github.com/Titanyus/NWBAbrechnung.git`
- Branch: `main`
- Compose-Datei: `compose.build.yaml`
- Vollständiger Git-Checkout erforderlich: Build-Kontext ist das Repository mit
  Dockerfile, Gemfile.lock und Anwendung. Nur die YAML einzufügen genügt nicht.

Git-Stand aktualisieren und den Stack neu bereitstellen. Die Compose-Datei setzt
`pull_policy: build`: Compose baut das Anwendungsimage lokal und startet es ohne
Quellcode-Mount. Dafür ist weder der GitHub-Image-Workflow noch ein GHCR-Zugang
nötig. Der Server benötigt Docker Compose V2/BuildKit und Zugang zu Docker Hub,
Debian-Paketquellen und RubyGems. GHCR-Zugangsdaten werden nicht verwendet.

Die bereits hinterlegten Umgebungsvariablen weiterverwenden. `NWB_IMAGE` wird bei
lokalem Build nicht benötigt und kann entfallen. Bei einem bestehenden Stack
insbesondere POSTGRES_PASSWORD, SECRET_KEY_BASE, SESSION_COOKIE_KEY, Stackname
und NWB_DATA_DIR beibehalten. Nicht gleichzeitig einen zweiten Stack mit demselben
PostgreSQL-Datenpfad starten und keine Datenverzeichnisse löschen.

Alternativ im Git-Checkout auf dem Testserver, mit der bestehenden privaten .env:

```sh
git pull --ff-only
docker compose -p nwbabrechnung -f compose.build.yaml up -d --build --wait
```

`-p nwbabrechnung` muss dem tatsächlich verwendeten Stacknamen entsprechen.
Anschließend wie unten unter `http://192.168.5.6:2601` anmelden. Das lokale Image
wird nicht in eine Registry hochgeladen. Ein tatsächlicher Dockhand-Deploy wurde
hier nicht ausgeführt; der Build und Start werden in der Cloud lokal geprüft.

## Alternative: fertiges GHCR-Image verwenden

Compose: `compose.image.yaml`, ohne Quellcode-Mount und ohne Build auf Dockhand.
Image: `ghcr.io/titanyus/nwbabrechnung:main` nach erfolgreichem manuellem Workflow
**Docker image to GitHub** auf Branch main. Der Workflow prüft erst vollständig
und veröffentlicht dann SHA-Tag, main-Tag und Digest. Bis dahin ist der Tag keine
Behauptung eines bereits vorhandenen Images. Private GHCR-Pakete benötigen einen
zum Lesen berechtigten Registry-Zugang in Dockhand; Zugangsdaten nicht in YAML.

In Dockhand einen Compose-Stack anlegen und die YAML sowie die zugehörigen
.env-Variablen übernehmen. Die persönlich erzeugte `.env` liegt außerhalb Git und
enthält neue Zufallswerte; nicht ins Repository übernehmen. `.env.example` ist
nur eine Vorlage mit leeren Geheimnisfeldern. Ein konkreter Dockhand-Deploy wurde
nicht ausgeführt, da kein Zugriff auf den Docker-Host besteht.

Konfiguration:

- Browser: http://192.168.5.6:2601
- NWB_PORT=2601 (vorläufiger Testport).
- NWB_HOST=192.168.5.6; Rails akzeptiert diesen Host explizit.
- NWB_BIND_ADDRESS=0.0.0.0; der Webport wird auf dem Docker-Host veröffentlicht.
- NWB_DATA_DIR=/opt/nwbabrechnung; DB-Bind-Mount darunter in `postgres`.
- NWB_LOAD_DEMO=1 legt beim Start ausdrücklich synthetische Testdaten an.
- DEMO_SIZE=small: 3 Anlagen, Verwaltung sieht 2. Für einen getrennten großen
  Teststack DEMO_SIZE=large, eigener Datenpfad, Cookie-Name, Projektname und Port.
- Anmeldung: admin@example.test oder verwaltung@example.test, Passwort aus
  DEMO_PASSWORD. Bestehende Benutzerpasswörter bleiben beim Neustart erhalten.

Der Pfad gilt auf dem Docker-Host, nicht innerhalb des Dockhand-Containers.
Basisordner 0750 für den Deployment-Benutzer, `.env` 0600. PostgreSQL initialisiert
seinen Unterordner selbst als UID/GID 70 mit 0700. Kein chmod 777, keine pauschalen
rekursiven Besitzeränderungen. Bei Änderungen am Datenbankpasswort ein geregeltes
DB-Passwortverfahren verwenden; bloßes Ändern der Variable ändert kein bestehendes
PostgreSQL-Passwort. Keine Volumes oder Daten zum Neustart löschen.

Für Updates kann statt main eine konkrete Digest-Referenz aus der Actions-
Zusammenfassung als NWB_IMAGE verwendet werden. Das ist reproduzierbar; main ist
bewusst ein beweglicher Test-Tag. Der Stack dient der synthetischen Erprobung,
noch keinem freigegebenen Produktivbetrieb.

## Aktualisierung auf Stammdatenverwaltung (Auftrag 02)

Branch `main` im bestehenden Git-Stack aktualisieren, `compose.build.yaml`
beibehalten und neu bauen/ausspielen. `db:prepare` legt beim Start die neuen
Tabellen, Fremdschlüssel und Intervall-Constraints additiv an. Die vorhandenen
Benutzer, Anlagen, Berechtigungen und IDs bleiben erhalten. Dieselbe private
Konfiguration und denselben Datenpfad verwenden; keine Volumes/Datenbanken
löschen und kein neues Passwort für eine bestehende Datenbank einsetzen.
Danach eine Anlage auswählen: Kunden, Anschlüsse, Zähler, Verträge und Trassen
stehen dort bereit. Kein Image-Publish und keine zusätzlichen Secrets nötig.
