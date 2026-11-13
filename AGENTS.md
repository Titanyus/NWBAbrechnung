# NWB Verwaltung – Entwicklungsregeln

Lies `.agents/skills/nwb-verwaltung/SKILL.md` und die einschlägigen Dokumente vor Änderungen.
Priorität: fachliche Korrektheit, Datenschutz/Sicherheit, Bedienbarkeit, Wartbarkeit.
Ein Betreiber je Installation; modularer Rails-Monolith mit Hotwire/PostgreSQL.
Keine echten Daten, Geheimnisse, externe Telemetrie oder CDN-Abhängigkeiten.
Serverseitig immer über die Anlagenrechte des aktuellen Benutzers filtern;
auch Administratoren brauchen explizite Zuordnungen. Negative Zugriffstests sind Pflicht.
Architektur-, Sicherheits- und Datenmodelländerungen vor Implementierung mit Auswirkungen dokumentieren.
Keine destruktiven Migrationen ohne Freigabe; keine historischen Originale löschen.
Keine freigegebenen Rechnungen überschreiben, keine Produktivimporte/-veröffentlichungen.
Geld mit Decimal; keine Geschäfts-, Steuer- oder Rundungsregel erfinden.
Jede Berechnung braucht fachliche Referenztests anhand freigegebener anonymisierter Beispiele.
NWBKunden ist nur lesende API-Referenz; tatsächlichen Vertrag prüfen, keine neue API erfinden.
Kleine Schritte, Tests tatsächlich ausführen; Fehler und ungetestete Teile benennen.
Docker-, Rails-, RuboCop-, Brakeman- und Dependency-Prüfungen nach README ausführen.
Vorhandenen Checkout nutzen: jede Cloud-Aufgabe ist bereits isoliert, keine zusätzlichen Worktrees ohne Auftrag.
