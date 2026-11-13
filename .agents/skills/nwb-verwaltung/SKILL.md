---
name: nwb-verwaltung
description: Entwicklung der NWB Nahwärme-Verwaltung mit Rails, Anlagenrechten und verbindlichem Joomla-Vertrag.
---

1. AGENTS.md, docs/ARCHITECTURE.md, docs/BILLING_RULES.md und docs/API_REFERENCE.md lesen.
2. Git-Stand prüfen. Nur beauftragtes Modul ändern; Auswirkungen vor wesentlichen Änderungen dokumentieren.
3. In vorhandenem Checkout arbeiten, keine Worktrees ohne ausdrücklichen Auftrag.
4. Controller scopen über current_user.plants; Rechte nie aus Formularparametern beziehen.
5. Migrationen mit DB-Constraints, Transaktionen und negativen Tests ergänzen.
6. Keine Berechnungsannahmen: offene Regeln in docs/OPEN_QUESTIONS.md festhalten.
7. Portalcode erst nach Prüfung des versionierten NWBKunden-Quellstands; kein Versand ohne Freigabe.
8. README-Testbefehle ausführen und tatsächliche Ergebnisse mit Einschränkungen dokumentieren.
