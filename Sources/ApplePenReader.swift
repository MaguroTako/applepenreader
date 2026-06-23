import SwiftUI
import PDFKit
import PencilKit
import UniformTypeIdentifiers

@main
struct ApplePenReaderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var document: PDFDocument?
    @State private var isImporterPresented = false
    @State private var extractedText = ""
    @State private var coordinator = PDFDrawingCoordinator()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PDFDrawingView(document: document, coordinator: coordinator)
                    .overlay {
                        if document == nil {
                            ContentUnavailableView(
                                "PDFを選択してください",
                                systemImage: "doc.richtext",
                                description: Text("PDFを開いて、Apple Pencilで文字を囲んでください。")
                            )
                        }
                    }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("抽出結果")
                        .font(.headline)
                    ScrollView {
                        Text(extractedText.isEmpty ? "まだ抽出されていません。" : extractedText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .frame(height: 120)
                }
                .padding()
                .background(.regularMaterial)
            }
            .navigationTitle("Apple Pen Reader")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("PDFを開く") {
                        isImporterPresented = true
                    }

                    Button("囲み文字を抽出") {
                        extractedText = coordinator.extractTextInsideDrawing()
                    }
                    .disabled(document == nil)

                    Button("線を消す") {
                        coordinator.clearDrawing()
                    }
                    .disabled(document == nil)
                }
            }
            .fileImporter(
                isPresented: $isImporterPresented,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                guard let url = try? result.get().first else { return }
                loadPDF(from: url)
            }
        }
    }

    private func loadPDF(from url: URL) {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        document = PDFDocument(url: url)
        coordinator.clearDrawing()
        extractedText = ""
    }
}

final class PDFDrawingCoordinator {
    weak var pdfView: PDFView?
    weak var canvasView: PKCanvasView?

    func clearDrawing() {
        canvasView?.drawing = PKDrawing()
    }

    func extractTextInsideDrawing() -> String {
        guard let pdfView, let canvasView else { return "" }
        return BalloonTextExtractor.extractText(pdfView: pdfView, drawing: canvasView.drawing)
    }
}

struct PDFDrawingView: UIViewRepresentable {
    let document: PDFDocument?
    let coordinator: PDFDrawingCoordinator

    func makeUIView(context: Context) -> PDFPencilContainerView {
        let view = PDFPencilContainerView()
        coordinator.pdfView = view.pdfView
        coordinator.canvasView = view.canvasView
        return view
    }

    func updateUIView(_ uiView: PDFPencilContainerView, context: Context) {
        uiView.pdfView.document = document
    }
}

final class PDFPencilContainerView: UIView {
    let pdfView = PDFView()
    let canvasView = PKCanvasView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configurePDFView()
        configureCanvasView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configurePDFView() {
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .systemBackground
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pdfView)

        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func configureCanvasView() {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .pencilOnly
        canvasView.tool = PKInkingTool(.pen, color: .systemBlue, width: 6)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(canvasView)

        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

enum BalloonTextExtractor {
    static func extractText(pdfView: PDFView, drawing: PKDrawing) -> String {
        guard let page = pdfView.currentPage,
              let outline = closedOutlinePath(on: page, pdfView: pdfView, drawing: drawing),
              let pageText = page.string,
              !pageText.isEmpty else {
            return ""
        }

        var selectedWords: [String] = []
        pageText.enumerateSubstrings(in: pageText.startIndex..<pageText.endIndex, options: [.byWords]) { word, range, _, _ in
            guard let word,
                  let selection = page.selection(for: NSRange(range, in: pageText)) else { return }

            let bounds = selection.bounds(for: page)
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            if outline.contains(center) {
                selectedWords.append(word)
            }
        }

        return selectedWords.joined(separator: " ")
    }

    private static func closedOutlinePath(on page: PDFPage, pdfView: PDFView, drawing: PKDrawing) -> CGPath? {
        let points = drawing.strokes.flatMap { stroke in
            stroke.path.map { pathPoint in
                pdfView.convert(pathPoint.location, to: page)
            }
        }

        guard points.count > 2 else { return nil }

        let path = CGMutablePath()
        path.move(to: points[0])
        points.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
}
