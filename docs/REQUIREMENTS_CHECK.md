# Abgleich mit dem ursprünglichen Projektauftrag

> Dieser Abgleich beschreibt den Grundaufbau vor Entwicklungsauftrag 02
> (b95aea4). Die danach implementierten Stammdaten und aktuellen Prüfungen stehen
> in [STEP_02_RESULTS.md](STEP_02_RESULTS.md). Die damalige Liste offener Module
> ist keine Behauptung über den heutigen Implementierungsstand.


Stand: 13.11.2026. Grundlage ist das nachgereichte Original in PROJECT_BRIEF.md.
Dieser Abgleich bewertet den rekonstruierten Code, nicht die frühere Arbeitskopie.
Laufzeitergebnisse stehen ausschließlich in TEST_RESULTS.md.

## Umfang

Abschnitt 14 begrenzt den ersten Auftrag ausdrücklich auf den funktionsfähigen
Grundaufbau. Die Abschnitte 3–13 beschreiben daneben das spätere Gesamtprodukt.
Fehlende Abrechnungs- und Kundenmodule sind daher kein Anlass, sie ungefragt bei
der Wiederherstellung zu implementieren.

## Erster Entwicklungsauftrag: zwölf Anforderungen

| Nr. | Anforderung | Umsetzung im Code / Dokumentation |
|---|---|---|
| 1 | AGENTS.md | Vorhanden; Sicherheit, explizite Anlagenrechte, keine erfundenen Berechnungsregeln, kleine Schritte und echte Prüfungen. |
| 2 | Projektskill | `.agents/skills/nwb-verwaltung/SKILL.md` vorhanden. |
| 3 | Architektur und fachliches Datenmodell | `docs/ARCHITECTURE.md`: modularer Monolith, implementierte Tabellen und Beziehungen, künftige Fachobjekte getrennt beschrieben. Das zukünftige Modell ist ein Entwurf, keine fertige Finanzdatenbank. |
| 4 | Verbindliche API-Referenz | `docs/API_REFERENCE.md` mit exaktem NWBKunden-Commit; `integration/portal_contract_test.rb` prüft einen echten synthetischen Empfänger. |
| 5 | Entschiedene Abrechnungsregeln | `docs/BILLING_RULES.md`, einschließlich Zwischenablesung, keiner Verbrauchsschätzung und Trennung von geplanten Abschlägen/Zahlungen. Noch keine Berechnung implementiert. |
| 6 | Offene kaufmännische Entscheidungen | `docs/OPEN_QUESTIONS.md`: u. a. Steuer, Rundung, Stichtage, Zeitanteile, Freigaben und Excel-Referenzfälle. |
| 7 | Docker-Compose-Entwicklungsumgebung | `Dockerfile`, eingefrorener `Gemfile.lock`, `compose.yaml`, optionale CA-Konfiguration für den Cloud-Proxy. |
| 8 | Rails/Hotwire/PostgreSQL | Rails 8.1.4.1, Ruby-Image mit Digest, PostgreSQL 17 mit Digest; Turbo/Stimulus/Importmap und serverseitige Views. Keine SPA oder Microservices. |
| 9 | Anmeldung und Anlagenberechtigungen | bcrypt, CSRF, widerrufbare zwölfstündige Sitzungen, Rate-Limit; Lesen stets über `current_user.plants`. Auch Administratoren benötigen explizite Zuordnungen. |
| 10 | Anlagen anlegen/auswählen | Liste, Detail, Neuanlage; Name, Anschrift und technische Hinweise. Erstellung, eigene Freigabe und Audit-Eintrag in einer Transaktion. |
| 11 | Getrennte kleine/große Testinstallation | Seeds mit ausdrücklichem Opt-in für 3 bzw. 50 Anlagen; getrennte Compose-Projekte, Volumes, Passwörter, Ports und Sitzungs-Cookies. |
| 12 | Automatisierte Prüfungen | Rails-Zugriffs-/Integritäts-/Seed-Tests, HTTP-Smoke mit DB-Readiness/CSRF/Login/Assets/Logout; CI startet den Docker-Stack. Zusätzliche Browser-, Kontrast- und Installationstests vorhanden. |

Die im Auftrag erwartete Planung der nächsten kleinen Entwicklungsschritte steht
in `docs/ROADMAP.md`. Empfohlen ist Kunden-/Anschlussverwaltung mit datierten
Verträgen und negativen Zugriffstests, noch keine Geldberechnung.

## Gesamtprodukt: ausdrücklich noch nicht umgesetzt

- Trassen, Kunden, Anschlüsse, Verträge, Zähler, Ablesungen und ihre historischen Wechsel.
- Tarifversionen, Sonderkonditionen, Rabatte und Freigabesprüfungen bei fehlender Zwischenablesung.
- Jahresabrechnung, Abschlagspläne, Zahlungseingänge, Guthaben und Korrekturen.
- Sammelvergünstigungen mit Vorschau und getrennte Entschädigungs-/Rückzahlungsvorgänge.
- ZUGFeRD-/Factur-X-Erzeugung, unabhängige EN-16931-/XML- und PDF/A-3-Validierung.
- Konfigurierbare Portalverbindungen, verschlüsselte API-Zugänge, dauerhafte Outbox,
  SSRF-geschützter Produktivclient und Zustellbelege pro Portalziel.
- Ein späterer Export an ausgewählte Banksoftware. Keine direkte Bankanbindung vorhanden.

Diese Funktionen sind geplant/dokumentiert und werden nicht als vorhanden oder
getestet dargestellt. Anonymisierte Excel-Referenzen und kaufmännische Freigaben
liegen weiterhin nicht vor.

## Konkrete Grenzen des Grundaufbaus

- Der Betreiber ist durch CHECK/UNIQUE auf höchstens einen DB-Datensatz begrenzt;
  die Ersteinrichtung legt ihn an. Eine leere Installation hat zunächst keinen.
- Benutzeranlage und explizite Freigaben erfolgen über Rails-Konsole; keine
  Benutzerverwaltungsoberfläche, kein Passwort-Reset und kein MFA.
- Das Audit schützt Einträge auf Modellebene, nicht gegen DB-Administratoren.
  Es existieren noch keine finanziellen Vorgänge, die protokolliert werden könnten.
- Rate-Limit-Cache ist pro Webprozess; Skalierung benötigt einen gemeinsamen Cache.
- Der Compose-Stack ist für synthetische Entwicklung/Erprobung. Produktivhärtung,
  TLS-Betrieb, Backup/Restore und Datenschutz-/Aufbewahrungsabnahme bleiben offen.
- Die Farbtheme-Einstellungen und Image-/Dockhand-Vorlagen stammen aus späteren
  Aufträgen im Export. Sie erweitern den Grundaufbau ohne zusätzliche Fachmodule.

## Rekonstruktionsabweichungen

Siehe RECOVERY.md: vom Export entfernte Programmfragmente wurden ergänzt,
synthetische Passwörter ersetzt und der fehlende finale Lockfile neu aufgelöst.
Das Originalbriefing ist jetzt vollständig vorhanden. Historische Erfolgsberichte
sind kein Nachweis für diesen Stand; neue Prüfergebnisse werden separat geführt.
