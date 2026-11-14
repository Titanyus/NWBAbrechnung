# Gemeinsame Abstände der Verwaltungsseiten

Referenz außen: Vertragsverwaltung. Referenz innen: Anlage anlegen.
Alle angemeldeten Verwaltungsseiten verwenden dieselbe bestehende Rails-/Hotwire-
Desktop-Hülle, denselben Seitenkopf und zentrale CSS-Tokens. Die Anmeldung bleibt
separat. Sekundäre Navigation und Statusmeldungen folgen dem Seitentitel.

| Bereich | Maß |
|---|---|
| Inhalt oben/unten | 12 px |
| Inhalt links/rechts | 16 px |
| Seitenkopf | mindestens 36 px, danach 8 px |
| Kästen und eingerahmte Formulargruppen innen | 16 px |
| Zwischen Abschnitten | 16 px |
| Formularraster, beide Achsen | 12 px |
| Aktionsgruppen | 12 px |

Rahmenlose Gruppen erzeugen keine doppelten Innenabstände. Tabellenzellen und
zweizeilige Vertragslisten bleiben für ihren Zweck kompakt (Zeilen 40/52 px).
Ablesung und Zählerwechsel verwenden nun auch außerhalb der Akte dieselben
Formularpartials. Keine neuen Farben, Fachregeln, Rechte oder Migrationen.

## Nachweise

- `scripts/layout_spacing_smoke.py`: 22 Seiten × vier Desktopgrößen = 88 Prüfungen;
  tatsächliche Inhalts-/Titelpositionen, Innenabstände, Formularraster, horizontaler
  Überlauf und JavaScriptfehler. Erfolgsnachricht nach Anlagenspeicherung verschiebt
  den Titel nicht. Messwerte in `metrics.json`, Bilder in `screenshots/`.
- Vorher-Bilder in `before/` aus dem zuvor gebauten Stand fddddc2; Nachher-Vergleich
  mit denselben synthetischen Daten des isolierten Build-Stacks in `built-image/`.
- Vollständiger Stammdatenablauf: Kunde, Trasse, Anschluss, Vertrag, Zähler,
  Bearbeitung, Ablesung, Korrektur, atomarer Zählerwechsel und Suche erfolgreich.
- Vertragserstellung im rechten Frame: Filter, linkes DOM und Scrollposition
  erhalten; begrenzte Suche, Fehlerkorrektur und Wiederverwendung erfolgreich.
- 40 Theme-/Kontrastkombinationen inkl. Speicherung, Navigation und Reset geprüft.
- Rails: 101 Tests, 781 Assertions, keine Fehler; inklusive negativer Rechteprüfungen.
- RuboCop: 72 Dateien ohne Befund. Zeitwerk erfolgreich. Brakeman: keine Warnungen.
  Dependency-Audit: keine bekannten Schwachstellen im aktuellen Advisory-Stand.
- Docker-Neubau über `compose.build.yaml` mit Cloud-CA-Override erfolgreich;
  Web und Datenbank gesund. Kein externes Deployment und keine Image-Veröffentlichung.

Die Browserprüfungen ersetzen keine vollständige Barrierefreiheitsabnahme.
