# Offene kaufmännische und betriebliche Entscheidungen

Vor Abrechnungsimplementierung erforderlich:

1. Anonymisierte historische Excel-Dateien inklusive erwarteter Ergebnisse und Sonderfälle.
2. Netto-/Bruttopreise, Umsatzsteuersätze und Gültigkeitszeiträume; steuerliche Behandlung jeder Rabatt-/Entschädigungsart.
3. Exakte Rundung: Modus, Stellen, Zeitpunkt pro Position/Gesamtrechnung sowie Restcent-Verteilung bei Abschlägen.
4. Periodengrenzen, Stichtagssemantik, Zeitanteile des Grundpreises (Tag/Monat, Schaltjahr), Vertrags-/Tarifüberlappungen.
5. Rechnungsnummernkreis, Rechnungsdatum, Fälligkeiten, Abschlagstermine, Verrechnung von Zahlungen/Guthaben und Korrekturverfahren.
6. Einheiten/Genauigkeit und Stichtage der Ablesungen, Ein-/Ausbauwerte, Zählerüberlauf und fehlerhafte/rückläufige Werte.
7. Bemessungsbasis, Kombinierbarkeit, Reihenfolge und Grenzen prozentualer/fester Rabatte; Genehmigungsrollen für Sammelaktionen.
8. Berechtigungen für Rechnungsprüfung/Freigabe (Vieraugenprinzip), Korrektur und Portalrückzug.

Vor Produktivbetrieb: Hosting/TLS, E-Mail/Passwortwiederherstellung/MFA, sichere initiale Benutzeranlage, Secret-Rotation, Backup-/Restore-Abnahme, Protokollzugriff und rechtlich abgestimmte Aufbewahrungs-/Löschregeln. Kein Rückschluss auf Datenschutzkonformität aus dem Grundaufbau.

Später: externe Banksoftware und Exportformat; konkretes ZUGFeRD-Profil und Version, Validator-Versionen und Referenzkorpus. Ruby-Bibliotheken werden erst im Rechnungsmodul anhand Pflegezustand und Validatornachweisen ausgewählt.

## Ergänzung nach Stammdatenverwaltung (Auftrag 02)

- Reichen Datum und ein effektiver Tageswert langfristig, oder braucht es Uhrzeiten
  für mehrere Zählerwechsel beziehungsweise Messungen am selben Tag?
- Welche Zahlungsarten und technischen Statuswerte sollen fachlich abschließend
  angeboten werden? Der Grundkatalog steht im Stammdatenentwurf.
- Zählerüberlauf und Gerätefehler brauchen freigegebene Regeln. Bisher werden
  Rückgänge nur begründet dokumentiert, nicht als berechneter Verbrauch behandelt.
- Gemeinsame Kundenstammdaten werden einmal geführt; eine feinere fachliche
  Delegation für deren Bearbeitung benötigt einen eigenen Berechtigungsauftrag.
