# Verbindliche Joomla-API-Referenz

Quelle: https://github.com/Titanyus/NWBKunden, Commit
`92d304f0c10f8cbc38ad50782c84f26bcba782ef`, com_nahwaerme 0.4.1,
HTTP-Vertrag 1.0.0. Keine neue API in NWB Verwaltung.

Gelesen: AGENTS, README, PROJECT_STATUS, docs/v0.4/README,
api-vertrag, openapi.json, sicherheit, betrieb und alle examples.
Abgeglichen mit `admin/webservices/src/Extension/Nahwaerme.php`,
`api/src/Controller/SnapshotsController.php`, `Domain/SnapshotPayload.php`,
`Infrastructure/SnapshotReceiver.php` sowie nativen API-Testfixtures.
Die Routen und Kernsemantik stimmen mit dem Vertrag überein. Präzisierungen:
Der Controller verlangt bei Manifest/PDF den exakten Content-Type ohne Charset;
Commit verlangt wirklich null Bodybytes. Native Auth-/Routerfehler können vom
komponenteneigenen Fehlerformat abweichen. Das OpenAPI-Schema allein prüft nicht
alle Summenlimits, Eindeutigkeiten, Revisionen oder JSON-Schlüsselduplikate.

Basis: HTTPS `/api/index.php/v1/nahwaerme` mit nativem Bearer-Token;
Accept `application/vnd.api+json`. Kein Redirect mit Zugangsdaten, kein Browserzugriff.

| Operation | Vertrag |
|---|---|
| POST /snapshots | JSON:API-Vollbestand, Idempotency-Key = data.id; 201/identisches Replay 200 |
| GET /snapshots/{batch} | Status und fehlende Dokument-IDs; fremd/unbekannt 404 |
| PUT /snapshots/{batch}/documents/{document} | unveränderte PDF-Bytes, SHA256 und Länge |
| POST /snapshots/{batch}/commit | leerer Body; atomarer Austausch genau eines Kundenbereichs |
| DELETE /snapshots/{batch} | nur Vorbereitung abbrechen, kein Rückzug veröffentlichter Daten |

Quelle/Anlage/Kunde und Dokument/Anschluss tragen stabile kanonische UUIDs.
Revision ist ein positiver Integerstring ≤ 9223372036854775807 je Kundenbereich.
Outbox muss exakte UTF-8-Bodybytes dauerhaft einfrieren; Zustellung je Portalziel
getrennt. Historische Erfolgsbelege werden niemals neu angewandt. Rückzug durch
höheren Vollbestand mit serving=false und sites=[]. Joomla-Konten nicht löschen.

2 MiB Manifest, 50 Stellen, 1000 Jahreswerte, 200 Dokumente, 20 MiB/PDF,
100 MiB neue PDF-Bytes/Bestand; 24h Vorbereitung, 30 Requests/min/Zugang,
Stagingquoten und Retry-After beachten. Unbekannte Felder/duplizierte Schlüssel
werden abgewiesen. Explizite native Kundenzuordnung bleibt erforderlich.

## Frühe Vertragsprüfung

`integration/portal_contract_test.rb` ist ein ausdrücklich gestarteter synthetischer
Rails-Test gegen eine getrennte echte Joomla-Installation. Er ist kein produktiver
HTTP-Client, keine Outbox und kein Versandweg für Rechnungen. Testzugänge und CA
liegen außerhalb Git; niemals einen produktiven Portalzugang dafür benutzen.
Der Test verwendet absichtlich einen leeren inaktiven Kundenbestand und prüft
Prepare, Status, Commit, identisches Replay, Konflikt und monotone Revision.
Die umfassende Joomla-eigene Suite ergänzt PDF-/Rechte-/Rollback-Prüfungen.

Vor einem späteren konfigurierbaren Client: HTTPS, keine Redirects, DNS-/IP-Prüfung
gegen private/Loopback/Link-local/Metadatennetze einschließlich Rebinding, explizite
Zielhostfreigaben, Timeouts und Bodylimits. Test-Loopbackfreigabe darf nicht in
Produktcode übernommen werden. Ohne diese Schutzmaßnahmen keine Portalverbindungen.
