# Dockhand-Test auf 192.168.5.6:2601

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
