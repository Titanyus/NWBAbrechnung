# NWB Verwaltung – Vertrag direkt in der Vertragsübersicht anlegen

## Ausgangslage

Die Vertragsverwaltung wurde bereits als neue Master-Detail-Oberfläche umgesetzt:

- links scrollbare Vertragsliste
- rechts Vertragsakte des ausgewählten Vertrags
- Bearbeitung einzelner Bereiche inline innerhalb der Vertragsakte

Aktuell öffnet der Button **„Vertrag anlegen“** jedoch noch die alte, separate Vollseiten-Ansicht mit einem klassischen langen Formular.

Diese alte Ansicht passt nicht mehr zum neuen Bedienkonzept und soll ersetzt werden.

## Ziel

Ein neuer Vertrag soll direkt **innerhalb der bestehenden Vertragsübersicht** angelegt werden.

Das bedeutet:

- Kein Wechsel auf die alte Vollseiten-Maske
- Kein separates altes Formular außerhalb der Vertragsübersicht
- Stattdessen rechts in der Detailansicht / Vertragsakte ein Modus **„Neuen Vertrag anlegen“**
- Die linke Vertragsliste bleibt sichtbar
- Die neue Vertragserfassung orientiert sich an der bestehenden Inline-Bearbeitung innerhalb der Vertragsakte

Die Oberfläche soll konsistent zur neuen Vertragsverwaltung sein.

---

## 1. Bestehende Vertragsübersicht als Arbeitskontext beibehalten

Wenn der Benutzer auf **„Vertrag anlegen“** klickt:

- bleibt die Vertragsübersicht geöffnet
- die linke Vertragsliste bleibt sichtbar
- rechts wird statt einer bestehenden Vertragsakte ein Erfassungsmodus für einen neuen Vertrag angezeigt

Der Benutzer soll sich weiterhin im Kontext der aktuellen Anlage befinden.

Der globale Anlagenkontext bleibt erhalten.

Die alte separate Seite zum Anlegen eines Vertrags soll nicht mehr der Standardweg sein.

Falls sie technisch noch benötigt wird, zunächst nicht unkontrolliert löschen, aber aus dem normalen Bedienablauf entfernen.

---

## 2. Neuer Modus „Vertrag anlegen“ innerhalb der Vertragsakte

Die rechte Detailansicht soll beim Anlegen eines Vertrags logisch gegliedert sein.

Vorgesehene Bereiche:

1. Kunde / Rechnungsempfänger
2. Verbrauchsstelle / Anschluss
3. Wärmezähler
4. Vertragsdaten

Diese Bereiche sollen in der bestehenden Vertragsakten-Struktur dargestellt werden, nicht als altes Vollformular.

Die Gestaltung soll sich an der bestehenden Inline-Bearbeitung orientieren.

---

## 3. Kunde / Rechnungsempfänger

Der Benutzer muss zwei Möglichkeiten haben:

### A. Vorhandenen Kunden auswählen
- Such- und Auswahlmöglichkeit
- Suche nach Name, Kundennummer, Adresse
- Nur fachlich zulässige Datensätze anzeigen

### B. Neuen Kunden anlegen
- Inline-Formular direkt innerhalb der Vertragsakte
- gleiche Logik und möglichst gleiche UI-Struktur wie bei der bereits vorhandenen Inline-Bearbeitung von Kundendaten

Verwende nach Möglichkeit die bereits bestehenden Form-Partial- oder Service-Strukturen.

Keine doppelte Implementierung derselben Kundenfelder mit abweichender Validierung.

Der Benutzer soll bewusst zwischen „vorhanden auswählen“ und „neu anlegen“ wechseln können.

Nicht beide Varianten gleichzeitig unübersichtlich offen darstellen.

---

## 4. Verbrauchsstelle / Anschluss

Auch hier soll der Benutzer zwei Möglichkeiten haben:

### A. Vorhandenen Anschluss auswählen
- Auswahl nur innerhalb der aktuellen Anlage
- Suchbar nach Anschlussnummer, Adresse und Trasse
- Nur fachlich passende Anschlüsse anzeigen

### B. Neuen Anschluss anlegen
Inline-Formular innerhalb der Vertragsakte mit mindestens:

- Anschlussnummer
- Anschlussadresse
- Trasse
- Inbetriebnahmedatum
- technischer Status
- ggf. Bemerkungen, sofern im Datenmodell vorhanden

Die Trassenauswahl darf nur Trassen der aktuell ausgewählten Anlage enthalten.

Keine Trasse einer fremden Anlage darf auswählbar sein.

Wichtig:
Ein Anschluss bleibt technisch ein eigenständiges Datenobjekt.

Die Oberfläche darf nur den Anlegeprozess logisch bündeln, nicht das Datenmodell vermischen.

---

## 5. Wärmezähler logisch an den Anschluss koppeln

Ein Wärmezähler ist kein frei schwebendes Objekt, sondern gehört immer zum Anschluss.

Deshalb soll der Zählerbereich vom gewählten Anschluss abhängen.

### Wenn ein vorhandener Anschluss gewählt wird:
- vorhandenen aktiven Zähler anzeigen, sofern vorhanden
- falls kein aktiver Zähler vorhanden ist: Möglichkeit „Zähler anlegen“
- falls fachlich vorgesehen: Möglichkeit, einen neuen Zähler für diesen Anschluss zu erfassen

### Wenn ein neuer Anschluss angelegt wird:
- optional direkt im selben Ablauf einen neuen Zähler anlegen
- alternativ zunächst ohne Zähler speichern, falls das fachlich zulässig ist

Ein neuer Zähler soll inline angelegt werden können, ähnlich der bestehenden Inline-Bearbeitungslogik.

Erforderliche Felder, soweit im bestehenden Modell vorhanden:

- Zählernummer
- Einbaudatum
- Einheit
- ggf. Bemerkung

Kein Zähler darf einem falschen Anschluss zugeordnet werden.

Keine freie losgelöste Zählerauswahl ohne Bezug zum Anschluss.

---

## 6. Vertragsdaten

Die eigentlichen Vertragsdaten sollen in einem eigenen Bereich erfasst werden.

Mindestens:

- Vertragsnummer
- Vertragsbeginn
- Vertragsende
- Vertragsstatus
- Vertragsbemerkungen

Spätere Erweiterungen wie Tarifzuordnung bleiben möglich, sollen aber hier noch nicht unnötig vorgezogen werden, falls sie fachlich noch nicht umgesetzt sind.

Die Felder sollen kompakt und logisch angeordnet sein.

Keine unnötig hohe Einspalten-Maske.

---

## 7. UX-Vorgaben

Die neue Vertragserfassung soll sich an folgenden Grundsätzen orientieren:

- Kein Rückfall in die alte Vollformular-Ansicht
- Kontext bleibt innerhalb der Vertragsübersicht erhalten
- Logische Gruppierung statt technischer CRUD-Masken
- Vorhandene Datensätze bevorzugt auswählbar
- Neue Datensätze bei Bedarf direkt inline anlegbar
- Keine doppelte Dateneingabe
- Keine unnötigen Seitenwechsel
- Keine überdimensionierten Leerflächen
- Keine unlogische Vermischung eigenständiger Datenobjekte

Die rechte Seite darf ruhig ein strukturierter Arbeitsbereich sein, aber kein endloses Formular ohne Benutzerführung.

Wo sinnvoll, kann zwischen „vorhanden auswählen“ und „neu anlegen“ mit Tabs, Toggle oder klaren Auswahloptionen gearbeitet werden.

---

## 8. Konsistenz mit bestehender Inline-Bearbeitung

Die bestehende Inline-Bearbeitung in der Vertragsakte, beispielsweise bei den Kundendaten, ist als Vorbild zu verwenden.

Das gilt insbesondere für:

- visuelle Struktur
- Formularverhalten
- Speichern / Abbrechen
- Einbettung innerhalb der rechten Detailansicht
- Beibehaltung des restlichen Arbeitskontexts

Keine völlig andere Eingabelogik für den neuen Vertrag entwickeln.

---

## 9. Datenmodell und Fachlogik erhalten

Die vorhandene relationale Trennung bleibt bestehen.

Insbesondere:

- Kunde bleibt eigenständiges Objekt
- Anschluss bleibt eigenständiges Objekt
- Zähler bleibt eigenständiges Objekt
- Vertrag verknüpft diese Objekte fachlich
- Trassen gehören zur Anlage
- Zähler gehören zum Anschluss

Keine unnötigen Änderungen des Datenmodells.

Keine unkontrollierten Duplikate erzeugen.

Keine automatische Zusammenführung unterschiedlicher Datensätze.

Keine Änderungen an Abrechnungslogik oder Joomla-API.

---

## 10. Technische und fachliche Regeln

- Der neue Vertrag wird innerhalb des aktuellen Anlagenkontexts angelegt.
- Ein vorhandener Anschluss darf nur dann verwendbar sein, wenn er fachlich zur aktuellen Anlage gehört.
- Kunden können anlagenbezogene Zusatzdaten besitzen; bestehende Regeln beibehalten.
- Ein Zählerwechsel ist nicht dasselbe wie das einfache Anlegen eines Vertrags.
- Historische Zuordnungen dürfen nicht beschädigt werden.
- Bestehende Validierungen und Berechtigungen weiterverwenden.
- Alle Rechteprüfungen serverseitig durchsetzen.

---

## 11. Tests

Prüfe mindestens:

1. Klick auf „Vertrag anlegen“ öffnet nicht mehr die alte Vollseiten-Ansicht.
2. Neuer Vertrag wird innerhalb der Vertragsübersicht angelegt.
3. Vorhandenen Kunden auswählen.
4. Neuen Kunden inline anlegen.
5. Vorhandenen Anschluss auswählen.
6. Neuen Anschluss inline anlegen.
7. Trassenauswahl beim neuen Anschluss ist auf die aktuelle Anlage begrenzt.
8. Vorhandenen aktiven Zähler des Anschlusses anzeigen.
9. Neuen Zähler inline erfassen.
10. Vertrag mit vorhandenem Kunden und vorhandenem Anschluss anlegen.
11. Vertrag mit neuem Kunden und neuem Anschluss anlegen.
12. Keine unzulässige Zuordnung fremder Anlagen-Datensätze.
13. Speichern und Abbrechen funktionieren sauber.
14. Vertragsliste links bleibt erhalten.
15. Bestehende Inline-Bearbeitungen bleiben funktionsfähig.
16. Bestehende Themefarben und Layoutsprache bleiben erhalten.

Tests tatsächlich ausführen und dokumentieren.

---

## 12. Visuelle Abnahme

Nutze die vorhandenen Screenshots:

- Bild 1: bisherige alte Vertrags-Neuanlage
- Bild 2: neue Vertragsübersicht / gewünschter Arbeitskontext
- Bild 3: bestehende Inline-Bearbeitung als Vorbild

Das Ziel ist:

- Die alte Maske aus Bild 1 soll nicht mehr der normale Arbeitsweg sein.
- Die neue Vertragserfassung soll sich visuell und funktional in Bild 2 und 3 einfügen.

Besonders wichtig:
Die rechte Detailansicht soll sich wie eine natürliche Erweiterung der Vertragsakte anfühlen.

---

## 13. Erwartetes Ergebnis

Nach der Umsetzung soll Folgendes gelten:

- „Vertrag anlegen“ passiert direkt in der Vertragsübersicht
- Bestehende Kunden können ausgewählt werden
- Neue Kunden können inline angelegt werden
- Bestehende Anschlüsse können ausgewählt werden
- Neue Anschlüsse können inline angelegt werden
- Zähler können im Anschlusskontext angezeigt oder neu angelegt werden
- Die Bedienung bleibt logisch, kompakt und konsistent
- Das Datenmodell bleibt sauber getrennt
- Die Vertragsübersicht bleibt der zentrale Arbeitsplatz

**Grundsatz: Nicht auf eine alte separate Eingabemaske wechseln, sondern den neuen Vertrag dort anlegen, wo die tägliche Arbeit stattfindet – in der Vertragsübersicht selbst.**