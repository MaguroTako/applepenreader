# Apple Pen Reader

Apple Pen Reader is a SwiftUI iPad prototype for opening a PDF, drawing a freehand balloon/loop with Apple Pencil, and extracting the PDF text enclosed by that loop.

## What it does

- Opens a PDF with `PDFKit`.
- Places a transparent `PencilKit` drawing surface above the PDF.
- Lets the user draw a closed outline around text on the visible page.
- Converts the drawn outline into PDF page coordinates.
- Extracts words whose bounding boxes are contained by the outline.

## Requirements

- iPadOS 17 or later
- Xcode 15 or later
- Swift 5.9 or later

## How to try it

1. Create a new iPad SwiftUI app in Xcode.
2. Add `Sources/ApplePenReader.swift` to the app target.
3. Set `ApplePenReaderApp` as the app entry point, or present `ContentView` from your existing app.
4. Run on an iPad or iPad simulator.
5. Tap **PDFを開く**, choose a PDF, draw a balloon around text, then tap **囲み文字を抽出**.

## Implementation notes

The important part is the coordinate conversion. `PDFView` displays pages in view coordinates, while `PDFSelection` word bounds are in PDF page coordinates. `BalloonTextExtractor` samples the PencilKit stroke path in overlay coordinates, converts each point through `PDFView.convert(_:to:)`, builds a closed `CGPath`, and checks each word selection's bounds center against that path.

For production use, consider adding multi-page selection handling, OCR for scanned PDFs, shape cleanup/smoothing, and better hit testing for text that partially overlaps the balloon edge.
