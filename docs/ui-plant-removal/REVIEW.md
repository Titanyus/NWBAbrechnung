# Anlage löschen und Rückkehr nach Speichern

Stand: 14.11.2026. Folgeauftrag nach 88fc0f3.

Rechts oben in der Anlagenansicht steht für zugeordnete Administratoren
„Anlage löschen“. Die Aktion öffnet eine eigene Bestätigungsansicht mit Name und
Anschrift. „Abbrechen“ verändert nichts. Erst „Löschen bestätigen“ sendet DELETE.
Die zehn Minuten gültige Bestätigung ist signiert und an Anlage, Benutzer und
Änderungsstand gebunden. Ohne gültige Bestätigung keine Entfernung. Das funktioniert
auch ohne einen ausschließlich clientseitigen JavaScript-Bestätigungsdialog.
Bestätigungswerte werden in den Rails-Logs gefiltert.

Trassen, Kundenzuordnungen, Hausanschlüsse und Verträge blockieren das Löschen.
Die Bestätigungsansicht erklärt die Sperre; auch der Server prüft vor dem Schreiben
erneut. Es gibt keine Löschkaskade. Die existierenden Audit-Ereignisse bleiben
unverändert erhalten, deshalb wird eine leere Anlage über `deleted_at` logisch
entfernt. Dazu entsteht ein neues Audit-Ereignis mit dem verantwortlichen Benutzer.

Entfernte Anlagen erscheinen für keinen Benutzer mehr in Listen oder Header-Auswahl.
Direkte und verschachtelte URLs sind über denselben Anlagenscope ausgeschlossen.
Berechtigungszuordnungen bleiben historisch gespeichert, erteilen aber keinen
Zugriff auf entfernte Anlagen. Der aktuelle Anlagenkontext wird nach Entfernung
bereinigt; ohne weitere berechtigte Anlagen zeigt der Header keinen leeren Wechsler.
Eine Wiederherstellungsoberfläche ist nicht Teil des Auftrags.

Anlagen-Schreibzugriffe und Entfernung verwenden dieselbe Anlagensperre, damit eine
bereits gestartete Formularanfrage nicht nach dem Entfernen noch Änderungen
schreibt. Die bisherigen atomaren Kunden-/Zähler-/Ableseoperationen verwenden
innerhalb dieser Sperre eigene Savepoints. Negative HTTP-Tests prüfen ausdrücklich,
dass Validierungsfehler weiterhin Stammdaten, Ablesungen und Audit zurückrollen.

„Anlage speichern“ führt bei Neuanlage und Änderung zur Anlagenübersicht zurück.
Für die anschließende Trassenbearbeitung wird die Anlage dort direkt über
„Bearbeiten“ geöffnet. Fehler beim Speichern erhalten weiterhin Formular und Werte.
Bestehende Buttons, Theme-Farben und UI-Komponenten werden wiederverwendet.

Ausgeführt:

- **90 Rails-Tests, 652 Assertions**, keine Fehler oder Fehlschläge.
- Bestätigung, Abbrechen, fehlende/manipulierte/abgelaufene/fremde Bestätigungen,
  geänderte Anlage, zwischenzeitlich angelegte Trasse, Rollen und Anlagenrechte,
  Audit-Erhalt, Ausschluss entfernter Anlagen und Schreibzugriffe danach.
- Browser: neue Anlage speichern → Übersicht, Änderung speichern → Übersicht,
  Löschen abbrechen, Löschen bestätigen, Listen-/Header-Ausschluss und direkte URL,
  belegte Anlage gesperrt. Vier Desktopgrößen ohne horizontalen Überlauf und ohne
  JavaScript-Fehler. Screenshots und `browser-checks.json` liegen hier.
- Bestehender Anlagen-/Trassen-Browserablauf nach Anpassung des Speicher-Rückwegs
  erfolgreich. Historische Screenshots des früheren Auftrags bleiben erhalten.
- RuboCop ohne Beanstandungen, Brakeman ohne Warnungen, Zeitwerk erfolgreich,
  aktueller Bundler-Audit ohne bekannte Schwachstellen.
- Docker-Build mit `compose.build.yaml` und Migration auf dem bisherigen lokalen
  Teststack erfolgreich. Vollständiger Browserablauf zusätzlich auf dem gebauten
  Image ohne Quellmount erfolgreich ausgeführt.

Neue Migration: `20261114000200_add_plant_deleted_at.rb`; keine bisherigen
Fachdaten werden entfernt. Dockhand weiterhin mit `compose.build.yaml` neu bauen
und ausspielen; `db:prepare` ergänzt das Feld automatisch.
