# Testen über GitHub

Die Dateien müssen zunächst im GitHub-Repository vorliegen. Von der lokalen
Implementierung wurde kein Push, Actions-Lauf oder Upload ausgelöst.

1. Unter Actions den Workflow **Docker image to GitHub** manuell starten.
2. Er führt den wiederverwendbaren Foundation-Workflow aus: Docker-Build/Start,
   Rails-Tests, RuboCop, Brakeman, Dependency-Audit und HTTP-Smoke.
3. Nur nach Erfolg baut er ein linux/amd64-Image und lädt es in die GitHub
   Container Registry des Repositories. Kein Docker Hub und kein Fremd-Registry.
4. Der Lauf liefert in seiner Zusammenfassung eine genaue `ghcr.io/...@sha256:...`
   Referenz. Diese in `.env` als NWB_IMAGE setzen. Der Commit-SHA wird zusätzlich
   als Tag veröffentlicht. Die Registry-Sichtbarkeit wird in GitHub verwaltet;
   keine automatische öffentliche Freigabe durch diesen Workflow.

Der GitHub-eigene GITHUB_TOKEN erhält nur im Upload-Job `packages: write`.
Keine persönlichen Tokens oder Produktiv-Secrets im Workflow hinterlegen.
Bei privaten Paketen muss der ausführende Docker-Host zum Lesen von GHCR
berechtigt sein; Anmeldung außerhalb von Compose verwalten, keine Tokens in YAML.
ARM64 ist noch nicht gebaut/getestet, daher keine ARM64-Kompatibilität behaupten.

## Image starten

Das gewünschte Basisverzeichnis auf dem Docker-Host ist `/opt/nwbabrechnung`.
`compose.image.yaml` als `/opt/nwbabrechnung/compose.yaml` und `bin/dev-env` als
`/opt/nwbabrechnung/dev-env` ablegen. Die Datenbank liegt als Bind-Mount unter
`/opt/nwbabrechnung/postgres`. `.env` liegt daneben mit Dateimodus 0600.
Keine pauschalen Rechte wie chmod 777 vergeben; das offizielle PostgreSQL-Image
initialisiert sein neues Datenverzeichnis mit passenden Rechten. Vorhandene
DB-Verzeichnisse und Dateieigentümer niemals blind ersetzen.

Nach erfolgreichem Image-Upload auf dem Docker-Host:

```sh
cd /opt/nwbabrechnung
python3 dev-env
# In .env NWB_IMAGE=<genaue Referenz aus Actions> ergänzen.
docker compose up -d --wait
docker compose exec -T -e NWB_LOAD_DEMO=1 web bin/rails db:seed
```

Anmeldung gemäß NWB_HOST/NWB_PORT über Port 2601 mit `admin@example.test` und dem
lokalen DEMO_PASSWORD. Die kleine Installation enthält drei Anlagen. Eine neue,
getrennte Installation mit DEMO_SIZE=large enthält 50; eigene Konfiguration,
Cookie-Kennung, Port und Compose-Projektname verwenden. Für ein zweites Image-Projekt
auch NWB_DATA_DIR auf ein eigenes Verzeichnis setzen, damit zwei PostgreSQL-Server
niemals dieselben Dateien öffnen.

Das Image benötigt keinen Quellcode-Mount. Im Repository gibt es daneben
`compose.yaml` zum lokalen Entwickeln und Bauen. Die Image-Variante nutzt den gewünschten lokalen Bind-Mount, die Entwicklungsvariante ein Docker-Volume; keine Volumes zum Neustarten löschen. Es handelt sich um
synthetische Entwicklungstests, nicht um einen freigegebenen Produktivbetrieb.

## Verzeichnisrechte

Basisordner für den lokalen Deployment-Benutzer anlegen:

```sh
sudo mkdir -p /opt/nwbabrechnung
sudo chown "$USER:$(id -gn)" /opt/nwbabrechnung
chmod 750 /opt/nwbabrechnung
```

Das Hilfsskript erzeugt `.env` exklusiv mit Modus 0600. Das verwendete
PostgreSQL-17-Alpine-Image hat den Datenbankbenutzer UID/GID 70; der laufende
Referenzcontainer bestätigt Modus 0700 für sein Datenverzeichnis. Das Image
setzt Besitzer und Rechte bei der Initialisierung selbst. Den Unterordner
`postgres` nicht mit chmod 777 öffnen und bestehende Daten nicht pauschal
rekursiv umberechtigen. Basisordner und PostgreSQL-Daten haben verschiedene
Besitzer; das ist beabsichtigt.

Für den konkreten Dockhand-Test sind 192.168.5.6 und Port 2601 voreingestellt; siehe [Dockhand](DOCKHAND.md).
