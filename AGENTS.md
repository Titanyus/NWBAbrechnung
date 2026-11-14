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

## Verbindlicher Desktop-UI-Standard

Bei jeder UI-Entwicklung und jedem UI-Review zusätzlich `docs/UI_GUIDELINES.md`
und `.agents/skills/admin-ui/SKILL.md` lesen und anwenden. Gilt insbesondere für
neue/geänderte Verwaltungsseiten, Tabellen und Formulare. Zielplattform ist
Desktop **1280–2560 px**; vier Pflichtgrößen gemäß UI_GUIDELINES.md, keine Smartphone-Navigation. Kompakte semantische
Tabellen, zentrale Design-Tokens, logisch gruppierte Desktopformulare, sichtbare
Anlage, Tastaturbedienung und echte Vorher-/Nachher-Prüfungen sind verbindlich.
Die bestehenden fachlichen, Sicherheits- und Architekturregeln bleiben bestehen.

Jede neue UI-Funktion muss den zentralen UX-Styleguide berücksichtigen und sich
logisch in bestehende Arbeitsabläufe integrieren. Vor Implementierung den konkreten
kaufmännischen Ablauf kurz erläutern. Anlagen und Verträge sind Hauptbereiche;
Trassen gehören zur Anlage, tägliche Kunden-/Anschluss-/Zählerarbeit in die Akte.
Der neueste UI_REBUILD_BRIEF.md und UI_REBUILD_PLAN.md haben Vorrang vor älteren
Layoutvorgaben. Berechtigungs- und Datenintegritätsregeln bleiben verbindlich.

Neue Suchen verwenden die gemeinsame serverseitige Turbo-Live-Suche über
`ui_search_data`: Text 300 ms, Auswahl sofort, alte Antworten abbrechen/verwerfen,
Fokus und unabhängige Formulare erhalten. Gemeinsame UI-Bausteine statt einzelner
Feld-/Button-/Rahmenvarianten. Farben ausschließlich aus vorhandenen Theme-Tokens.

Anschriften bei Anlagen, Kunden und Hausanschlüssen immer als getrennte Pflichtfelder
Straße/Hausnummer, PLZ und Ort über `shared/address_fields` erfassen. Gemeinsame
Validierung `StructuredAddress`; PLZ als Text, vollständige Anschrift nur berechnet.
Trassen: integrierte Tabelle ohne Suche; Vertragskennzahlen zählen alle Statuswerte.
