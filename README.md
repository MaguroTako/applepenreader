# Apple Pen Reader

Apple Pen Reader is an HTML prototype for opening a PDF in the browser, drawing a freehand balloon/loop with Apple Pencil, touch, or mouse, and extracting the PDF text enclosed by that loop.

## What it does

- Opens a local PDF from a browser file input.
- Extracts and keeps all PDF text in memory before showing the first page.
- Renders the first page with PDF.js.
- Places a transparent drawing canvas above the PDF page.
- Lets the user draw a closed outline around text.
- Allows browser pinch zoom on the drawing area without creating unwanted lines.
- Extracts positioned text fragments whose center point is inside the outline or whose rectangle overlaps the outline.
- Shows the text detected on the visible PDF page below the extraction result.
- Shows an optional debug overlay for text fragment rectangles and center points.
- Groups extracted fragments with nearby Y coordinates into rows, then joins each row in X order.

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
4. Draw a balloon around text with Apple Pencil, touch, or mouse. Pinch with two fingers to zoom the page; pinch gestures do not create drawing lines.
5. Tap **文字位置を表示** if you want to inspect the rectangles and center points used for hit testing.
6. Check **検出したテキスト** below the extraction result if you want to confirm all text fragments found on the visible page.
7. Tap **囲み文字を抽出**.
8. Tap **線を消す** to reset the outline and result.

## Implementation notes

The important part is keeping the PDF canvas and drawing canvas in the same browser coordinate space. `index.html` renders the first PDF page with PDF.js, overlays a second canvas for pointer input, stores the drawn outline points in canvas coordinates, waits for one-finger touch movement before drawing so two-finger pinch gestures can start without leaving stray lines, ignores active multi-pointer gestures, keeps all PDF text items in memory before the page is shown, converts the saved text fragments for the visible page into rendered coordinates, shows the visible page text detected by PDF.js below the extraction result, and extracts fragments when either their center point is inside the outline or their rectangle overlaps the outline.

This keeps the prototype small and easy to run without Xcode. For production use, consider bundling PDF.js locally, adding multi-page navigation, supporting OCR for scanned PDFs, and smoothing or simplifying hand-drawn outlines.
