# Verbindlicher UI-Standard – NWB Verwaltung

Aktueller Folgeauftrag hat Vorrang vor der ursprünglichen Pilotbegrenzung:
Anlagenübersicht und Stammdatenbearbeitung verwenden dieselben Desktop-Komponenten
wie die Vertragsverwaltung. Alle bestehenden Suchen reagieren live serverseitig:
Text nach 300 ms, Dropdown sofort, alte Antworten verwerfen, Fokus erhalten.
Keine einzelnen Komponenten/Styles pro Feld oder Button; gemeinsame Tabellen-,
Feld-, Fehler-, Aktions- und Layoutbausteine wiederverwenden. Farben ausschließlich
aus vorhandenen Theme-Variablen; NWB-Header und Seitenleiste verwenden das bestehende
Grün, Aktionen Gold, Flächen Weiß. Keine neuen unabhängigen Farbcodes.
Leistungsdaten sind nicht modelliert: „nicht erfasst“ statt erfundener Berechnung.

## Aktueller Anlagen-/Trassenauftrag

Anlagen direkt pro Zeile bearbeiten; keine Markierung und keine Radiobuttons.
Stammdaten links, automatisch ermittelte Kennzahlen rechts, Trassen als Tabelle
unterhalb. Alle Vertragsstatus zählen; „Verträge gesamt“ eindeutig beschriften.
Trassen direkt in diesem Arbeitsplatz anlegen/bearbeiten; keine Trassensuche und
kein beschreibender Einführungstext dort (ausdrückliche Ausnahme zur Live-Suche).
Keine Löschfunktion ergänzen. Bestehende Rechte erhalten.

Straße/Hausnummer, PLZ und Ort sind bei jeder Anlage, jedem Kunden und jedem
Hausanschluss getrennte Pflichtfelder. Gemeinsames Partial `shared/address_fields`
und gemeinsame Modellvalidierung `StructuredAddress` verwenden. PLZ ist Text und
behält führende Nullen. Anschrift für Anzeigen wird daraus zusammengesetzt, nicht
zusätzlich gespeichert. Keine Freitext-Adressmasken oder automatischen Parser.
Die ausdrücklich entbehrlichen bisherigen Demoadressen werden bei der Migration
durch strukturierte Beispielwerte ersetzt; der Betreiber hat dies freigegeben.

## Ursprünglicher Vertrags-Pilot (historischer Stand)

Zunächst ausschließlich Vertragsverwaltung: kompakte linke Hauptnavigation,
Anlagenwahl oben, horizontale Filter und ein Master-Detail-Arbeitsplatz. Linke
Auswahlliste scrollt unabhängig, initial höchstens 30 Verträge, danach serverseitig
begrenztes Turbo-Nachladen. Keine klassische Seitennummerierung dort. Suche,
Filter und Sortierung immer serverseitig über den vollständigen Anlagenscope.
Rechte Akte wird separat geladen; Auswahl verändert Filter und Scrollstand nicht.

Übersicht enthält Kunde, Vertrag, Anschluss und aktuellen Zähler gemeinsam.
Weitere Ansichten nur für tatsächliche Historie oder komplexe Vorgänge. Kein
Kunden-Hauptmenü, keine leeren Abrechnungs-/Auswertungsfunktionen. Der Rest der
Anwendung bleibt bis zur visuellen Abnahme im Bestand; der Styleguide ist das
künftige gemeinsame Muster, keine Freigabe für einen sofortigen breiten Rollout.

## Geltungsbereich und Vorrang

Die Anwendung ist ein Desktop-Arbeitswerkzeug von **1280 bis 2560 Pixeln** Breite.
Der neueste Auftrag UI_REBUILD_BRIEF.md hat Vorrang vor dem vorherigen UI-Auftrag
und dessen 1440-Pixel-Mindestvorgabe. Pflichtgrößen: 1280 × 800, 1440 × 900,
1920 × 1080 und 2560 × 1440. Keine gesonderte Smartphone-Navigation oder mobilen
Kartenlayouts. Zoom und schmale Fenster müssen die Bedienung weiter erlauben.
Rails/Hotwire, Themes, bestehende Modelle, UUIDs und Schutzregeln bleiben erhalten.

Vor jeder neuen oder geänderten Verwaltungsansicht diesen Leitfaden und
`.agents/skills/admin-ui/SKILL.md` lesen. Sicherheit und fachliche Korrektheit
haben weiterhin Vorrang. Keine Datenmodell-/Rechteänderung als UI-Optimierung.

## Konzeptionelle Referenzen

- IBM Carbon: https://carbondesignsystem.com/components/data-table/usage/
- Offizielle gelesene Quelle: https://github.com/carbon-design-system/carbon-website/blob/main/src/pages/components/data-table/usage.mdx
- PatternFly: https://www.patternfly.org/components/table/design-guidelines/
- Offizielle gelesene Quelle: https://github.com/patternfly/patternfly-react/blob/main/packages/react-table/src/components/Table/examples/Table.md

Übernommen werden kompakte Tabellen, angepasste Toolbars, volle Inhaltsbreite,
semantische Kopfzeilen und eine klare Aktionsspalte. Die veröffentlichten HTML-
Webseiten waren hier netzwerkseitig gesperrt; die offiziellen Dokumentationsquellen
auf GitHub wurden gelesen. Keine Frameworkinstallation, keine React-Komponenten,
keine externen CSS-, Font- oder CDN-Abhängigkeiten und kein Kopieren ganzer Systeme.

## Tokens und Typografie

Im Pilot werden Maße zentral und lokal begrenzt in `admin_contracts.css` definiert.
Bestehende Seiten behalten `application.css` unverändert.

| Token-Gruppe | Verbindlicher Standard |
|---|---|
| Abstand | 4, 8, 12, 16, 24, 32 px; Basisschritt 4 px |
| Grundschrift | 14 px, Systemschrift, Zeilenhöhe ca. 1,45 |
| Seitentitel | 24 px / 1,25; ein H1 je Seite |
| Abschnittstitel | 18 px; keine Marketingüberschriften |
| Kleine Hinweise | 12 px; keine verkleinerten Hauptdaten |
| Tabellen | Ziel 40 px pro einfacher Datenzeile und Kopfzeile; bei langen Inhalten natürliche Höhe |
| Formularfelder | 36 px für einzeilige Felder; Textareas passend zum Inhalt |
| Aktionen | 36 px Hauptaktionen, mindestens 32 px Zeilenaktionen; sichtbarer Text |
| Inhalt | Verfügbare Desktopbreite nutzen; keine pauschale enge max-width für Listen |

Keine individuellen Schrift-/Abstandswerte je View. Farbvariablen bleiben mit
NWB Billenhausen, Smaragd, Ozean, Schiefer, Hell/Dunkel und eigenen Akzenten
kompatibel. Statusanzeigen verwenden dieselben vorhandenen Theme-Tokens, keine separaten
Farbpaletten oder fest codierten Farben in Views. Keine dekorativen Schatten oder verschachtelten Karten.

## Listen und Tabellen

Für künftige Erweiterungen gilt: Anlagen, Kunden, Anschlüsse, Zähler, Ablesungen und Trassen werden bei
vergleichbaren Feldern als semantische Tabellen dargestellt. Wiederverwendbare
Struktur: `shared/_data_table.html.erb` mit Caption, THEAD, TH scope=col und TBODY.
Jede Tabelle erhält eine eindeutige ID und einen verständlichen Namen.

- Namen/Nummern sind normale Links zur Detailansicht, keine nur anklickbaren Zeilen.
- Spalten: Identität zuerst, relevante Vergleichswerte, Status und Aktionen zuletzt.
- Kunden: Name, Kundennummer, erfasste Anschrift, Status, Aktionen. Kein erfundener
  Ort aus einem unstrukturierten Adressfeld; vorhandene Daten nur formatieren.
- Zeilenaktionen einheitlich textlich, mit verständlichem zugänglichem Namen.
- Keine Platzhalter-Aktionen für nicht implementierte Tarife oder Abrechnung.
- Keine Ellipse als Standard für wichtige Namen, Zahlen oder Aktionen. Lange Texte
  dürfen umbrechen oder in ausdrücklich beschrifteten Details geöffnet werden.
- Leere Ergebnisse erklären; Anlage, Suchfilter, Seitennavigation und Erstellen-
  Aktion bleiben erreichbar. Keine künstlichen leeren Karten.
- Keine Miniaturtabellen. Bei tatsächlich sehr breiten Inhalten kontrolliertes
  Scrollen im beschrifteten Tabellenbereich, kein überlaufendes Gesamtlayout.
- Ziel: möglichst 12–15 vollständige einfache Kundenzeilen bei 1440 × 900 ohne
  Scrollen. Lesbarkeit, lange Inhalte und sichere Aktionen haben Vorrang.

## Navigation und Informationshierarchie

Zwei Hauptbereiche: **Anlagen** (Stammdaten, Einstellungen, Trassen) und **Verträge**
(Übersicht und zentrale Akte). Kunden-, Anschluss- und Zählerlisten bleiben sekundär
unter „Weitere Stammdaten“ erreichbar. Trassen ausschließlich unter Anlagen.
Globale Anlagenwahl einmal im Header, kein zweiter Filter für denselben Kontext.
 Anlage und Bereich müssen jederzeit
sichtbar sein. Kompakte Anlagenwahl und flache Bereichslinks; der aktive Bereich
bekommt `aria-current=page`. Keine zusätzlichen Dashboard- oder Menüebenen.
Der Pilot verwendet die kompakte linke Navigation gemäß Bildreferenz.
Ein Seitenkopf verbindet Titel und primäre Aktion in einer Zeile. Filter stehen
als schmale Toolbar direkt vor der Liste; Beschriftungen bleiben sichtbar.

## Formulare und Details

- Formulare in logischen, beschrifteten Gruppen und zwei sinnvollen Desktopspalten.
  Lange Anschriften/Kommentare über beide Feldspalten. Kein 700-px-Formular in einem
  1600-px-Inhaltsbereich mit großem ungenutztem Rand.
- Labels bleiben eindeutig; erforderliche Eingaben werden sichtbar als Pflichtfeld
  gekennzeichnet und behalten das native required-Attribut. Bedingte Identität
  (Firma ODER Vor-/Nachname) nicht fälschlich in einzelne Pflichtfelder verwandeln.
- Fieldsets und Legenden für Gruppen, echte Label/Input-Verknüpfungen; keine Labels
  durch Platzhalter ersetzen. Checkbox-Label gemeinsam anklickbar.
- Fehlermeldungen unmittelbar vor dem Formular mit role=alert und verständlicher
  Zusammenfassung. Bestehende Validierung und eingegebene Werte erhalten.
- Speichern und Abbrechen gemeinsam am Formularende. Abbrechen ändert keine Daten.
- Details als kompakte DT/DD-Gruppen, Beziehungen als Tabellen, nicht als Karten
  innerhalb von Karten. UUIDs lesbar, aber visuell nachgeordnet.

## Zahlen, Daten und Status

Datumswerte in Ansichten `TT.MM.JJJJ`, Zeitpunkte zusätzlich `HH:MM` in der
Anwendungszeitzone. HTML-Date-Felder behalten ISO-Werte. Exakte Zählerstände mit
Dezimalkomma und Tausenderpunkt; keine Rundung und keine Float-Konvertierung.
Zahlen rechtsbündig mit tabellarischen Ziffern, Einheit klar angeben. Für spätere
Geldanzeigen erst freigegebene fachliche Rundung anwenden, nie im UI erfinden.
Status als Text mit dezentem Badge; Farbe trägt nicht allein die Bedeutung.

## Barrierefreiheit und Nachweis

Native Tabellen-/Formularsemantik, sichtbarer Tastaturfokus, Skip-Link und klare
Linknamen. Normale Texte mindestens 4,5:1, Fokus/Bedienelemente ausreichend
kontrastreich. Zoom und lange Inhalte dürfen Aktionen nicht abschneiden.
Anlagenwechsel, Suche/Filter, Zeilenaktionen, Formulare und Details mit Tastatur
und Playwright prüfen. Vorher-/Nachher-Screenshots mit identischem synthetischem
Datenbestand. Sichtbare Zeilen, Zeilenhöhe, Scrollhöhe und Seitenüberlauf messen.
Nicht ausgeführte Prüfungen ausdrücklich benennen; keinen vollständigen
Barrierefreiheitsnachweis aus einzelnen Browserprüfungen ableiten.

## Verbindliches Vertragsakten-Konzept

Die Akte zeigt Kunde, Hausanschluss, Vertragsdaten und aktuellen Zähler logisch
in zwei bis drei Spalten, mit kurzen DT/DD-Gruppen und lokalen Bearbeitungslinks.
Einzige hervorgehobene tägliche Aktion am Zähler: Neue Ablesung. Seltene Wechsel/
Korrekturen gehören in verständlich benannte Detailabläufe, nicht in eine Sammlung
vieler gleichrangiger Buttons. Keine leeren Platzhalter für spätere Fachmodule.

Kleine Bearbeitungen über Turbo-Frames im Arbeitskontext; nach Speicherung bleibt
die Akte mit aktualisierten Daten sichtbar. Ein Vertragskontext wird immer über
eine autorisierte Vertrags-ID und passende Kunde-/Anschluss-/Zählerbeziehung
geprüft, nie über freie return_to-URLs. Bei Fehlern Eingaben/Begründungen erhalten.

Zurückgestellt (nicht Teil dieses Pilots): Neue Verträge in einem logischen Formular: vorhandener/neuer Kunde, vorhandener/
neuer Anschluss, Trasse der Anlage, Vertragsdaten, prüfen und atomar speichern.
Vorhandene Kunden, Anschlüsse und Zähler werden dabei nicht überschrieben oder
unnötig dupliziert. Keine mehrstufigen Assistenten und keine neuen Fachregeln.

Vertragsliste mit horizontalen Such-/Filterfeldern (Kunde/Vertrag, Kundennummer,
Anschluss, Trasse, Status, Beginn ab). Seltene Filter unter Weitere Filter.
Die linke Vertragsauswahlliste verwendet eine beschriftete Sortierauswahl und
zwei Informationszeilen mit ca. 52 px Höhe; Vergleichstabellen nutzen Tabellenköpfe. Filter und Sortierung bei Seitennavigation erhalten.

## Anlagen und Trassen

Vorhandene Anlagenfelder Name, Anschrift und technische Hinweise sind für
zugeordnete Administratoren bearbeitbar. Keine UUID-Änderung und kein ungefragtes
Ergänzen von Status-/Inbetriebnahmefeldern ohne Fachentscheidung. Trassen nur in
der Anlage einrichten/bearbeiten. Entfernen ausschließlich manuell bestätigt,
wenn keine aktuellen oder protokollierten Anschlusszuordnungen bestehen.

## Verbindlicher Ablauf vor jeder UI-Erweiterung

Zuerst einen kurzen kaufmännischen Arbeitsablauf erklären, dann Informationen
ordnen, erst danach implementieren. Die Abläufe A–D aus UI_REBUILD_PLAN.md mit
Klicks, Seitenwechseln, Orientierung und sicheren Rückwegen tatsächlich testen.
Vier Desktopgrößen, Tastatur und Zoom prüfen; identische Vorher-/Nachher-Daten.
Listen sollen innerhalb der oberen 180–220 px des nutzbaren Inhalts beginnen;
12–15 einfache Zeilen bei 1440 × 900 sind ein Ziel, keine Kürzungsvorgabe.
