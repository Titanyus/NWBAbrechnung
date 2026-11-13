# Neue Prüfungen der Rekonstruktion – 13.11.2026

Alle folgenden Ergebnisse wurden an der rekonstruierten Arbeitskopie erneut
ermittelt. Historische Testergebnisse aus dem Export sind kein Nachweis.
Nur synthetische Daten, lokale Docker-Stacks, linux/amd64.

| Prüfung | Neues Ergebnis |
|---|---|
| Docker-Build mit eingefrorenem Bundle | erfolgreich; vertrauenswürdiges CA-Bundle nur temporär gemountet; TLS-Prüfung aktiv |
| Laufende Versionen | Ruby 3.4.12, Rails 8.1.4.1; PostgreSQL 17 mit fixiertem Image-Digest |
| Rails-Tests im gebauten Anwendungscontainer | **20 Tests, 107 Assertions, 0 Fehler, 0 Fehlschläge, 0 Skips** |
| Zeitwerk | Eager Loading bestanden |
| RuboCop Omakase | 34 Ruby-Dateien, keine Verstöße; historische Formatierung erneut geprüft |
| Brakeman 8.1.0 | 0 Fehler, 0 Sicherheitswarnungen |
| bundler-audit 0.9.3 | keine bekannten Schwachstellen; ruby-advisory-db 305f8b079a23bf95d00c881842f366bb8db19f35, 1359 Advisories |
| Native Joomla-HTTPS-API-Suite | **11 Tests bestanden**; echtes separates Joomla 6.2.0/PHP 8.4 und MariaDB, unveränderter NWBKunden-Referenzstand |
| Rails → Joomla-Vertragstest | **1 Test, 13 Assertions, 0 Fehler, 0 Fehlschläge, 0 Skips**; TLS-verifizierter synthetischer Empfänger |
| HTTP-Smoke, kleine/große Installation | DB-Readiness, CSRF-Ablehnung, Login, lokale CSS-Assets, no-store und Logout bestanden |
| Chromium Desktop/Mobil | Hotwire aktiv, Anlagenwahl und Abmeldung bestanden; keine JS-Fehler, kein horizontaler Überlauf |
| Farbthemes | **40 Kombinationen** mit unabhängiger Kontrastreferenz ≥4,5:1; Speicherung, Navigation, Reset und ungültiger Local Storage bestanden |
| Zwei getrennte Installationen | 3 bzw. 50 Anlagen; Verwaltung sieht 25 der großen Installation; kleine Adminsitzung bleibt beim An-/Abmelden im großen Stack gültig |
| Seed-/Datenintegrität | Rails-Tests prüfen kleine Rechte 3/2, große Rechte 50/25, Wiederholbarkeit, Passworterhalt, UUIDs, Fremdschlüssel, Eindeutigkeit und atomare Erstellung |
| Normaler Start | kein automatisches Demo-Opt-in; Test bestätigt keine Demoanlage ohne NWB_LOAD_DEMO=1 |
| Neustart | regulärer Webcontainer-Neustart, anschließend Healthcheck und vollständiger HTTP-Smoke bestanden |
| Image ohne Quellcode-Mount | separater lokaler Stack mit PostgreSQL-Bind-Mount, Port 2601, Demo-Opt-in und HTTP-Smoke bestanden |
| Private Konfiguration | gebackenes Image enthält keine /app/.env; private lokale Konfigurationen werden von Git ignoriert |
| Hostschutz des Image-Stacks | konfigurierter Host akzeptiert, fremder Host mit 403 abgewiesen |
| Compose / Workflows | Entwicklungs- und Image-Compose validiert; beide Workflow-YAMLs geparst; Image-Publish nur workflow_dispatch |
| Originalauftrag | unverändert in PROJECT_BRIEF.md übernommen; zwölf Anforderungen des ersten Auftrags in REQUIREMENTS_CHECK.md abgeglichen |

## Nachvollziehbarkeit und Grenzen

Reproduzierbare Befehle: README.md. Herkunft/ergänzte Stellen: RECOVERY.md.
Die Rails-Tests wurden zunächst auch im Werkzeugimage und anschließend im
fertig gebauten Anwendungscontainer erfolgreich ausgeführt. Der finale Lockfile
wurde neu aufgelöst; ein byteidentischer alter Lockfile lag nicht vor.

Die Joomla-Suite lief mit --fresh: der historische Upgradepfad von 0.3.3 wurde
bewusst nicht ausgeführt. Der Rails-Vertragstest prüft einen leeren inaktiven
synthetischen Kundenbestand; PDF-/Rechte-/Replay-/Rollback-Fälle deckt zusätzlich
die native Joomla-Suite ab. Keine Produktivzugänge oder Produktivdaten verwendet.

Kein GHCR-Upload, kein externer Dockhand-Deploy und keine Veröffentlichung der
Cloud-Umgebung. Das lokale Image ist kein Nachweis eines vorhandenen GHCR-Tags.
Der GitHub-Push dient der Quellcodesicherung; Ergebnisse der danach automatisch
startenden GitHub-CI sind durch diese lokalen Tests nicht vorweggenommen.
Installations- und Startanweisungen wurden als Umgebungsentwurf gespeichert;
Wiederherstellung in einer neuen Aufgabe ist damit noch nicht unabhängig geprüft.

Kunden-/Vertrags-/Tarif-/Zählerverwaltung, Finanzberechnungen, ZUGFeRD und Outbox
sind spätere Module und nicht implementiert. Keine Excel-Referenzabrechnungen,
Produktivhärtung, MFA, Passwort-Reset, Backup-/Restore- oder Datenschutzabnahme.
ARM64 wurde nicht getestet. Diese Grenzen entsprechen dem begrenzten ersten
Auftrag; offene Fachregeln stehen in OPEN_QUESTIONS.md.
