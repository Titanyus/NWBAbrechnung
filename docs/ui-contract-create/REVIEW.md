# Vertragserstellung im bestehenden Arbeitsplatz

Stand: 14.11.2026. Basis: 9a00c46. Auftrag: `CONTRACT_CREATION_BRIEF.md`,
anschließend dunklerer Seitenhintergrund als Ergänzung.

## Ergebnis

„Vertrag anlegen“ öffnet rechts „Neuen Vertrag anlegen“. Links bleiben Liste,
Filter, Sortierung und Scrollbereich erhalten. Die direkte `/new`-Adresse öffnet
jetzt ebenfalls den vollständigen Arbeitsplatz statt der alten Vollseitenmaske.
Abbrechen kehrt zur zuvor ausgewählten Vertragsakte im selben Filterkontext zurück.

Vier gruppierte Bereiche: Kunde, Anschluss, Zähler und Vertragsdaten. Kunde und
Anschluss haben jeweils eine bewusste Auswahl „vorhanden“ oder „neu“; nur die
aktive Variante ist sichtbar und nimmt an der Formularvalidierung teil. Neue
Kunden und Hausanschlüsse verwenden dieselben Feldpartials und die getrennten
Pflichtfelder Straße/Hausnummer, PLZ und Ort wie ihre bisherige Bearbeitung.
Optionale Kundenzuordnungsdaten stehen in einer beschrifteten Aufklappgruppe.

Vorhandene Kunden werden über die Kundenzuordnungen der aktuellen Anlage gewählt,
Anschlüsse und Trassen ebenfalls ausschließlich aus dieser Anlage. Suchfelder
verwenden die vorhandene serverseitige Live-Suche und suchen über den gesamten
berechtigten Datenbestand. Pro Abfrage maximal 20 Treffer, ggf. zusätzlich die
bereits ausgewählte gültige ID. Name/Kundennummer/Anschrift bzw. Anschlussnummer/
Anschrift/Trasse sind suchbar. Es werden keine vollständigen großen Auswahllisten
vorab geladen. Suchformulare sind über native `form`-Attribute verbunden und
nicht unzulässig im Speicherformular verschachtelt.

Der Zählerbereich folgt dem gewählten Anschluss. Ein aktueller Zähler wird mit
Einbaudatum und letztem effektiven Stand angezeigt. Ohne aktuellen Zähler kann
optional ein neuer Zähler mit Einbaudatum, Einheit und belegtem Anfangsstand
angelegt werden. Ein neuer Anschluss kann auch zunächst ohne Zähler gespeichert
werden. Keine freie Zählerzuordnung zu Kunden, kein impliziter Zählerwechsel.
Beim Wechsel des Anschlusskontexts werden vorherige Einbau-Eingaben deaktiviert,
bis der passende Zählerbereich neu geladen ist.

Vertragsnummer bleibt entsprechend dem bestehenden Modell manuell gepflegt und
pflichtig. Aus dem rein visuellen Platzhalter im Referenzbild wurde keine neue
Nummerierungsregel abgeleitet. Vertragsintervalle bleiben einschließlich; die
kompakten Beschriftungen erläutern das gemeinsam unter den Vertragsfeldern.
Keine Tarife, Abrechnung oder API-Funktion ergänzt.

## Speicherung und Rückkehr

`Contracts::Draft` bündelt vorhandene Modelle und Dienste, ohne sie zu vermischen.
Kunde, Kundenzuordnung, Anschluss, optionaler Zähler/Anfangsablesung und Vertrag
inklusive Audit werden atomar in einer Transaktion gespeichert. Vorhandene Objekte
werden beim Wiederverwenden nicht mit neuen Formularfeldern überschrieben.
Auch spät auftretende Fehler beim Einbau/Anfangsstand rollen alles zurück.
Fehler, Modi und eingegebene Fachdaten bleiben im rechten Bereich erhalten.

Nach Erfolg öffnet sich rechts die neue Akte. Der Zähler der gefilterten Liste
wird aktualisiert, ohne die Liste neu zu laden. Ein passender neuer Datensatz im
ersten Ergebnisfenster wird einsortiert und markiert. Liegt er außerhalb der
aktuellen Filter oder des ersten Ladefensters, bleiben diese Grenzen bestehen;
die neue Akte ist dennoch rechts geöffnet. Kein erzwungenes Zurücksetzen der Suche.
Die vorhandene schrittweise Nachladung und Duplikaterkennung bleiben aktiv.
Turbo übernimmt Navigation und URL-Wechsel; keine neue Frontend-Architektur.

Die bisherige POST-Struktur wird für bestehende Aufrufer weiter unterstützt.
Der alte separate Formularweg ist aus der normalen Navigation entfernt. Auch
Validierungsfehler solcher älteren Aufrufer landen im neuen Arbeitskontext.
Gemeinsame Vertrags-/Zählerfelder wurden aus den bestehenden Formularen extrahiert;
Feldvalidierung und Rechte bleiben an einer Stelle. Anschlussfelder bekommen
eindeutige IDs, damit ihre Labels nicht auf den gleichnamigen globalen Filter zeigen.

## Seitenhintergrund

Helle Seitenflächen werden zentral in der vorhandenen Theme-Steuerung dunkler
abgeleitet: 92 % bestehende Surface-Farbe, 8 % bestehende Textfarbe. Kästen behalten
ihre weiße Surface-Farbe. Keine neue unabhängige Hex-Palette, kein Farbwert pro
Button oder Feld. Die vorhandene Link-/Fokus-Kontrastberechnung berücksichtigt
den neuen Seitenhintergrund und die weiße Oberfläche. Dunkelwerte bleiben erhalten.
Die Referenzanordnung wurde übernommen, nicht ein fremdes Farbschema.

## Tatsächlich ausgeführte Prüfungen

- **101 Rails-Tests, 781 Assertions**, ohne Fehler/Fehlschläge.
- Neue Tests: Frame-/Direktaufruf, vorhandene Daten unverändert wiederverwenden,
  alle Kombinationen neuer/vorhandener Kunden und Anschlüsse, Zähleranlage und
  exakter Anfangswert, ohne Zähler speichern, Wiederholung ohne Duplikate,
  Transaktionsrollback einschließlich Audit und Erhalt der Feldeingaben.
- Fremde Kundenzuordnungen, Anschlüsse, Trassen und Zähler-Anfragen ausgeschlossen;
  injizierte Zähler-Anschluss-ID wird nicht übernommen; Rechteentzug geprüft.
  Lookup-Begrenzung, Suche jenseits des ersten Fensters und eindeutige DOM-IDs geprüft.
- Browser: Öffnen/Abbrechen erhält Listen-DOM, Scrollstand, Filter und vorherige
  Auswahl. Suche findet UX-150 außerhalb der initialen Auswahl. Aktiver Zähler
  bleibt unverändert; Vertragserstellung und anschließende Inline-Kundenbearbeitung.
  Neuer Kunde/Anschluss/Zähler, absichtlich ungültiger Anfangswert, erhaltene Modi/
  Eingaben und erfolgreicher Wiederholungsversuch mit exaktem Stand. Neue passende
  Listenzeile wird genau einmal eingefügt und ausgewählt. Keine JavaScript-Fehler.
- Bestehende Vertrags-Browserregression erfolgreich: begrenztes Nachladen, Suche,
  Scroll-/Filtererhalt, Tastaturauswahl, Inlineänderung, Ablesefehler und Speicherung.
  Die Prüfung wählt die konkrete Vertragsnummer; mehrere Verträge desselben Kunden
  sind jetzt ausdrücklich ein regulärer Testfall, keine vermeintlichen Duplikate.
- Masterdaten-Browserablauf einschließlich Ablesekorrektur und atomarem Zählerwechsel
  weiterhin erfolgreich. Theme-Test: 40 Kombinationen mit mindestens 4,5:1 Link- und
  Buttontext-Kontrast, Speicherung, Navigation, Reset und ungültiger lokaler Auswahl.
- RuboCop ohne Beanstandung, Brakeman ohne Warnungen, Zeitwerk erfolgreich,
  aktueller Bundler-Audit ohne bekannte Schwachstellen.
- Docker-Build/Start mit `compose.build.yaml` erfolgreich. Derselbe vollständige
  Neuanlage-/Fehler-/Wiederholungsablauf zusätzlich auf dem Image ohne Quellmount
  mit eigener synthetischer Fixture durchgeführt. Keine neue Migration erforderlich.

## Visuelle Nachweise und Grenzen

`screenshots` enthält die neue Erfassung bei 1280 × 800, 1440 × 900,
1920 × 1080 und 2560 × 1440 sowie Fehler- und Ergebniszustände. Keine horizontale
Seitenausdehnung. Im rechten Bereich wird bei Bedarf unabhängig gescrollt;
insbesondere neue Stammdaten benötigen mehr Höhe als die Wiederverwendung.
Keine Smartphone-Architektur und keine vollständige Accessibility-Abnahme behauptet.

`before` zeigt echte Aufnahmen der bisherigen Vollseiten-Neuanlage aus dem noch
laufenden vorherigen Docker-Image vor dessen Update. Beide Installationen nutzen
die synthetische 150er-Fixture, haben jedoch unterschiedliche UUIDs und zusätzliche
Testdatensätze. Die Bilder belegen den Layoutwechsel, keinen identischen numerischen
Datenbestand oder eine gemessene Performanceverbesserung.

Browsernachweise: `browser-checks.json`, `contract-regression-checks.json`.
Reproduktion: `python3 scripts/contract_creation_smoke.py`; Optionen `--base`,
`--env-file`, `--fixtures`, `--output` unterstützen den separaten Docker-Teststack.
Die Fixture wird ausschließlich mit expliziter synthetischer Freigabe erzeugt.

## Geänderte Bereiche und Auslieferung

Formularobjekt, Vertragscontroller und drei begrenzte Lookup-Endpunkte,
Draft-Ansichten/Stimulus, gemeinsame Vertrags-/Zählerfelder, IDs gemeinsamer
Anschlussfelder, Listenaktualisierung, Theme-Ableitung, Tests und UI-Regeln.
Keine Datenmodell-, Abrechnungs-, Joomla- oder Abhängigkeitsänderung.

Dockhand: bestehenden Git-Stack auf `main` aktualisieren und weiterhin mit
`compose.build.yaml` neu bauen/ausspielen. Umgebungsvariablen und Datenpfade bleiben.
