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
- Registers positioned text fragments in a coordinate map keyed by their unrounded X/Y placement points, ignores duplicate text fragments that share the same coordinate key and text, then uses a `Set` of hit coordinate keys during outline extraction so duplicate hits are not emitted.
- Shows the text detected on the visible PDF page below the extraction result as a single vertical column of coordinate-keyed fragments, with each fragment's unrounded registered X/Y key beside the text.
- Shows the extraction result as one text item per line, ordered from top to bottom.
- Shows an optional debug overlay for text fragment rectangles and center points.
- Keeps completed outline loops on the page until the clear button is pressed, and colors the most recent loop purple while older loops stay light blue.

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
7. Check **検出したテキスト** below the extraction result if you want to confirm all text fragments found on the visible page in one vertical column with unrounded placement X/Y points beside each text item.
8. Confirm the extraction result appears one item per line, ordered from top to bottom.
9. Tap **囲み文字を抽出**.
10. Tap **囲み線を消す** to clear every outline and reset the result.

## Implementation notes

The important part is keeping the PDF canvas and drawing canvas in the same browser coordinate space. `index.html` renders the selected PDF page with PDF.js, updates previous/next buttons and the current-page/total-page count, overlays a second canvas for pointer input, styles the outline as a thin dashed line, keeps completed outline loops on the page until the clear button is pressed, colors the newest loop purple and older loops light blue, stores the drawn outline points in canvas coordinates, waits for one-finger touch movement before drawing so two-finger pinch gestures can start without leaving stray lines, ignores active multi-pointer gestures, keeps all PDF text items in memory before the page is shown, converts the saved text fragments for the visible page into rendered coordinates, builds each text rectangle from its PDF.js baseline direction and font height without scaling its reported width twice, uses PDF.js line-end hints plus Y-position grouping to preserve line breaks, shows the visible page text detected by PDF.js as one vertical column below the extraction result with registered X/Y keys beside each item, stores fragments in a `Map` keyed by unrounded X/Y placement points, ignores repeated identical text at the same placement point, and during outline extraction records hit coordinate keys in a `Set` before joining the matching text one item per line so repeated hits do not duplicate output.

This keeps the prototype small and easy to run without Xcode. For production use, consider bundling PDF.js locally, adding page thumbnails or direct page-number input, supporting OCR for scanned PDFs, and smoothing or simplifying hand-drawn outlines.
