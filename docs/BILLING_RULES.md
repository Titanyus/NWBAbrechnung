# Entschiedene Abrechnungsregeln

Diese Regeln sind Anforderungen, noch keine implementierte Abrechnung.

- Jahresabrechnung; Verbrauch aus belegten Zählerstandsdifferenzen einschließlich dokumentierter Zählerwechsel.
- Jede unterjährige Änderung verbrauchsabhängiger Preise braucht eine passende Zwischenablesung zum Stichtag. Fehlt sie, bleibt die Freigabe gesperrt.
- Keine Schätzung, saisonale Gewichtung oder automatische kalendertägliche Verteilung von Verbrauch.
- Kostenfreie verbrauchsabhängige Zeiträume brauchen ebenfalls geeignete Ablesungen.
- Reine Grundpreisänderungen/feste Gutschriften brauchen keine Verbrauchsablesung, aber freigegebene Berechnungsregeln.
- Abschläge gleichmäßig auf ausdrücklich festgelegte Termine verteilen. Plan und tatsächlich eingegangene Zahlungen getrennt speichern.
- Geld ausschließlich als exakte Dezimalwerte; Rundungsreihenfolge noch offen, keine versteckte Float-Konvertierung.
- Tarifversionen und freigegebene Abrechnungsoriginale historisch erhalten. Änderungen als explizite Korrektur.
- Entgeltminderung, Rechnungskorrektur, eigenständige Entschädigung und Rückzahlung getrennt behandeln. Keine einheitliche steuerliche Annahme.
- Keine Bankkommunikation/SEPA-Einreichung. Export erst nach Auswahl externer Banksoftware.
- PDF und XML später aus demselben freigegebenen Datensatz. ZUGFeRD erst nach unabhängigen EN-16931-/XML- und PDF/A-3-Prüfungen als gültig bezeichnen.

Vor Umsetzung werden Formeln mit anonymisierten historischen Excel-Beispielen dokumentiert und durch Referenztests belegt. Es liegen noch keine solchen Dateien vor.
