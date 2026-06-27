# Apple Pen Reader

Apple Pen Reader is an HTML prototype for opening a PDF in the browser, drawing a freehand balloon/loop with Apple Pencil (with mouse fallback for desktop checks), using finger touch to pan or pinch-zoom the drawing, and extracting the PDF text enclosed by that loop.

## What it does

- Opens a local PDF from a browser file input.
- Extracts and keeps all PDF text in memory before showing the first page.
- Renders the selected page with PDF.js and provides previous/next page navigation with a current-page/total-page count.
- Places a transparent drawing canvas above the PDF page.
- Keeps the PDF display area hidden until a file is selected, then shows the page close to the top of the viewer.
- Lets the user draw a thin dashed closed outline around text.
- Uses finger touch for page pan and pinch-zoom without creating outline lines; outline drawing is reserved for Apple Pencil, with mouse input kept as a desktop fallback.
- Registers positioned text fragments in a coordinate map keyed by their unrounded X/Y placement points, ignores duplicate text fragments that share the same coordinate key and text, then uses a `Set` of hit coordinate keys during outline extraction so duplicate hits are not emitted.
- Places the extraction result and detected-text/search reference panel on the left, while keeping the PDF viewer on the right for side-by-side iPad use.
- Shows the text detected on the visible PDF page below the extraction result as a single vertical column of coordinate-keyed fragments, with each fragment's unrounded registered X/Y key beside the text.
- Overwrites the detected-text panel whenever the visible page text is refreshed, with a reset button for clearing it manually.
- Appends extracted text to the extraction result whenever an outline loop is completed, until the result reset button is pressed.
- Shows a trash button to the left of each extracted-text line so individual lines can be removed.
- Shows each extracted text item on its own line, ordered from top to bottom.
- Shows an optional debug overlay for text fragment rectangles and center points.
- Groups extracted fragments into rows using PDF.js line-end information and nearby Y coordinates, then joins each row in X order.

## Requirements

- A modern browser with JavaScript modules and pointer events.
- Network access to load PDF.js from the CDN used by `index.html`.
- iPad Safari is the primary target, but desktop browsers can be used with a mouse for quick checks.

## How to try it

1. Serve this directory with a local web server, for example:

   ```bash
   python3 -m http.server 8000
   ```

2. Open `http://localhost:8000/` in a browser.
3. Tap **ファイルを選択** and choose a PDF.
4. Use one finger to move the page or two fingers to pinch-zoom the page. Draw a balloon around text with Apple Pencil. On desktop browsers, a mouse can still be used as a fallback for quick checks.
5. If the PDF has multiple pages, use **前のページ** and **次のページ** while checking the page count shown as `current / total`.
6. Tap **文字位置を表示** if you want to inspect the rectangles and center points used for hit testing.
7. Check **検出したテキスト** below the extraction result if you want to confirm all text fragments found on the visible page in one vertical column with unrounded placement X/Y points beside each text item.
8. Tap **検出テキストを消す** if you want to clear the detected-text panel manually.
9. Finish drawing an outline and confirm the extracted text is appended to the extraction result automatically.
10. Tap the trash icon beside an extracted line when you want to remove only that line.
11. Tap **抽出結果をリセット** when you want to clear the accumulated extraction result.
12. Tap **囲み文字を抽出** if you want to append extraction for the current outlines manually.
13. Tap **囲み線を消す** to clear every outline.

## Implementation notes

The important part is keeping the PDF canvas and drawing canvas in the same browser coordinate space. `index.html` renders the first PDF page with PDF.js, overlays a second canvas for pointer input, stores the drawn outline points in canvas coordinates, maps finger touch gestures to CSS translate/scale transforms for panning and pinch-zooming, keeps Apple Pencil and mouse fallback input for outline drawing, keeps all PDF text items in memory before the page is shown, converts the saved text fragments for the visible page into rendered coordinates, uses PDF.js line-end hints plus Y-position grouping to preserve line breaks, shows the visible page text detected by PDF.js in the left-side result panel, and extracts fragments when either their center point is inside the outline or their rectangle overlaps the outline.

This keeps the prototype small and easy to run without Xcode. For production use, consider bundling PDF.js locally, adding page thumbnails or direct page-number input, supporting OCR for scanned PDFs, and smoothing or simplifying hand-drawn outlines.
