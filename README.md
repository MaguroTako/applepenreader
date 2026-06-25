# Apple Pen Reader

Apple Pen Reader is an HTML prototype for opening a PDF in the browser, drawing a freehand balloon/loop with Apple Pencil, touch, or mouse, and extracting the PDF text enclosed by that loop.

## What it does

- Opens a local PDF from a browser file input.
- Extracts and keeps all PDF text in memory before showing the first page.
- Renders the selected page with PDF.js and provides previous/next page navigation with a current-page/total-page count.
- Places a transparent drawing canvas above the PDF page.
- Keeps the PDF display area hidden until a file is selected, then shows the page close to the top of the viewer.
- Lets the user draw a thin dashed closed outline around text.
- Allows browser pinch zoom on the drawing area without creating unwanted lines.
- Extracts positioned text fragments whose center point is inside the outline or whose rectangle overlaps the outline.
- Shows the text detected on the visible PDF page below the extraction result.
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
4. Draw a balloon around text with Apple Pencil, touch, or mouse. Pinch with two fingers to zoom the page; pinch gestures do not create drawing lines.
5. If the PDF has multiple pages, use **前のページ** and **次のページ** while checking the page count shown as `current / total`.
6. Tap **文字位置を表示** if you want to inspect the rectangles and center points used for hit testing.
7. Check **検出したテキスト** below the extraction result if you want to confirm all text fragments found on the visible page.
8. Tap **囲み文字を抽出**.
9. Tap **線を消す** to reset the outline and result.

## Implementation notes

The important part is keeping the PDF canvas and drawing canvas in the same browser coordinate space. `index.html` renders the selected PDF page with PDF.js, updates previous/next buttons and the current-page/total-page count, overlays a second canvas for pointer input, styles the outline as a thin dashed line, stores the drawn outline points in canvas coordinates, waits for one-finger touch movement before drawing so two-finger pinch gestures can start without leaving stray lines, ignores active multi-pointer gestures, keeps all PDF text items in memory before the page is shown, converts the saved text fragments for the visible page into rendered coordinates, builds each text rectangle from its PDF.js baseline direction and font height without scaling its reported width twice, uses PDF.js line-end hints plus Y-position grouping to preserve line breaks, shows the visible page text detected by PDF.js below the extraction result, and extracts fragments when either their center point is inside the outline or their rectangle overlaps the outline.

This keeps the prototype small and easy to run without Xcode. For production use, consider bundling PDF.js locally, adding page thumbnails or direct page-number input, supporting OCR for scanned PDFs, and smoothing or simplifying hand-drawn outlines.
