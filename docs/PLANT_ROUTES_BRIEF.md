# NWB Verwaltung – Anlagenverwaltung und Trassen optimieren
## Verbindlicher Entwicklungsauftrag mit visueller Referenz

### 1. Ausgangslage

Die bestehende Rails-Anwendung „NWB Verwaltung“ verfügt bereits über:

- Anlagenübersicht
- Globale Anlagenauswahl im Header
- Anlagenstammdaten
- Kunden, Verträge und Hausanschlüsse
- Trassenverwaltung
- Bestehende Themegestaltung und UI-Komponenten

Die Anlagenübersicht funktioniert grundsätzlich gut.

Das Formular zum Anlegen und Bearbeiten einer Anlage benötigt dagegen eine deutlich bessere Struktur und Benutzerführung.

Als Referenz liegt ein Bild der gewünschten neuen Anlagenbearbeitung bei.

**Arbeite auf Grundlage der bestehenden Anwendung. Keine unnötige Neuentwicklung.**

Lies zuerst `AGENTS.md`, vorhandene Skills, UI-Styleguide, Architekturentscheidungen und relevante Tests.

---

### 2. WICHTIG: Referenzbild enthält nur gestalterische Muster

Das beigefügte Bild dient ausschließlich als Referenz für:

- Informationsarchitektur
- Logische Gruppierung
- Anordnung der Eingabefelder
- Platznutzung
- Tabellenstruktur
- Informationsdichte
- Benutzerführung
- Hierarchie der Funktionen

**Die Farben des Referenzbildes dürfen ausdrücklich NICHT übernommen werden.**

Die NWB-Verwaltung besitzt bereits eine eigene Themegestaltung.

Verbindlich erhalten bleiben:

- Bestehende Themefarben
- Bestehende Schriftgestaltung
- Vorhandene Buttonfarben
- Bestehende Hintergrundfarben
- Vorhandene Rahmen- und Eingabefeldstile
- Bereits etablierte Statusfarben
- Bestehende Design-Tokens und CSS-Variablen

Keine neue blaue Farbpalette einführen, nur weil das Referenzbild blaue Elemente enthält.

Keine globalen CSS-Farben verändern.

Keine neuen Hex-Farbwerte aus dem Referenzbild übernehmen.

Nutze möglichst vorhandene CSS-Klassen, Variablen und UI-Komponenten.

**Übernimm die Struktur, nicht das Farbschema.**

---

### 3. Anlagenübersicht – vorhandene Struktur erhalten

Die bestehende Anlagenübersicht soll grundsätzlich erhalten bleiben.

Ihre Tabellenstruktur mit Anlagenname, Anschrift, Anschlüssen, Trassen, Verträgen und weiteren vorhandenen Angaben ist bereits sinnvoll.

Folgende Änderungen sind gewünscht:

**Entfernen:**
- Radiobuttons zur Markierung einer Anlage
- Spalte „Markieren“
- Bearbeitungsablauf, bei dem zunächst ein Radiobutton ausgewählt werden muss

**Beibehalten:**
- Tabellenübersicht
- Bestehende Suche
- Sortierung
- Button „Neue Anlage anlegen“
- Button „Anlage auswählen“ in jeder Tabellenzeile
- Globale Anlagenauswahl im Header

**Neu beziehungsweise vereinfacht:**
- Jede Tabellenzeile erhält eine direkte Bearbeitungsmöglichkeit.
- Dafür eine kompakte Aktion „Bearbeiten“ vorsehen.
- Alternativ oder ergänzend kann der Anlagenname die Bearbeitungsansicht öffnen.
- Keine vorherige Datensatzmarkierung erforderlich.

### Wichtig: Zwei unterschiedliche Aktionen

**„Anlage auswählen“**

Diese bestehende Funktion bleibt ausdrücklich erhalten.

Sie übernimmt die betreffende Anlage als aktuellen Arbeitskontext und führt direkt in deren Vertragsverwaltung.

Sie ist sinnvoll, weil Mitarbeiter bei einer langen Anlagenliste direkt aus der jeweiligen Tabellenzeile wechseln können.

**„Bearbeiten“**

Diese Funktion öffnet die Stammdaten und Trassenverwaltung der betreffenden Anlage.

Beide Aktionen haben unterschiedliche Aufgaben und sind deshalb keine unnötige Doppelung.

Die globale Anlagenauswahl im Header bleibt ebenfalls bestehen und funktioniert unverändert.

Keine dieser funktionierenden Navigationsmöglichkeiten entfernen.

---

### 4. Anlagenformular logisch neu gestalten

Nutze das beigefügte Referenzbild für die gewünschte Anordnung.

Die Anlagenbearbeitung soll drei Hauptbereiche besitzen:

1. Stammdaten
2. Trassenverwaltung
3. Automatisch ermittelte Anlagenkennzahlen

Diese Bereiche sind fachlich zusammengehörig und sollen innerhalb einer gemeinsamen Anlagenansicht zugänglich sein.

Keine zusätzlichen Hauptmenüpunkte oder unnötigen Zwischenseiten entwickeln.

Dasselbe Gestaltungskonzept soll für das Anlegen und Bearbeiten einer Anlage gelten.

---

### 5. Bereich Stammdaten

Die bisherige Formularansicht verwendet teilweise viel zu große Eingabefelder.

Überarbeite sie kompakt und übersichtlich.

Vorgesehene Angaben, soweit fachlich und technisch vorhanden:

- Anlagenname
- Anlagenanschrift
- Anlagenstatus
- Optionale technische Anlagenleistung in kW
- Optionale technische Hinweise
- Weitere bereits vorhandene Anlagenstammdaten

Verwende auf Desktop eine sinnvolle horizontale Feldanordnung.

Beispiel:

**Zeile 1:**
Anlagenname | Anlagenstatus

**Zeile 2:**
Straße und Hausnummer | PLZ | Ort

**Zeile 3:**
Technische Hinweise | Optionale Anlagenleistung

Die konkreten Feldgrößen sollen sich am Inhalt orientieren.

Ein Feld für kurze technische Hinweise darf nicht ohne Grund eine riesige Fläche belegen.

Mehrzeilige Eingaben nur dann verwenden, wenn tatsächlich längere Texte vorgesehen sind.

Bestehende Daten korrekt übernehmen.

Falls für strukturierte Adressfelder eine Änderung der vorhandenen Datenstruktur erforderlich wäre, zunächst Auswirkungen prüfen und dokumentieren. Keine automatische verlustbehaftete Umwandlung bestehender Anschriften.

Keine unnötigen Stammdatenfelder ergänzen.

---

### 6. Trassen direkt innerhalb der Anlage verwalten

Eine Trasse gehört genau zu einer Nahwärmeanlage.

Trassen werden normalerweise einmalig eingerichtet und danach nur gelegentlich bearbeitet.

Deshalb gehört die Trassenverwaltung direkt in die Anlagenansicht.

Gewünschte Darstellung:

Eine kompakte Tabelle mit:

- Trassennummer beziehungsweise Kennung
- Bezeichnung
- Anzahl Hausanschlüsse
- Anzahl zugeordneter Verträge
- Bearbeitungsmöglichkeit

Darüber oder daneben:

**„Neue Trasse“**

Das Anlegen einer Trasse soll direkt innerhalb dieses Bereichs möglich sein, beispielsweise über eine kompakte Eingabezeile oder einen kleinen Editor.

Kein umfangreiches separates Formular erforderlich.

Bestehende Trassen können dort bearbeitet werden.

Eine Trasse darf nicht unkontrolliert gelöscht werden, wenn bereits Anschlüsse oder andere relevante Datensätze zugeordnet sind.

Gefährliche Aktionen dürfen nicht als ungeschützte Löschsymbole ausgeführt werden.

Die bestehenden Berechtigungen bleiben unverändert.

### Neue Anlage anlegen

Beim Anlegen einer neuen Anlage darf der Trassenbereich zunächst leer sein.

Er soll einen verständlichen Leerzustand und die Möglichkeit zur Anlage der ersten Trasse bieten.

Falls die Anlage zuerst gespeichert werden muss, darf dieser Ablauf verwendet werden.

Alternativ ist eine gemeinsame Speicherung von Anlage und Trassen möglich, sofern sie einfach und transaktional sicher umgesetzt werden kann.

Keine unnötig komplexe Zwischenspeicherung entwickeln.

---

### 7. Automatisch berechnete Zahlen – keine doppelte Eingabe

**Verbindliches Grundprinzip: Eine Information, eine Quelle.**

Die Anlagenverwaltung soll keine Zahlen manuell erfassen, die sich bereits eindeutig aus vorhandenen Datensätzen ergeben.

Beispiel:

Die Trasse „Nord“ wird einmal angelegt.

Später werden fünf Hausanschlüsse dieser Trasse zugeordnet.

In der Trassenübersicht erscheint automatisch:

Nord – 5 Anschlüsse

Wird ein weiterer Anschluss zugeordnet, steigt die Anzeige automatisch auf sechs.

Es darf kein zusätzliches Eingabefeld für die Anzahl der Anschlüsse geben.

Gleiches gilt für:

- Anzahl der Trassen einer Anlage
- Gesamtzahl der Hausanschlüsse
- Hausanschlüsse je Trasse
- Anzahl der Verträge
- Verträge je Trasse

Die Werte müssen aus den vorhandenen Beziehungen ermittelt werden.

Die fachliche Zählweise muss eindeutig sein. Beispielsweise ist zu unterscheiden, ob alle oder nur aktive Verträge gezählt werden.

**Wichtig: Haushalte sind nicht automatisch identisch mit Hausanschlüssen.**

Eine eigenständige Haushaltszahl nur dann anzeigen, wenn sie zuverlässig aus vorhandenen Daten abgeleitet werden kann.

Keine fiktiven Haushaltszahlen einsetzen.

Die technische Anlagenleistung in kW ist dagegen ein manuell gepflegtes technisches Stammdatum, sofern sie im Datenmodell vorgesehen und bekannt ist.

Eine manuell erfasste Anlagenleistung darf nicht als automatisch berechnete Kennzahl ausgegeben werden.

---

### 8. Bereich Anlagenkennzahlen

Erstelle eine kompakte Übersicht der tatsächlich verfügbaren Kennzahlen.

Insbesondere:

- Trassen
- Hausanschlüsse
- Verträge

Weitere Kennzahlen nur bei vorhandenem fachlichem Nutzen und gesicherter Datenbasis.

Die Kennzahlen dienen ausschließlich zur Information.

Keine bearbeitbaren Eingabefelder.

Keine überdimensionierten Dashboard-Karten.

Keine bloßen Nullwerte als scheinbar belastbare Informationen anzeigen, wenn die zugrunde liegenden Daten noch nicht erfasst werden können.

Bei einer neu angelegten Anlage dürfen korrekt ermittelte Zählwerte selbstverständlich null sein.

---

### 9. Bedienbarkeit und Informationsarchitektur

Die Anwendung ist Desktop-First.

Nutze die vorhandene Bildschirmbreite intelligent.

Gewünscht sind:

- Kompakter Seitenkopf
- Sinnvolle horizontale Formularanordnung
- Logisch zusammengehörige Bereiche
- Übersichtliche Trassentabelle
- Klar erkennbare Aktionen
- Möglichst wenig unnötiges Scrollen
- Keine doppelt erfassten Informationen
- Keine redundanten Bearbeitungsabläufe

Aber ausdrücklich:

**Nicht möglichst viele Buttons und Felder auf engstem Raum zusammenquetschen.**

Lesbarkeit, Verständlichkeit und menschliche Bedienbarkeit haben Vorrang vor maximaler Informationsdichte.

Pro Bereich eine klare Hauptaktion vorsehen.

Seltene Aktionen dürfen in einem sinnvoll beschrifteten Kontextmenü stehen, dürfen aber nicht unnötig versteckt werden.

---

### 10. Datenmodell und Berechtigungen erhalten

Die vorhandene relationale Struktur bleibt bestehen.

Insbesondere:

- Anlagen sind eigenständige Datenobjekte.
- Trassen gehören zu Anlagen.
- Anschlüsse bleiben eigenständige Datenobjekte.
- Verträge bleiben eigenständige Datenobjekte.
- Bestehende UUIDs bleiben erhalten.
- Historische Zuordnungen bleiben erhalten.

Keine Änderung der Abrechnungslogik.

Keine Änderung der Joomla-API.

Keine Änderung des Sicherheitsmodells.

Sämtliche Zugriffe und Änderungen müssen weiterhin serverseitig anhand der Anlagenberechtigungen geprüft werden.

Keine destruktiven Migrationen.

---

### 11. Verbindliche Tests

Prüfe mindestens:

1. Neue Anlage anlegen.
2. Bestehende Anlagenstammdaten bearbeiten.
3. Anlage unmittelbar aus der Übersicht bearbeiten.
4. Keine Radiobutton-Auswahl mehr erforderlich.
5. „Anlage auswählen“ bleibt pro Tabellenzeile vorhanden.
6. „Anlage auswählen“ öffnet weiterhin die Vertragsverwaltung der betreffenden Anlage.
7. Globale Anlagenauswahl im Header funktioniert unverändert.
8. Neue Trasse innerhalb einer Anlage anlegen.
9. Bestehende Trasse bearbeiten.
10. Fremde Trassen können nicht zugeordnet werden.
11. Bestehende Trassen mit Zuordnungen werden vor unzulässiger Löschung geschützt.
12. Anzahl Hausanschlüsse wird automatisch ermittelt.
13. Anzahl Verträge wird korrekt berechnet.
14. Bestehende Anlagen- und Vertragsdaten bleiben erhalten.
15. Bestehende Themefarben bleiben unverändert.
16. Bestehende Berechtigungen bleiben wirksam.

Führe die Tests tatsächlich aus.

---

### 12. Visuelle Abnahme

Vergleiche die überarbeitete Anwendung mit dem beigefügten Referenzbild.

Achte besonders auf:

- Informationsanordnung
- Kompaktheit
- Gruppierung
- Formularbreiten
- Trassenverwaltung
- Kennzahlen
- Verständliche Aktionen

**Prüfe ausdrücklich, dass die Farbgebung der bestehenden Anwendung erhalten geblieben ist.**

Die Referenzfarben sind kein Bestandteil der Umsetzung.

Erstelle nach Möglichkeit Browser-Screenshots bei:

- 1440 × 900
- 1920 × 1080

Vergleiche die tatsächliche Darstellung mit den bisherigen Screenshots.

Keine Prüfungen als erfolgreich melden, die nicht ausgeführt wurden.

---

### 13. Erwartetes Ergebnis

Nach der Umsetzung:

**Anlagenübersicht**
- Weiterhin kompakte Tabelle
- Keine Radiobuttons
- Direkte Bearbeitung je Anlage
- „Anlage auswählen“ bleibt je Zeile erhalten
- Globale Anlagenauswahl bleibt erhalten

**Anlage anlegen/bearbeiten**
- Kompakte Stammdaten
- Trassen direkt innerhalb der Anlagenansicht
- Automatisch berechnete Kennzahlen
- Keine redundanten Eingaben
- Klare Benutzerführung

**Gestaltung**
- Bestehendes Theme vollständig erhalten
- Keine Übernahme der Referenzfarben
- Intelligente Nutzung des verfügbaren Platzes

Dokumentiere abschließend:

- Geänderte Dateien
- UI-Änderungen
- Gegebenenfalls erforderliche Datenmodelländerungen
- Ausgeführte Tests
- Screenshots
- Noch offene Punkte

## Abschließende Regel

**Das beigefügte Bild ist eine Layout- und UX-Referenz, keine Theme-Vorlage.**

Übernimm die logische Anordnung, nicht die Farben.

Verbessere die bestehende Anwendung gezielt, ohne funktionierende Arbeitsabläufe zu entfernen oder zusätzliche Komplexität einzuführen.