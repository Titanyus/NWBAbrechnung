# NWB Verwaltung – Verbindlicher UI/UX-Neuaufbau
## Desktop-Verwaltungssoftware mit intelligenter Informationsarchitektur

### 1. Ausgangslage

Die bestehende Ruby-on-Rails-Anwendung „NWB Verwaltung“ verfügt bereits über eine funktionierende Anlagen-, Kunden-, Vertrags-, Anschluss-, Trassen- und Zählerverwaltung.

Die technische Umsetzung funktioniert grundsätzlich. Die Benutzeroberfläche ist jedoch in ihrer derzeitigen Form nicht zufriedenstellend.

Folgende Probleme wurden festgestellt:

- Zu viel ungenutzte Bildschirmfläche
- Überdimensionierte Seitenköpfe
- Wiederholte Anlageninformationen
- Filterfelder werden untereinander statt nebeneinander angeordnet
- Einzelne Kunden werden in sehr großen Karten dargestellt, obwohl nur wenige Informationen enthalten sind
- Datensätze beginnen teilweise erst in der unteren Bildschirmhälfte
- Zusammengehörige Informationen sind auf mehrere unabhängige Verwaltungsseiten verteilt
- Die Navigation orientiert sich zu stark an technischen Datenbankmodellen
- Funktionen und Aktionen werden nicht ausreichend logisch gruppiert
- Das Layout ist zu stark auf mobile Bildschirmgrößen ausgerichtet

Dadurch entstehen unnötige Wege, Klicks und Scrollvorgänge.

**Diese Probleme müssen jetzt behoben werden, bevor weitere umfangreiche Verwaltungsfunktionen entwickelt werden.**

---

### 2. Oberstes Ziel

Entwickle eine professionelle Desktop-Verwaltungsoberfläche, die sich für kaufmännische Mitarbeiter intuitiv, effizient und logisch bedienen lässt.

Die Anwendung soll nicht möglichst viele Funktionen sichtbar machen, sondern die jeweils relevanten Informationen und Aktionen sinnvoll präsentieren.

Die wichtigsten Grundsätze sind:

1. Logische und intelligente Gruppierung
2. Aufgabenorientierte Benutzerführung
3. Hohe Informationsdichte ohne Überladung
4. Konsequente Nutzung der verfügbaren Bildschirmbreite
5. Möglichst wenig unnötige Navigation und Klicks
6. Klare Priorisierung von Aktionen
7. Einheitliche, verständliche Gestaltung
8. Hohe Bedienbarkeit und Lesbarkeit

**Wichtig: Informationsdichte bedeutet nicht, möglichst viele kleine Elemente zusammenzuquetschen.**

Das Ziel ist eine menschlich verständliche, gut organisierte Arbeitsoberfläche.

Die Software ist ein Arbeitswerkzeug, keine Marketingwebsite und kein dekoratives Dashboard.

---

### 3. Vorhandenes Projekt zuerst untersuchen

Lies vor Änderungen:

- `AGENTS.md`
- Alle relevanten projektspezifischen Codex-Skills
- Architekturentscheidungen
- Vorhandenen UI-Styleguide, falls vorhanden
- Rails-Routen
- Controller
- Models
- Views und Partials
- CSS und vorhandene Designkomponenten
- Berechtigungsmechanismen
- Vorhandene Tests

Prüfe die tatsächlich implementierte Anwendung.

Untersuche insbesondere, welche Verwaltungsseiten bereits existieren und wie sie derzeit miteinander verbunden sind.

Bewerte die bestehende Navigation und die typischen Arbeitsabläufe.

**Keine Implementierung aufgrund bloßer Annahmen über die vorhandene Codebasis.**

---

### 4. Strikte Trennung zwischen Datenmodell und Oberfläche

Diese Aufgabe betrifft in erster Linie:

- Informationsarchitektur
- Navigation
- Seitenaufbau
- Listen und Tabellen
- Formulare
- Informationsgruppen
- Bearbeitungsabläufe
- Aktionsanordnung
- Desktop-Layout
- Visuelle Konsistenz

Die vorhandenen fachlichen Datenmodelle bleiben grundsätzlich unverändert.

Insbesondere bleiben eigenständige Datenmodelle für:

- Nahwärmeanlagen
- Trassen
- Kunden
- Hausanschlüsse beziehungsweise Verbrauchsstellen
- Wärmelieferverträge
- Wärmezähler
- Zählerablesungen

Diese technische Trennung ist sinnvoll und ausdrücklich gewünscht.

**Es geht darum, wie Informationen für Menschen dargestellt werden, nicht darum, alle Daten in einer einzigen Vertragstabelle zusammenzuführen.**

Keine destruktiven Migrationen und keine unnötigen Änderungen der Fachlogik.

Eine begrenzte Erweiterung zur Bearbeitung bisher fest vorgegebener Anlagenstammdaten ist ausdrücklich vorgesehen. Nutze zunächst vorhandene Felder und Services. Zusätzliche Datenbankfelder nur bei tatsächlichem Bedarf und nach nachvollziehbarer Begründung.

---

### 5. Desktop-First als verbindlicher Standard

Die NWB-Verwaltung ist eine Desktop-Anwendung für kaufmännische Arbeitsplätze.

Eine speziell für Smartphones optimierte Oberfläche ist nicht erforderlich.

Entwickle primär für Bildschirmbreiten zwischen 1280 und 2560 Pixeln.

Besonders wichtig ist eine effiziente Darstellung auf Full-HD-Monitoren mit 1920 × 1080 Pixeln.

Vorgaben:

- Desktop-First statt Mobile-First
- Bildschirmbreite intelligent ausnutzen
- Keine unnötig schmalen Inhaltscontainer
- Keine pauschalen engen `max-width`-Beschränkungen für Verwaltungslisten
- Keine großflächigen ungenutzten Seitenbereiche
- Keine grundlose vertikale Stapelung
- Zusammengehörige Elemente horizontal anordnen, wenn genügend Platz vorhanden ist
- Keine Smartphone-spezifische Navigation entwickeln
- Keine Mobile-First-Kartenlayouts als Desktop-Standard verwenden

Schmale Browserfenster und Browserzoom dürfen vorhandene Funktionen nicht unbedienbar machen.

Barrierefreiheit, Tastaturbedienung und Lesbarkeit bleiben verbindlich.

---

### 6. Neue Informationsarchitektur

Die Hauptnavigation soll sich an den tatsächlichen Arbeitsabläufen orientieren, nicht an der Anzahl der Datenbanktabellen.

Gewünschte übergeordnete Struktur:

**Anlagen**
- Anlage auswählen
- Anlagenstammdaten und Einstellungen
- Trassen verwalten

**Verträge**
- Vertragsübersicht
- Vertrag suchen und öffnen
- Zusammengehörige Kunden-, Anschluss-, Vertrags- und Zählerdaten bearbeiten

Später zusätzlich:
- Abrechnungsübersicht, soweit als übergreifender Arbeitsbereich sinnvoll

Kunden, Anschlüsse, Verträge, Zähler und Trassen dürfen nicht länger unreflektiert als fünf gleichberechtigte Hauptbereiche nebeneinanderstehen.

Die eigenständigen Funktionen und technischen Ressourcen bleiben erhalten. Ihre Benutzeroberflächen werden jedoch dort angeboten, wo sie für den jeweiligen Arbeitsablauf sinnvoll sind.

Keine Funktionen entfernen, nur um die Hauptnavigation kürzer zu machen.

---

### 7. Globale Anlagenauswahl

Die aktuell ausgewählte Nahwärmeanlage muss jederzeit klar erkennbar sein.

Implementiere beziehungsweise optimiere dafür eine kompakte globale Anlagenauswahl innerhalb der Navigation.

Der Benutzer soll bei entsprechender Berechtigung schnell zwischen Anlagen wechseln können.

Die ausgewählte Anlage bildet den Arbeitskontext für Verträge und zugehörige Daten.

Vorgaben:

- Anlagenauswahl an einer zentralen Stelle
- Keine Wiederholung des vollständigen Anlagennamens in großen Seitenköpfen
- Keine mehrfachen Anlagenfilter für denselben Kontext
- Anlagenwechsel klar erkennbar
- Bestehende Berechtigungen vollständig erhalten
- Direkte Seitenaufrufe und manipulierte URLs weiterhin serverseitig absichern

Ein Benutzer mit Zugriff auf mehrere Anlagen muss stets wissen, in welcher Anlage er arbeitet.

---

### 8. Anlagenverwaltung

Die vorhandenen Anlagen dürfen nicht dauerhaft nur aus fest vorgegebenen Testwerten bestehen.

Ermögliche das Bearbeiten der vorhandenen Anlagenstammdaten.

Soweit fachlich bereits vorgesehen, insbesondere:

- Anlagenname
- Anschrift
- Beschreibung
- Inbetriebnahmedatum
- Anlagenstatus
- Vorhandene technische Kenndaten

Verwende eine kompakte, übersichtliche Einstellungsansicht.

Keine überdimensionierten Formulare und keine unnötigen Zwischenseiten.

Die technische Anlagen-UUID bleibt unverändert.

Bestehende Daten dürfen nicht unkontrolliert überschrieben werden.

Keine umfassende technische Betriebsführung oder Anlagenüberwachung ergänzen.

---

### 9. Trassen gehören ausschließlich zur Anlage

Eine Trasse gehört fachlich immer zu einer bestimmten Nahwärmeanlage.

Trassen werden typischerweise bei der Einrichtung einer Anlage angelegt und später nur gelegentlich bearbeitet.

Daher:

**Trassenverwaltung ausschließlich innerhalb der Anlagenverwaltung anbieten.**

Gewünschter Weg:

Anlagen → Anlage auswählen → Trassen

Dort können Trassen:

- Angelegt
- Angezeigt
- Bearbeitet
- Bei zulässigen Bedingungen deaktiviert oder entfernt werden

Die Trassen sollen in einer kompakten Liste oder Tabelle dargestellt werden.

Bei einem Hausanschluss kann eine bereits vorhandene Trasse der betreffenden Anlage ausgewählt werden.

Keine selbstständige Trassen-Hauptnavigation.

Keine Trassen anderer Anlagen zur Auswahl anbieten.

Bestehende Beziehungen und historische Zuordnungen erhalten.

---

### 10. Verträge als zentraler Arbeitsplatz

Der Vertrag wird zur zentralen Benutzeroberfläche für die tägliche Verwaltung.

Eine Vertragsakte soll alle relevanten Informationen zu einem Wärmeliefervertrag zusammenhängend anzeigen.

Die fachlich getrennten Datenobjekte werden innerhalb dieser Ansicht logisch zusammengeführt.

Vorgesehene Informationsbereiche:

**A. Kunde**
- Name beziehungsweise Firma
- Kundennummer
- Anschrift
- Telefonnummer
- E-Mail
- Bearbeitungsmöglichkeit

**B. Hausanschluss**
- Anschlussadresse
- Anschlussnummer
- Zugehörige Trasse
- Inbetriebnahmedatum
- Bearbeitungsmöglichkeit

**C. Vertragsdaten**
- Vertragsnummer
- Vertragsbeginn
- Vertragsende
- Vertragsstatus
- Später Tarifzuordnung
- Bearbeitungsmöglichkeit

**D. Wärmezähler**
- Aktuell eingebauter Zähler
- Zählernummer
- Einbaudatum
- Letzter Zählerstand
- Datum der letzten Ablesung
- Neue Ablesung erfassen
- Zählerhistorie öffnen

Später ergänzbar:

**E. Tarif und Abschläge**

**F. Jahresabrechnungen und Dokumente**

**G. Gutschriften und Entschädigungen**

Diese Informationen sollen innerhalb einer zusammenhängenden Vertragsakte erscheinen.

Nicht für jeden Abschnitt standardmäßig eine zusätzliche Hauptseite verlangen.

Bei komplexen Vorgängen, beispielsweise einem Zählerwechsel, darf eine eigenständige geführte Ansicht verwendet werden.

---

### 11. Intelligente Gruppierung der Vertragsakte

Die Vertragsakte muss die verfügbare Desktop-Breite sinnvoll nutzen.

Empfehlungen:

- Zwei oder drei Informationsspalten, soweit sinnvoll
- Kompakte Abschnitte
- Klare Bereichsüberschriften
- Zusammengehörige Felder nebeneinander
- Keine unnötig großen Karten
- Keine überflüssigen Rahmen und Schatten
- Kein übermäßiger vertikaler Abstand
- Keine unnötige Wiederholung bereits sichtbarer Informationen

Aber ausdrücklich:

**Nicht versuchen, jeden freien Pixel zu füllen.**

Wichtiger als maximale Packungsdichte ist eine klare, verständliche Anordnung.

Ein Informationsbereich darf mehr Platz erhalten, wenn dadurch die Bedienung besser wird.

Keine verschachtelten Karten innerhalb mehrerer weiterer Karten, sofern sie keinen echten Informationsgewinn bringen.

---

### 12. Vertragserstellung als zusammenhängender Arbeitsablauf

Beim Anlegen eines Vertrags soll der Benutzer nicht zwischen zahlreichen isolierten Verwaltungsseiten hin- und herspringen müssen.

Gewünschter Ablauf:

1. Anlage ist ausgewählt.
2. Vorhandenen Kunden auswählen oder neuen Kunden anlegen.
3. Vorhandenen Hausanschluss auswählen oder neuen Anschluss anlegen.
4. Falls erforderlich, passende Trasse auswählen.
5. Vertragsdaten erfassen.
6. Eingaben prüfen und speichern.
7. Neue Vertragsakte anzeigen.

Der zugehörige Zähler kann anschließend innerhalb des Anschlussbereichs verwaltet werden.

Wichtig:

- Ein neuer Vertrag benötigt nicht automatisch einen neuen Kunden.
- Ein neuer Vertrag benötigt nicht automatisch einen neuen Hausanschluss.
- Ein vorhandener Hausanschluss kann nacheinander mehrere Verträge besitzen.
- Der vorhandene Zähler bleibt beim Kundenwechsel dem Hausanschluss zugeordnet.
- Historische Vertrags-, Kunden- und Zählerbeziehungen bleiben nachvollziehbar.

Keine unnötigen Duplikate erzeugen.

Keine mehrstufigen Assistenten entwickeln, wenn eine gut strukturierte Eingabemaske einfacher ist.

---

### 13. Kompakte Listen und Tabellen

Für Vertragsübersichten, Trassen, Kundenlisten, Zählerhistorien und Ablesungen sind grundsätzlich kompakte Tabellen zu bevorzugen, sofern ein tabellarischer Vergleich sinnvoll ist.

Keine großflächigen Einzelkarten für einfache Datensätze.

Beispiel Vertragsübersicht:

| Vertrag | Kunde | Anschluss | Trasse | Status | Beginn |
| --- | --- | --- | --- | --- | --- |

Anforderungen:

- Suchbar
- Filterbar
- Sinnvoll sortierbar
- Kompakt
- Gut lesbar
- Eindeutige Datensatzaktionen
- Keine überdimensionierten Zeilen

Orientierungswert für einfache Tabellenzeilen: etwa 40–44 Pixel.

Bei langen oder komplexen Inhalten darf mehr Höhe benötigt werden.

Keine Inhalte abschneiden, nur um einen festen Pixelwert einzuhalten.

Die gesamte Zeile beziehungsweise eine klar beschriftete Hauptaktion darf zur Detailansicht führen, sofern das technisch und hinsichtlich der Barrierefreiheit sauber umgesetzt wird.

---

### 14. Filter horizontal anordnen

Ein besonders wichtiges Problem der bisherigen Oberfläche ist die unnötige vertikale Stapelung von Filtern.

Beispiel:

Kunde | Kundennummer | Anschluss | Trasse | Status | Zeitraum

Auf einem ausreichend breiten Desktop-Monitor sollen fünf bis sechs Filterfelder nebeneinander Platz finden können.

Verwende CSS Grid oder Flexbox mit sinnvollen Spaltenbreiten.

Regeln:

- Filter grundsätzlich horizontal organisieren
- Häufig verwendete Filter direkt sichtbar
- Seltene Filter optional unter „Weitere Filter“
- Keine riesigen separaten Filterkarten
- Keine grundlos bildschirmbreiten Einzelfelder
- Keine unnötigen Umbrüche
- Keine überdimensionierten Labels und Eingabefelder
- Suche und Filter unmittelbar oberhalb der Datentabelle

Nicht alle Filter müssen gleich breit sein.

Ein Namenssuchfeld darf breiter sein als ein Statusfeld.

Die Gestaltung soll sich am tatsächlichen Inhalt orientieren.

---

### 15. Vertikalen Platzverbrauch reduzieren

Eine Verwaltungsseite soll ihre eigentlichen Arbeitsdaten möglichst früh anzeigen.

Minimiere:

- Höhe des globalen Headers
- Höhe der Seitentitel
- Wiederholung des Anlagennamens
- Abstände zwischen Navigation und Inhalt
- Filterbereiche
- Leere Informationskarten
- Überdimensionierte Hinweistexte
- Unnötige Abschnittstrenner

Empfohlene Gestaltung:

- Kompakter globaler Header
- Seitentitel und wichtigste Aktion auf einer Zeile
- Direkt darunter kompakte Suche und Filter
- Anschließend unmittelbar die Daten

Für einfache Listenansichten sollen die ersten Datensätze möglichst innerhalb der oberen 180–220 Pixel des nutzbaren Inhaltsbereichs beginnen.

Dieser Wert ist ein Ziel, keine starre technische Grenze.

Eine Seite, die auf einem Full-HD-Monitor die halbe Bildschirmhöhe für Kopfbereich und Filter verbraucht, gilt grundsätzlich als fehlgestaltet.

---

### 16. Formulare sinnvoll in der Breite gestalten

Formulare dürfen nicht automatisch einspaltig aufgebaut werden.

Verwende auf Desktop zwei bis vier Spalten, sofern das fachlich sinnvoll und gut lesbar ist.

Beispiel Kundenstammdaten:

Vorname | Nachname | Kundennummer

Straße | Hausnummer | PLZ | Ort

Telefon | E-Mail | Zahlungsart

Lange Bemerkungsfelder dürfen selbstverständlich mehr Breite erhalten.

Vorgaben:

- Logische Gruppierung nach Inhalt
- Sinnvolle Feldbreiten
- Gute Beschriftungen
- Verständliche Fehlermeldungen
- Keine unnötigen Pflichtfelder
- Kein übermäßiger Abstand
- Eindeutige Speichern- und Abbrechen-Aktionen
- Konsistente Tastaturreihenfolge

Nicht künstlich vier Spalten erzwingen, wenn dadurch die Eingabe unübersichtlich wird.

---

### 17. Aktionen intelligent priorisieren

**Ein besonders wichtiger Punkt: Keine Ansammlung von zwanzig gleichberechtigten Buttons.**

Eine gute Oberfläche zeigt die Funktionen dort, wo der Benutzer sie benötigt.

Unterscheide:

**Primäre Aktion**
- Wichtigste Handlung im aktuellen Kontext
- Klar erkennbar
- Beispielsweise „Neuer Vertrag“

**Sekundäre Aktionen**
- Häufig benötigte Bearbeitungen
- Direkt am zugehörigen Informationsbereich
- Beispielsweise „Kundendaten bearbeiten“

**Seltene beziehungsweise administrative Aktionen**
- In sinnvoll benannten Menüs oder Detailansichten
- Beispielsweise historische Korrekturen oder spezielle Verwaltungsfunktionen

**Gefährliche Aktionen**
- Deutlich getrennt
- Mit geeigneter Bestätigung und Berechtigung
- Niemals direkt neben alltäglichen Aktionen gleichwertig platzieren

Vermeide:

- Zu viele gleichwertige Buttons
- Unverständliche Symbolsammlungen
- Aktionen ohne erkennbaren Bezug
- Wiederholte Aktionen an mehreren Stellen
- Unnötige Modal-Dialoge
- Versteckte Hauptfunktionen

Nicht jede technisch vorhandene Funktion muss permanent sichtbar sein.

Wichtige und häufig benötigte Funktionen dürfen jedoch nicht hinter unverständlichen Menüs verschwinden.

---

### 18. Kontextbezogene Bearbeitung

Ein Mitarbeiter soll möglichst im aktuellen Arbeitszusammenhang bleiben können.

Beispiel:

Er befindet sich in einer Vertragsakte und möchte die Telefonnummer des Kunden ändern.

Er soll nicht zuerst die Vertragsverwaltung verlassen, zum Kundenmenü wechseln, den Kunden erneut suchen und anschließend zurücknavigieren müssen.

Die Kundeninformationen sind bereits sichtbar.

Dort soll eine direkte Bearbeitungsmöglichkeit angeboten werden.

Dasselbe gilt für einfache Anschluss- und Vertragsänderungen.

Für komplexere Vorgänge wie Zählerwechsel mit Schlussablesung darf ein separater, klar geführter Ablauf verwendet werden.

Nach abgeschlossener Bearbeitung soll der Benutzer sinnvoll in seinen vorherigen Arbeitskontext zurückkehren.

---

### 19. Nicht nach Datenbankmodellen gestalten

Eine technisch vorhandene Model-Klasse rechtfertigt nicht automatisch:

- Einen eigenen Hauptmenüpunkt
- Eine eigenständige Verwaltungsseite
- Eine zusätzliche Karte
- Einen separaten Bearbeitungsablauf
- Eine neue Navigationsebene

Entscheidend ist, wie der Benutzer seine Arbeit erledigt.

Prüfe bei jeder Oberfläche:

1. Welche konkrete Aufgabe soll hier erledigt werden?
2. Welche Informationen braucht der Mitarbeiter dafür?
3. Was gehört fachlich zusammen?
4. Was wird regelmäßig bearbeitet?
5. Welche Informationen sind nur gelegentlich relevant?
6. Welche Aktionen sind wirklich notwendig?
7. Kann ein unnötiger Seitenwechsel vermieden werden?

Entwickle die Oberfläche aus diesen Antworten.

---

### 20. Dauerhafte Designregeln

Orientiere dich konzeptionell an professionellen Enterprise-Designsystemen:

IBM Carbon Design System:
https://carbondesignsystem.com/

PatternFly:
https://www.patternfly.org/

Verwende insbesondere deren Grundprinzipien für:

- Informationshierarchie
- Tabellen
- Formulare
- Navigationsstrukturen
- Abstände
- Konsistente Interaktionen
- Barrierefreiheit

Keine zusätzlichen großen UI-Frameworks installieren.

Die vorhandene Rails-/Hotwire-Architektur bleibt bestehen.

Verwende zentrale Design-Tokens und wiederverwendbare Layoutkomponenten, soweit im Projekt sinnvoll.

Keine individuelle Gestaltung für jede Verwaltungsseite neu erfinden.

---

### 21. Verbindliche UX-Prüfung vor jeder größeren Implementierung

Bevor du eine neue Verwaltungsoberfläche entwickelst, beschreibe kurz den vorgesehenen Arbeitsablauf aus Sicht eines kaufmännischen Mitarbeiters.

Beispiel:

„Der Mitarbeiter öffnet die Vertragsübersicht, sucht nach einem Kunden und öffnet dessen Vertrag. Dort sieht er Kundendaten, Hausanschluss und aktuellen Zähler. Über die Funktion 'Neue Ablesung' erfasst er den Zählerstand und kehrt anschließend in die aktualisierte Vertragsakte zurück.“

Diese Beschreibung soll kurz und konkret sein.

Wenn sich ein Arbeitsablauf nicht einfach erklären lässt, muss die Benutzerführung vor der Implementierung überprüft werden.

**Erst Arbeitsablauf verstehen, dann Informationen gruppieren, dann Oberfläche gestalten, anschließend implementieren.**

---

### 22. Typische Arbeitsabläufe testen

Prüfe mindestens:

**Arbeitsablauf A – Neuen Vertrag anlegen**
- Anlage auswählen
- Vorhandenen oder neuen Kunden verwenden
- Vorhandenen oder neuen Anschluss verwenden
- Vertrag erfassen
- Vertragsakte öffnen

**Arbeitsablauf B – Kundendaten ändern**
- Vertrag suchen
- Vertragsakte öffnen
- Kundendaten ändern
- Zur Vertragsakte zurückkehren

**Arbeitsablauf C – Zählerablesung erfassen**
- Vertrag suchen
- Anschluss und Zähler anzeigen
- Ablesung eingeben
- Aktuellen Stand kontrollieren

**Arbeitsablauf D – Trasse verwalten**
- Anlage öffnen
- Trassenübersicht aufrufen
- Trasse anlegen oder bearbeiten
- Zur Anlage zurückkehren

Beurteile bei jedem Ablauf:

- Wie viele Klicks sind erforderlich?
- Wie viele Seitenwechsel sind nötig?
- Gibt es redundante Eingaben?
- Muss der Benutzer Informationen erneut suchen?
- Sind Aktionen verständlich?
- Bleibt die Orientierung erhalten?
- Können mehrere Schritte sinnvoll zusammengefasst werden?

Keine künstliche Reduzierung der Klickzahl zulasten von Sicherheit oder Nachvollziehbarkeit.

---

### 23. Verbindliche visuelle Tests

Nutze die vorhandenen Browser-Testwerkzeuge, vorzugsweise Playwright.

Teste mindestens folgende Bildschirmgrößen:

- 1280 × 800
- 1440 × 900
- 1920 × 1080
- 2560 × 1440

Erstelle Vorher-/Nachher-Screenshots der wichtigsten Ansichten.

Prüfe insbesondere:

1. Wie viel Bildschirmbreite wird tatsächlich genutzt?
2. Wie viel Fläche bleibt unnötig leer?
3. Wie viele Filterfelder stehen nebeneinander?
4. Wie weit unten beginnt der erste Datensatz?
5. Wie viele Datensätze sind ohne Scrollen sichtbar?
6. Gibt es unnötige Zeilenumbrüche?
7. Werden zusammengehörige Informationen logisch gruppiert?
8. Sind alle relevanten Aktionen verständlich erreichbar?
9. Gibt es eine unübersichtliche Ansammlung von Buttons?
10. Sind Formulare kompakt, aber gut bedienbar?
11. Funktioniert die Tastaturnavigation?
12. Ist der aktuell ausgewählte Anlagenkontext eindeutig?

Ziel für einfache Kunden- und Vertragslisten:

Bei 1440 × 900 Pixeln sollen nach Möglichkeit 12–15 Einträge ohne vertikales Scrollen sichtbar sein, sofern Navigation, Filter und Inhalt dies sinnvoll zulassen.

Das ist ein Orientierungswert, kein Grund für unlesbar kleine Schrift oder abgeschnittene Inhalte.

Bewerte das tatsächliche Browserergebnis, nicht nur den geschriebenen CSS-Code.

Wenn visuelle Tests technisch nicht ausführbar sind, dokumentiere dies ausdrücklich als nicht ausgeführt.

Keine Screenshots oder Prüfergebnisse erfinden.

---

### 24. Fachliche und technische Sicherheit

Die gesamte Umgestaltung muss folgende Vorgaben erfüllen:

- Bestehende Datenmodelle grundsätzlich beibehalten
- Bestehende Benutzerrechte erhalten
- Sämtliche Berechtigungsprüfungen serverseitig durchsetzen
- Keine Freigabe fremder Anlagendaten
- Keine Änderung historischer Vertragsbeziehungen
- Bestehende UUIDs erhalten
- Keine unnötigen Migrationen
- Keine Löschung bestehender Fachfunktionen
- Keine neue Benutzerverwaltung
- Keine neue Abrechnungslogik
- Keine Änderungen an der Joomla-API
- Keine zusätzlichen großen Frontend-Frameworks
- Vorhandene Rails-/Hotwire-Komponenten weiterverwenden
- Bestehende Tests erhalten und ergänzen
- Ausschließlich synthetische Testdaten verwenden

Die geplante Bearbeitung von Anlagenstammdaten ist Teil dieses Auftrags. Falls dafür fachliche Datenmodellentscheidungen nötig werden, dokumentiere diese zunächst statt unkontrolliert neue Strukturen einzuführen.

---

### 25. Dauerhafte Codex-Guardrails

Erstelle beziehungsweise aktualisiere:

`docs/UI_GUIDELINES.md`

Enthalten sein müssen:

- Desktop-First-Prinzipien
- Informationsarchitektur
- Logische Gruppierung
- Tabellenstandards
- Horizontale Filterlayouts
- Formularlayouts
- Seitenköpfe und Abstände
- Aktionspriorisierung
- Vertragsakten-Konzept
- Anlagen- und Trassenverwaltung
- Bedienungsabläufe
- Visuelle Abnahmekriterien

Erstelle beziehungsweise aktualisiere außerdem:

`.agents/skills/admin-ui/SKILL.md`

Dieser Skill ist bei jeder zukünftigen Entwicklung oder Änderung von Verwaltungsoberflächen zu verwenden.

Ergänze `AGENTS.md` um eine verbindliche Regel:

**Jede neue UI-Funktion muss den zentralen UX-Styleguide berücksichtigen und sich logisch in die bestehenden Arbeitsabläufe integrieren.**

Widersprüchliche ältere Mobile-First- oder Layoutanweisungen für dieses Projekt sind entsprechend anzupassen.

Bestehende Sicherheits- und Architektur-Guardrails dürfen nicht abgeschwächt werden.

---

### 26. Umsetzung in kontrollierten Schritten

Gehe folgendermaßen vor:

**Phase 1 – Analyse**
- Aktuelle Oberflächen prüfen
- Navigation und typische Abläufe untersuchen
- Größte Platzverschwendungen identifizieren
- Bestehende Berechtigungen und Datenbeziehungen prüfen

**Phase 2 – Zielkonzept**
- Neue Hauptnavigation festlegen
- Globale Anlagenauswahl definieren
- Vertragsakte konzipieren
- Anlagen- und Trassenverwaltung logisch einordnen
- Kompakte Listen- und Formularstandards festlegen

**Phase 3 – Implementierung**
- Navigation optimieren
- Seitenköpfe verkleinern
- Filter horizontal ausrichten
- Tabellen kompakt gestalten
- Anlagenstammdaten bearbeitbar machen
- Trassen in die Anlagenverwaltung integrieren
- Vertragsakte als zentralen Arbeitsbereich aufbauen
- Bestehende Kunden-, Anschluss- und Zählerfunktionen dort zugänglich machen

**Phase 4 – Qualitätsprüfung**
- Arbeitsabläufe testen
- Berechtigungen prüfen
- Browser-Screenshots vergleichen
- Informationsdichte bewerten
- UX-Probleme korrigieren
- Regressionstests ausführen

**Phase 5 – Standards festschreiben**
- UI-Styleguide aktualisieren
- Codex-Skill aktualisieren
- AGENTS.md ergänzen
- Neue Regeln für alle weiteren Entwicklungsschritte verbindlich machen

Arbeite in kleinen, nachvollziehbaren Änderungen.

Kein großflächiger Neubau der Rails-Anwendung.

---

### 27. Erwartete Ergebnisse

Am Ende erwarte ich:

1. Eine deutlich kompaktere Desktop-Oberfläche.
2. Effiziente Nutzung der Bildschirmbreite.
3. Horizontale, sinnvoll angeordnete Filter.
4. Kompakte Kunden- und Vertragslisten.
5. Eine logisch aufgebaute Hauptnavigation.
6. Eine zentrale Anlagenauswahl.
7. Bearbeitbare Anlagenstammdaten.
8. Trassenverwaltung innerhalb der jeweiligen Anlage.
9. Eine zusammenhängende Vertragsakte.
10. Kunden-, Anschluss-, Vertrags- und Zählerinformationen innerhalb dieser Akte.
11. Sinnvoll priorisierte Aktionen statt unübersichtlicher Button-Sammlungen.
12. Verständliche und möglichst direkte Bearbeitungsabläufe.
13. Vorher-/Nachher-Screenshots.
14. Tatsächlich ausgeführte Tests.
15. Einen dauerhaft dokumentierten UI-Styleguide.
16. Einen verbindlichen Codex-UI-Skill.
17. Eine aktualisierte AGENTS.md.
18. Eine Zusammenfassung der vorgenommenen Änderungen und noch vorhandener Einschränkungen.

---

## Abschließende Grundregel

**Baue keine Oberfläche, die zeigt, was die Software alles kann. Baue eine Oberfläche, mit der ein Mensch seine Arbeit möglichst selbstverständlich erledigen kann.**

Ein Mitarbeiter soll ohne lange Erklärung verstehen:

- Wo er sich befindet
- Zu welcher Anlage die Daten gehören
- Wo er einen Vertrag findet
- Welche Informationen zusammengehören
- Wo er etwas bearbeiten kann
- Was der nächste sinnvolle Arbeitsschritt ist

Informationsdichte ist wichtig, aber logische Ordnung und menschliche Bedienbarkeit sind wichtiger.

Vermeide sowohl großflächige Platzverschwendung als auch überfüllte Oberflächen.

**Das Ziel ist eine intelligente, aufgeräumte und effiziente Desktop-Verwaltung, bei der sich Funktionen selbstverständlich in den jeweiligen Arbeitszusammenhang einfügen.**

Diese Grundsätze gelten verbindlich für alle zukünftigen Entwicklungsschritte der NWB-Verwaltung.