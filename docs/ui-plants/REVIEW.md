# Anlagenübersicht und gemeinsame Live-Suche

Stand: 14.11.2026. Folgeauftrag nach Freigabe der Vertragsverwaltung.

## Ergebnis und gemeinsame Komponenten

Anlagen erscheinen als kompakte Tabelle mit Name, Adresse, Anzahl Anschlüsse,
Trassen und Verträge sowie Gesamtleistung. Zähler-/Leistungsdaten wurden nicht
verwechselt: Es existiert weder an Anlagen noch Anschlüssen ein Leistungsfeld.
Die Spalte sagt daher „nicht erfasst“; keine neue Berechnung oder Migration.

Eine Zeile bzw. ihr Radiobutton markiert die Anlage. Administratoren können die
markierte Anlage über die gemeinsame Aktion „Anlage bearbeiten“ öffnen; ohne
Auswahl bleibt die Aktion deaktiviert. „Neue Anlage anlegen“ verwendet dasselbe
Formular mit denselben Feld-/Fehler-/Aktionskomponenten. „Anlage auswählen“ pro
Zeile verwendet exakt die vorhandene autorisierte Anlagenwahl des Headers und
öffnet die Vertragsverwaltung. Der Namenslink öffnet die vorhandenen Anlagendetails
mit dem Zugang zur Trassenverwaltung. Trassen bleiben innerhalb der Anlage.

Für beide Hauptbereiche gibt es dasselbe Layout, dieselbe Navigation und dieselben
CSS-Komponenten. Kopf- und Seitenleiste verwenden `--header`/`--header-text`, die
Markierung `--accent`/`--accent-text`. Beim NWB-Theme sind das vorhandenes Grün und
Gold. Auch Statusanzeigen und Rahmen verwenden bestehende Theme-Variablen.
Keine zusätzlichen Hexfarben in `admin_contracts.css`, keine neue Bibliothek.
Gemeinsam verwendet: Seitenkopf, Tabelle, Feldgruppen, Fehlerausgabe, Formular-
und Buttonstile, Theme-Tokens und Live-Suche. Keine Komponenten je Einzelfeld.

## Live-Suche

Alle bisher vorhandenen Suchen verwenden denselben Stimulus-Controller und
`ui_search_data`: Anlagen, Verträge, Kunden, Anschlüsse und die Suche vorhandener
Kunden bei der Neuanlage. Text nach 300 ms Tipppause, Dropdowns sofort. Vertragssortierung
ist Bestandteil desselben Formulars, damit sie keinen aktuellen Suchtext verliert.

Turbo aktualisiert die jeweilige Ergebnisregion. Fokus und Textauswahl werden
wiederhergestellt. Frühere Anfragen werden abgebrochen; überholte Antworten dürfen
keine neue Eingabe verdrängen. Explizite Navigation wie Filter-Reset hat Vorrang
vor einer wartenden Suche. Enter und Suchbutton funktionieren weiterhin als
Fallback. Kein Reload der ganzen Seite, keine clientseitige Suche im Teilbestand.
Bei der Kundenzuordnung bleibt das ungespeicherte Neuerstellungsformular außerhalb
der Suchregion und wird deshalb nicht ersetzt.

Anlagen und bestehende Stammdatenlisten bleiben bei maximal 100 Einträgen pro
Seite; Suche gilt vor dieser Begrenzung. Vertragsliste weiterhin 30 je Nachladung.
Anlagenzähler werden in drei gruppierten SQL-Abfragen für die sichtbaren Anlagen
ermittelt, ohne Join-Vervielfachung oder eine Anfrage pro Tabellenzeile.

## Rechte und Datenerhalt

Anlagen ausschließlich über `current_user.plants`. Stammdatenänderung verlangt
zusätzlich Administratorrolle. Ausschließlich Name, Adresse und technische Hinweise
sind freigegeben. Transaktion, Zeilensperre und bestehendes Audit protokollieren
Änderungen; UUID, Betreiber, Beziehungen und historische Originale bleiben erhalten.
Keine Datenbankschema-, Geschäftsregel- oder Dependency-Änderung.

## Nachweise

- Rails: 74 Tests, 480 Assertions, keine Fehler/Fehlschläge. Neue Prüfungen für
  korrekte Aggregatzähler, begrenzte Anlagenliste mit Suche jenseits der ersten
  100 Einträge, fremde/revozierte Anlagenrechte, fehlende Administrator-
  rolle, Manipulation gesperrter Felder, Audit und Validierungsfehler.
- Browser: vier Desktopgrößen (1280 × 800, 1440 × 900, 1920 × 1080, 2560 × 1440),
  Tastaturmarkierung/Bearbeitung/Speicherung, Wechsel in die Akte, alle bestehenden Suchen,
  Dropdowns, Fokus und ein Request für eine Tippfolge. Kontrolliert verzögerte
  frühere Suchantwort und Reset während wartender Suche. Ungespeicherte Daten im
  Kunden-Neuerstellungsformular bleiben erhalten. Keine JavaScript-Fehler.
- Acht Theme-/Modus-Kombinationen: Header und Seitenleiste entsprechen jeweils der
  vorhandenen Headerfarbe. Kein horizontaler Seitenüberlauf in den vier Größen.
- Bestehende Vertrags-Browserregression weiterhin erfolgreich: begrenzte Nachladung,
  Scroll-/Filtererhalt, Inlineänderung, Ablesefehler und anschließende Speicherung.
- RuboCop ohne Beanstandung, Brakeman ohne Warnungen, Zeitwerk erfolgreich,
  aktueller Bundler-Audit ohne bekannte Schwachstellen.
- Docker-Build über `compose.build.yaml` mit Cloud-CA-Override, Start ohne Quellmount,
  Login und Live-Suche im gebauten Image geprüft. Testbestand vor/nach Update
  unverändert: 3 Anlagen, 3 Kunden, 3 Verträge, 15 Ablesungen.

Browserprotokoll: `browser-checks.json`. Nachher-Aufnahmen beider Hauptansichten:
`screenshots/after`. Vorher-Aufnahmen der unveränderten bisherigen Anlagenkarten
wurden aus dem bereits vorhandenen synthetischen UI-Prüfarchiv übernommen:
`screenshots/before` (small=1280, desktop=1440, fullhd=1920, wide=2560).
Es handelt sich nicht um neue Vorher-Aufnahmen nach dem Umbau. Die drei Anlagen
und ihre Namen/Adressen sind identisch; die bisherige Ansicht enthielt keine Zähler.
Die bestehenden Vertrags-Pilotbilder bleiben als historischer Prüfstand erhalten.
Ein Ablauf der Anmeldung während einer Live-Suche führt zur vollständigen
Anmeldeseite, statt eine fehlende Ergebnisregion anzuzeigen.

Reproduktion: `python3 scripts/plant_live_search_smoke.py` gegen den lokalen
synthetischen Entwicklungsstack mit `.env` und `/tmp/nwb-ui-fixture.json` aus dem
vorhandenen `scripts/ui_fixture.rb`. Die Browserprüfung speichert nur synthetische
Anlagendaten. Kein vollständiges Accessibility-Audit; keine zusätzliche Mobil-UI.

Dockhand: bestehenden Git-Stack auf `main` aktualisieren, mit `compose.build.yaml`
neu bauen und ausspielen. Umgebungsvariablen und Datenpfade beibehalten.

Die getrennte große Demo-Installation wurde in diesem Durchlauf nicht erneut
geprüft. Die Begrenzung und Vollbestandssuche sind stattdessen mit 101 zusätzlichen
synthetischen Anlagen im Integrationstest belegt; Installationstrennung bleibt
unverändert. Der bestehende Mehrinstallations-Browsertest wurde lediglich an den
neuen Tabellen-Selektor angepasst.
