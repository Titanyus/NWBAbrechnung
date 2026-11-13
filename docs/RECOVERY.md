# Wiederherstellung aus dem Chat-Export

Am 13.11.2026 im vorhandenen, zuvor leeren Checkout NWBAbrechnung rekonstruiert.
Quelle: vom Benutzer übergebener Chat-Export (274833 Bytes).
SHA-256: `a561868d1468347764e1ed68ff4f564abca5239f580f7d38fb8b5b8b3c8291c7`. Die Anwendung ist
keine bytegenaue Wiederherstellung einer gesicherten alten Arbeitskopie.

- Dateierzeugung und spätere Patches wurden in ihrer zeitlichen Reihenfolge übernommen.
- 15 Basisdateien stammen aus IFF f674dbad7a8894afd3cfccd2e598d15eab656e9f.
- Joomla-Referenz: NWBKunden 92d304f0c10f8cbc38ad50782c84f26bcba782ef.
- Redaktion im Export entfernte auch Programmfragmente: Passwortparameter im
  Login, ENV.fetch im Seed und JSON.parse/File.read im synthetischen Vertragstest
  wurden anhand des vorhandenen Ablaufs ergänzt. Testpasswörter sind neue,
  öffentliche synthetische Werte; Demo-/Sitzungs-/DB-Secrets werden lokal erzeugt.
- Das Originalbriefing wurde vom Benutzer nachgereicht und unverändert als
  PROJECT_BRIEF.md übernommen. REQUIREMENTS_CHECK.md gleicht den Code damit ab.
- Der abschließende alte Lockfile fehlt. Er wurde mit Rails 8.1.4.1 und den
  dokumentierten Prüfwerkzeugversionen neu aufgelöst und danach eingefroren.
- Frühere Testergebnisse wurden nicht übernommen. TEST_RESULTS.md dokumentiert
  ausschließlich die neue Prüfung. Alte private Konfigurationen, Datenbanken,
  Screenshots, Containerimages und Zugangsdaten wurden nicht wiederhergestellt.

GitHub-Ziel ist ausschließlich Titanyus/NWBAbrechnung. Kein Image-Publish und
kein Deployment gehören zu diesem Wiederherstellungsauftrag.
