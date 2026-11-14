# UI-Neuaufbau – Vorrang, Abgleich und Arbeitsabläufe

Der neue Auftrag „Verbindlicher UI/UX-Neuaufbau“ hat ausdrücklich Vorrang vor dem
vorherigen UI/UX-Optimierungsauftrag und dessen laufenden, noch nicht gepushten
Änderungen. Kein zweiter paralleler Styleguide und keine doppelte Implementierung.

| Bisheriger Auftrag / Zwischenstand | Vorrangige neue Vorgabe |
|---|---|
| Kompakte Tabellen, Tokens, horizontale Filter | beibehalten und einmal zentral umsetzen |
| Fünf gleichberechtigte Anlagen-Unterbereiche | ersetzen durch Anlagen und Verträge; sonstige Stammdaten sekundär erreichbar |
| Desktop ab 1440 × 900, Zusatztest 1920 | ersetzen durch Tests 1280 × 800, 1440 × 900, 1920 × 1080, 2560 × 1440 |
| Maximal 1600 px breiter Arbeitsbereich | Listen nutzen die verfügbare Desktopbreite; kein pauschaler enger Container |
| Bestehende Workflows unverändert lassen | neue zentrale Vertragsakte und zusammenhängende Erstellung haben Vorrang |
| Keine Controller-/Workflow-Erweiterung | begrenzte sichere Erweiterungen für Formkoordination, Rückkehr und Anlagenbearbeitung ausdrücklich nötig |
| Mobilkarten, Tablet-/Mobiltests aus Originalbrief | nicht umsetzen; Desktop/Zoom/Keyboard sind maßgeblich |

## Zielkonzept vor Implementierung

Globaler Header mit Anlagenwahl und den Hauptbereichen Anlagen und Verträge.
Trassen ausschließlich unter Anlagen. Kunden-/Anschluss-/Zählerlisten bleiben
über sekundäre Stammdatenzugänge erreichbar, nicht als fünf Hauptbereiche.

A. Der Mitarbeiter wählt eine Anlage und öffnet Verträge. Er kann vorhandene
   Kunden/Anschlüsse auswählen oder im selben Formular neue erfassen, prüft die
   Vertragsdaten und speichert alles atomar. Anschließend öffnet sich die Akte.
B. Der Mitarbeiter findet einen Vertrag über Suchfelder/Filter/Sortierung und
   öffnet die Akte. Im Kundenbereich bearbeitet er Kontaktdaten und bleibt danach
   bei diesem Vertrag. Keine erneute Suche und kein Wechsel in ein Kundenmenü.
C. In der Akte sieht er Anschluss, Trasse und aktuellen Zähler. Neue Ablesungen
   werden dort erfasst; danach ist der aktualisierte Stand sichtbar. Komplexe
   Zählerwechsel bleiben geführt mit sicherer Rückkehr in dieselbe Akte.
D. Unter Anlagen bearbeitet ein zugeordneter Administrator Name, Anschrift und
   technische Hinweise. Trassen werden nur hier verwaltet; nie aus dem Vertrag
   heraus neu erfunden. Nicht verwendete Trassen dürfen nur nach bestätigter
   Aktion und Prüfung aktueller sowie protokollierter Zuordnungen entfernt werden.

## Modell-/Sicherheitsentscheidungen

Keine neue Tabelle und keine Migration nötig. Anlagen verwenden die vorhandenen
Felder name/address/technical_notes; Beschreibung bleibt Teil technischer Hinweise.
Inbetriebnahme/Status der Anlage sind bisher nicht modelliert und werden nicht
mit Anschlussdaten verwechselt oder ohne Fachentscheidung ergänzt. UUIDs bleiben.
Anlagenbearbeitung braucht Administratorrolle UND explizite Anlagenberechtigung.

Kunde, Kundenzuordnung, Anschluss, Vertrag, Zähler und Ablesungen bleiben getrennte
Modelle. Ein Formobjekt koordiniert ausschließlich die schon vorhandenen
Validierungen und Services in einer Transaktion; es berechnet keine neuen Regeln.
Vorhandene Kunden/Anschlüsse werden bei Wiederverwendung nicht überschrieben.
Trassen und vorhandene IDs werden immer über die autorisierte Anlage aufgelöst.

Rückkehr zur Akte ausschließlich über eine validierte Vertrags-ID im aktuellen
Anlagenscope, niemals über freie return_to-URLs. Zusätzlich muss der bearbeitete
Kunde/Anschluss/Zähler zu genau dieser Akte gehören. Inlinebearbeitung erfolgt
über bestehende Turbo-Komponenten; Fehler bleiben sichtbar und Eingaben erhalten.

Gemeinsame Kundendaten behalten die Prüfung aller Anlagenzuordnungen. Bestehende
Berechtigungen, Intervallconstraints, Audit, Korrekturketten und Daten bleiben.
Keine neue Abrechnungs-, Tarif-, Bank- oder Joomla-Funktion. Eine Trasse mit
bestehenden oder protokollierten Verwendungen darf nicht gelöscht werden.

## Prüfung

Vorher-Aufnahmen werden vom letzten veröffentlichten Git-Stand c2b7f50 mit
identischen synthetischen Daten für alle vier Desktopgrößen erstellt, nicht vom
halb fertigen Zwischenlayout. Danach gleiche Ansichten und Größen. Zusätzlich
Arbeitsabläufe A–D, Tastatur, Zoom, Langtexte, Berechtigungen, Kontextmanipulation,
Transaktionsrollback, Datenerhalt und Docker-Build/Start testen. Ergebnisse nur
nach tatsächlicher Ausführung dokumentieren.

## Nachgereichte Bildreferenz und Pilot-Abgrenzung (höchster Vorrang)

Die zuletzt übermittelte Bildreferenz konkretisiert den Vertragsteil als
Master-Detail-Arbeitsplatz: Hauptnavigation links, Anlagenwahl oben, horizontale
Filter, eigenständig scrollbare Vertragsliste links und Akte rechts. Auswahl lädt
nur die rechte Akte per Turbo. Liste/Filter bleiben erhalten, große Ergebnismengen
werden serverseitig begrenzt und beim Scrollen schrittweise nachgeladen. Keine
klassische Seitennummerierung in dieser Auswahlliste.

Die anschließende ausdrückliche Einschränkung gilt: **zunächst nur diesen einen
Vertragsarbeitsplatz umsetzen und visuell abnehmen**. Die zuvor entworfenen
seitenübergreifenden Umbauten, neue Vertragserstellungskoordination, Anlagen-
bearbeitung und Trassenentfernung sind zurückgestellt, nicht verloren. Der gesamte
Zwischenstand wurde vor der Abgrenzung als geprüftes Archiv außerhalb Git gesichert.
Diese Erweiterungen werden nicht stillschweigend mit dem Pilot ausgeliefert.

Bestehende Fachseiten und Erstellungsfunktionen bleiben erhalten. Kleine
kontextbezogene Kunden-/Anschlussänderungen und Ablesungen dienen unmittelbar der
Akte und sind Teil dieses Pilots. Kein Kunden-Hauptmenü. Die Übersicht zeigt die
wichtigen Daten gemeinsam; Details und komplexe Vorgänge dürfen eigene Ansichten
innerhalb des rechten Arbeitsbereichs öffnen. Keine leeren Abrechnungs-/Auswertungs-
Tabs aus der Referenz, solange die Funktionen nicht existieren.

## Fortsetzung nach Freigabe des Vertrags-Pilots

Beauftragt: gemeinsame Theme-Farben statt eigener Chrome-Farben; Anlagenübersicht
als auswählbare Tabelle mit Stammdatenbearbeitung und Wechsel in Verträge; jede
bestehende Suche als gemeinsame serverseitige Live-Suche (300 ms, Dropdown sofort).
Gemeinsame Layout-, Tabellen-, Feld- und Aktionskomponenten wiederverwenden.
Keine Migration: Leistungsfelder existieren nicht, daher Gesamtleistung ausdrücklich
„nicht erfasst“. Anlagenänderungen nur Administrator mit expliziter Zuordnung,
Transaktion und bestehendes Audit. Keine neuen Fachregeln oder Rechte aus Formularen.

## Anlagen und Trassen, strukturierte Anschriften (neuer Vorrang)

Referenz: PLANT_ROUTES_BRIEF.md. Bestätigt: Kennzahlen zählen alle Verträge,
auch Entwürfe/beendete/stornierte. Trassen-Verträge werden über die derzeitige
Anschlusszuordnung gezählt; keine rückwirkende Änderung historischer Verträge.
Direkte Bearbeitung statt Markierung. Anlage zuerst speichern, danach Trassen im
selben Arbeitsplatz. Trassenrechte unverändert: zugeordnete Verwaltungsbenutzer;
Anlagenstammdaten weiterhin nur zugeordnete Administratoren. Keine Löschfunktion.

Zusatzauftrag: getrennte Pflichtfelder Straße/Hausnummer, PLZ, Ort bei Anlagen,
Kunden und Hausanschlüssen, überall dieselbe Formularkomponente. Benutzer hat
bestätigt, dass nur entbehrliche Demodaten vorliegen und nichts erhalten werden
muss. Daher keine Freitext-Übergangslösung oder automatische Adresszerlegung.
Die Migration benennt address in street um, ergänzt postal_code/city und ersetzt
vorhandene Demoadressen ausdrücklich durch strukturierte Beispielwerte. Alle
übrigen Fachobjekte, UUIDs und Beziehungen bleiben unverändert. Neue DB-Checks und
Modellvalidierungen sichern vollständige Adressen. address ist anschließend nur
noch eine berechnete Textdarstellung, kein zweiter Speicherort. Suche und Seeds
werden auf die drei Spalten umgestellt. Kein Status-/Leistungsfeld, keine neue
Farbpalette, Abrechnung oder API-Änderung. Für einen Bestand mit echten Adressen
ist diese ausdrücklich für den aktuellen Demoaufbau bestimmte Migration ungeeignet.

Letzte Präzisierung: Trassensuche und ihr Beschreibungstext entfallen ausdrücklich.
Normale Trassenlisten zeigen keine Seitennavigation; nur bei mehr als 100 Trassen
bleibt eine begrenzte Folgeseite erreichbar. Keine Datensätze still abschneiden.

## Anlage löschen (beauftragt)

Rechts oben in der bestehenden Anlagenansicht für zugeordnete Administratoren.
Ausdrückliche Bestätigungsseite, danach DELETE mit kurzlebiger, an Benutzer,
Anlage und Änderungsstand gebundener Bestätigung. Ohne diese keine Entfernung.
Nur leere Anlagen: Trassen/Kundenzuordnungen/Anschlüsse/Verträge blockieren.
Bestehende unveränderliche Audit-Ereignisse referenzieren die Anlage per FK;
deshalb logische Löschung über deleted_at statt Löschen von Audit-Originalen.
Berechtigungen bleiben historisch erhalten, aber current_user.plants schließt
entfernte Anlagen aus. Alle Listen, Header, verschachtelte Ressourcen und direkten
Zugriffe nutzen damit weiterhin denselben serverseitigen Anlagenscope.
Keine neue Löschfarbe, kein neues JS-Framework, keine Kaskadenlöschung.

Schreibzugriffe innerhalb einer Anlage halten während der Änderung dieselbe
Anlagensperre wie die Löschung. So kann keine bereits gestartete Formularanfrage
nach dem Entfernen noch Datensätze in die verschwundene Anlage schreiben.

Die bestehenden atomaren Schreibdienste verwenden innerhalb der Anlagensperre
savepoints (requires_new), damit im Controller behandelte Validierungsfehler
weiterhin den gesamten jeweiligen Kunden-/Zähler-/Ablesevorgang zurückrollen.
Die fachlichen Regeln und Berechtigungen werden dabei nicht verändert.
