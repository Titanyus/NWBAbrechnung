# NWB Oberfläche in Figma

Dieses Paket erzeugt in Figma ein natives, bearbeitbares Dokument aus dem tatsächlichen
Rails-/Hotwire-UI. Es ist selbst keine `.fig`-Datei. Nach dem Import kann Figma das
Dokument normal speichern und über **File → Save local copy** als `.fig` ausgeben.

## Import

1. ZIP vollständig entpacken. Figma Desktop öffnen und ein leeres Design-Dokument anlegen.
2. **Plugins → Development → Import plugin from manifest…** wählen; die entpackte
   `manifest.json` auswählen. Je nach Figma-Version ist dies über Resources/Plugins erreichbar.
3. Das lokale Plugin **NWB Oberfläche importieren** starten.
4. Im Plugin die entpackte `nwb-ui.json` auswählen und **importieren** klicken.
   Full HD ist optional. Der Import kann wegen der vielen Textebenen etwas dauern.
5. Das Dokument speichern. Für eine native Übergabedatei **Save local copy** verwenden.

Entwicklungsplugins benötigen Figma Desktop und gegebenenfalls die entsprechenden
Organisationsrechte. Das Plugin nutzt keine Netzverbindung, Bibliothek oder externen Dienst.
Ein erneuter Import erzeugt zusätzliche Seiten und Definitionen; er aktualisiert keine
bestehenden Designs. Am besten in ein leeres Dokument importieren.

## Enthalten

- 22 Ansichten: elf tatsächliche Seiten bei 1440 × 900 und 1920 × 1080.
  Verträge (Übersicht/Anlegen), Anlagen (Übersicht/Anlegen/Bearbeiten/Details), Kunde,
  Anschluss, Zähler, Ablesung und Darstellung. Die Hauptansichten zeigen NWB hell.
- Editierbare Frames, Flächen, Rahmen, Texte und SVG-Vektoren; Scrollbereiche werden
  beschnitten. DOM-/CSS-Bezeichnungen und Raster-/Padding-Definitionen bleiben als
  Ebenennamen bzw. Plugin-Metadaten erhalten.
- Acht Variablensammlungen: NWB Billenhausen, Smaragd, Ozean, Schiefer × Hell/Dunkel.
  Farben und Maße sind aus dem Browser aufgelöst, einschließlich des Seitenhintergrunds.
  Pro Sammlung ein Modus, damit keine Mehrmodus-Lizenz erforderlich ist.
- Farbflächen sind dort, wo der berechnete Farbwert übereinstimmt, an Variablen des
  dargestellten NWB-Hell-Themes gebunden. Identische Farben können denselben Token
  verwenden. Der Import bildet keine vollständig semantische Theme-Umschaltung aller
  Ansichten ab; die anderen Theme-Definitionen stehen für die Weiterarbeit bereit.
- Vier Textstile und sechs wiederverwendbare Komponenten mit Auto Layout:
  primärer/sekundärer/Zeilen-Button, Eingabe, Status, Kasten. Diese sind ein Startsatz,
  keine vollständige Variantenbibliothek aller Zustände. Die importierten Ansichten
  enthalten eigenständige Ebenen, keine automatisch verknüpften Komponenteninstanzen.
- `design.tokens.json`: Design-Token-Austausch im W3C-DTCG-Stil (Farben/Dimensionen).
- `screenshots/`: PNG-Referenzen derselben Browseransichten, nummeriert wie der Export.
- `nwb-ui.json`: vollständiges Übergabeformat mit Quell-Commit, Geometrie und Definitionen.

## Grenzen der Konvertierung

Figma führt weder Rails noch Hotwire aus: Live-Suche, Berechtigungen, Speichern und
Infinite Scroll bleiben in der Anwendung. Die Ansichten zeigen den erfassten Zustand;
kein Prototyp-Flow und keine vollständige Liste aller Daten/Fehler-/Hoverzustände.
Scrollinhalte werden als Ebenen im beschnittenen Frame übernommen, nicht als interaktives
serverseitiges Nachladen. Browser-Details wie native Datums-/Dropdown-Icons, Pseudoelemente,
Textunterstreichung, Schatten und Fokuszustände werden nicht vollständig nachgebildet.

Browser-`system-ui` wird auf Inter, alternativ Arial/Noto Sans abgebildet; Schriftmetriken
können abweichen. Browserzeilen werden als einzelne editierbare Textzeilen übernommen.
Die Ansichten verwenden feste Browserpositionen, keine automatisch rekonstruierte
Auto-Layout-Hierarchie. Die sechs Basiskomponenten besitzen echtes Auto Layout.
PNG-Dateien sind die verbindliche visuelle Vergleichsreferenz. Vor Weitergabe Figma-Import
visuell prüfen. Der Import wurde ohne angeschlossene Figma-Sitzung entwickelt; ein
vollständiger Test in der Figma-Desktop-Anwendung steht noch aus.

Die exportierte Installation enthält ausschließlich synthetische Demodaten. Das
Exportskript meldet sich lokal an; Passwort, Cookies und Umgebungsdateien werden nicht
in das Paket geschrieben. Bei späteren Exporten echte Daten vorher ausschließen.

## Aktualisierung aus dem Repository

```sh
python3 scripts/export_figma.py --output /workspace/NWB-Figma-Export
```

Benötigt den gestarteten lokalen Rails-Stack, Playwright/Chromium sowie die synthetische
Fixture `/tmp/nwb-ui-fixture.json`. Andere Quelle über `--base`, `--env-file`, `--fixtures`.
`design/figma/capture.js` und die lokalen Plugin-Dateien sind die versionierten Quellen.
