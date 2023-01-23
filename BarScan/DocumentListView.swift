//
//  DocumentListView.swift
//  BarScan
//
//  Created by Linus Skucas on 1/21/23.
//

import QuickLookThumbnailing
import SwiftUI

struct ItemThumbnailView: View {
    @State var itemThumbnail: NSImage? = nil
    var itemURL: URL

    var body: some View {
        if itemThumbnail == nil {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.secondary)
                .frame(width: 75.0, height: 90)
                .overlay(alignment: .center) {
                    ProgressView()
                        .controlSize(.large)
                }
                .alignmentGuide(.thumbnailButtonAlignmentGuide) { context in
                    context[.bottom]
                }
                .task {
                    do {
                        let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: QLThumbnailGenerator.Request(fileAt: itemURL, size: CGSize(width: 75, height: 90), scale: 1, representationTypes: .thumbnail))
                        itemThumbnail = thumbnail.nsImage
                    } catch {
                        print("error generating thumbnail")
                    }
                }
        } else {
            Image(nsImage: itemThumbnail!)
                .alignmentGuide(.thumbnailButtonAlignmentGuide) { context in
                    context[.bottom]
                }
        }
    }
}

struct DocumentListView: View {
    var item: ImportedItem
    @State var itemThumbnail: NSImage? = nil

    var body: some View {
        GroupBox {
            HStack(alignment: .top) {
                ItemThumbnailView(itemURL: item.url)

                VStack(alignment: .leading) {
                    Text("Imported Item")
                        .font(.title)
                        .fontDesign(.rounded)
                    Text(item.fileType.preferredFilenameExtension ?? "")
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack {
                        Button("Save As...") {
                            saveAs()
                        }
                        Spacer()
                        Button {
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                        .help("Drag the item to another app")
                        .disabled(true)
                        .foregroundColor(.secondary)
                        Button {
                            // detach popover
                        } label: {
                            Image(systemName: "pin")
                        }
                    }
                    .buttonStyle(.borderless)
                    .alignmentGuide(.thumbnailButtonAlignmentGuide) { context in
                        context[.bottom]
                    }
                }
                Spacer()
            }
        }
        .padding()
        .frame(width: 340, height: 120)
        .onDrag {
            let itemProvider = NSItemProvider(object: item.url as NSURL)
            return itemProvider // TODO: Get preview (use thumbnail)
        }
    }

    func saveAs() {
        let savePanel = NSSavePanel()
        let window = LinusWindow()
        
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.animationBehavior = .none

        savePanel.allowedContentTypes = [item.fileType]
        savePanel.beginSheetModal(for: window) { response in
            if response == .OK {
                guard let saveURL = savePanel.url else { return }
                print(saveURL.startAccessingSecurityScopedResource())
                try! FileManager.default.copyItem(at: item.url, to: saveURL)
                saveURL.stopAccessingSecurityScopedResource()
            }
        }
        
        savePanel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

class LinusWindow: NSWindow {
    override var alphaValue: CGFloat {
        get {
            0.0
        } set {
            super.alphaValue = newValue
        }
    }

    override var backgroundColor: NSColor! {
        get {
            .clear
        } set {
            super.backgroundColor = newValue
        }
    }

    override var isOpaque: Bool {
        get {
            false
        } set {
            super.isOpaque = newValue
        }
    }
}

struct DocumentListView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentListView(item: ImportedItem(fileType: .png, url: URL(fileURLWithPath: "/Users/linus/wide.png")))
    }
}

extension VerticalAlignment {
    private struct ThumbnailButtonAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.bottom]
        }
    }

    static let thumbnailButtonAlignmentGuide = VerticalAlignment(ThumbnailButtonAlignment.self)
}
