# Apple Pen Reader

Apple Pen Reader is an HTML prototype for opening a PDF in the browser, drawing a freehand balloon/loop with Apple Pencil (with mouse fallback for desktop checks), using finger touch to pan or pinch-zoom the drawing, and extracting the PDF text enclosed by that loop.

## What it does

- Opens a local PDF from a browser file input inside the PDF tab.
- Adds a **配線リスト** tab with a 4-column, 100-row wiring table for checking wiring entries, highlights the touched cell with a red border while restoring the previous cell border, shows registered **Symbol** strings as tappable tags on a single click/tap, allows keyboard entry in every wiring-list cell including **Symbol** cells with a double click/tap, and copies a tapped extraction-result row into the selected red-bordered cell.
- Adds a **部品リスト** tab with a 2-column, 100-row parts table headed **Device** and **TypeName**, and registers each unique value copied into the wiring-list **Device** column into the first empty parts-list **Device** cell.
- Extracts and keeps all PDF text in memory before showing the first page.
- Renders the selected page with PDF.js inside a PDF tab that also contains the file input, extraction controls, debug toggle, previous/next page navigation, and a current-page/total-page count.
- Places a transparent drawing canvas above the PDF page.
- Keeps the PDF display area hidden until a file is selected, then shows the page close to the top of the viewer.
- Lets the user draw a thin dashed closed outline around text.
- Uses finger touch for page pan and pinch-zoom without creating outline lines; outline drawing is reserved for Apple Pencil, with mouse input kept as a desktop fallback.
- Registers positioned text fragments in a coordinate map keyed by their unrounded X/Y placement points, ignores duplicate text fragments that share the same coordinate key and text, then uses a `Set` of hit coordinate keys during outline extraction so duplicate hits are not emitted.
- Keeps the expanded extraction result and detected-text/search reference panel visible on the left while the PDF tab on the right focuses on viewing and drawing.
- Shows the text detected on the visible PDF page below the extraction result as a single vertical column of coordinate-keyed fragments, with each fragment's unrounded registered X/Y key beside the text.
- Overwrites the detected-text panel whenever the visible page text is refreshed, with a reset button for clearing it manually.
- Appends extracted text to the extraction result whenever an outline loop is completed, until the result reset button is pressed.
- Shows a `↕` drag handle and a visible trash button to the left of each extracted-text row so individual rows can be reordered or removed.
- Shows each extracted text fragment as its own row, ordered from top to bottom, and enables text editing after a double tap.
- Shows an optional debug overlay for text fragment rectangles and center points.
- Lists extracted fragments one per row in Y/X order.

## Requirements

- A modern browser with JavaScript modules and pointer events.
- Local PDF.js files included under `vendor/pdfjs/4.10.38/`; no network access is required after checkout.
- iPad Safari is the primary target, but desktop browsers can be used with a mouse for quick checks.

## How to try it

1. Serve this directory with a local web server, for example:

   ```bash
   python3 -m http.server 8000
   ```

2. Open `http://localhost:8000/` in a browser.
3. Open the **PDF** tab, tap **ファイルを選択**, and choose a PDF.
4. Open the **配線リスト** tab when you want to view the 4-column, 100-row wiring table. Tap a wiring-list cell to mark its border red; tapping another cell restores the previous cell and marks the new one. Double-tap a wiring-list cell with a finger when you want to type with the iPad software keyboard; Apple Pencil/stylus taps select cells but do not open editing. Single-click/tap a **Symbol** cell to show registered strings as tags and select one; double-click/tap the cell when you want to type another value with the iPad software keyboard.
5. Open the **部品リスト** tab when you want to view the 2-column, 100-row parts table with **Device** and **TypeName** headings.
6. Use one finger to move the page or two fingers to pinch-zoom the page. Draw a balloon around text with Apple Pencil. On desktop browsers, a mouse can still be used as a fallback for quick checks.
7. If the PDF has multiple pages, use **前のページ** and **次のページ** while checking the page count shown as `current / total`.
8. Tap **文字位置を表示** if you want to inspect the rectangles and center points used for hit testing.
9. Check **検出したテキスト** in the always-visible left panel if you want to confirm all text fragments found on the visible page in one vertical column with unrounded placement X/Y points beside each text item.
10. Tap **検出テキストを消す** if you want to clear the detected-text panel manually.
11. Finish drawing an outline and confirm the extracted text is appended to the extraction result automatically.
12. Tap an extracted row after selecting a red-bordered wiring-list cell to copy that extracted text into the cell. When the selected wiring-list cell is in the **Device** column, the same text is also added to the first empty **Device** cell in the parts list unless it is already registered. Double-tap an extracted row and edit the text when OCR/PDF extraction needs correction. Editing locks again when the row loses focus.
13. Drag the `↕` handle beside an extracted row when you want to move it.
14. Tap the `🗑` button beside an extracted row when you want to remove only that row.
15. Tap **抽出結果をリセット** when you want to clear the accumulated extraction result.
16. Tap **囲み文字を抽出** if you want to append extraction for the current outlines manually.
17. Tap **囲み線を消す** to clear every outline.

## Implementation notes

The important part is keeping the PDF canvas and drawing canvas in the same browser coordinate space. `index.html` keeps the extraction results visible on the left and keeps the PDF controls and viewer together in the PDF tab on the right, renders the first PDF page with PDF.js, overlays a second canvas for pointer input, stores the drawn outline points in canvas coordinates, maps finger touch gestures to CSS translate/scale transforms for panning and pinch-zooming, keeps Apple Pencil and mouse fallback input for outline drawing, keeps all PDF text items in memory before the page is shown, converts the saved text fragments for the visible page into rendered coordinates, uses PDF.js line-end hints plus Y-position grouping to preserve line breaks, shows the visible page text detected by PDF.js in the left-side result panel, and extracts fragments when either their center point is inside the outline or their rectangle overlaps the outline.

PDF.js is bundled locally in `vendor/pdfjs/4.10.38/` so the prototype can run offline after the repository is available on the device. This keeps the prototype small and easy to run without Xcode. For production use, consider adding page thumbnails or direct page-number input, supporting OCR for scanned PDFs, and smoothing or simplifying hand-drawn outlines.
