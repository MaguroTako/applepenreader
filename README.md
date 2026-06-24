# Apple Pen Reader

Apple Pen Reader is an HTML prototype for opening a PDF in the browser, drawing a freehand balloon/loop with Apple Pencil, touch, or mouse, and extracting the PDF text enclosed by that loop.

## What it does

- Opens a local PDF from a browser file input.
- Renders the first page with PDF.js.
- Places a transparent drawing canvas above the PDF page.
- Lets the user draw a closed outline around text.
- Extracts text items whose center points are contained by the outline.

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
4. Draw a balloon around text with Apple Pencil, touch, or mouse.
5. Tap **囲み文字を抽出**.
6. Tap **線を消す** to reset the outline and result.

## Implementation notes

The important part is keeping the PDF canvas and drawing canvas in the same browser coordinate space. `index.html` renders the first PDF page with PDF.js, overlays a second canvas for pointer input, stores the drawn outline points in canvas coordinates, and checks each PDF text item's rendered center point with a point-in-polygon test.

This keeps the prototype small and easy to run without Xcode. For production use, consider bundling PDF.js locally, adding multi-page navigation, improving text hit testing for partially overlapped words, supporting OCR for scanned PDFs, and smoothing or simplifying hand-drawn outlines.
