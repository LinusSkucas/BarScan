//
//  StatusItemConfigurator.swift
//  BarScan
//
//  Created by Linus Skucas on 12/21/22.
//

import Cocoa
import Foundation
import SwiftUI
import UniformTypeIdentifiers

class StatusItem: NSResponder, NSServicesMenuRequestor, NSPopoverDelegate {
    var statusItem: NSStatusItem?
    var statusItemMenu = NSMenu()

    var popover: NSPopover?

    func setUpMenu(importMenuItem: NSMenuItem) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem?.button else { return }
        button.image = NSImage(systemSymbolName: "camera", accessibilityDescription: nil)

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 340, height: 120)
        popover.behavior = .transient
        popover.delegate = self

        self.popover = popover

        Task {
            importMenuItem.menu?.removeItem(importMenuItem)
            statusItemMenu.addItem(importMenuItem)
            statusItem?.menu = statusItemMenu
        }
    }

    // MARK: - Continuity Camera Stuff

    func readSelection(from pasteboard: NSPasteboard) -> Bool { // TODO: Refactor out non pasteboard things
        guard pasteboard.canReadItem(withDataConformingToTypes: NSImage.imageTypes) else { return false }
        let itemType = pasteboard.availableType(from: [.pdf, .png, NSPasteboard.PasteboardType("public.jpeg")])
        guard let itemType else {
            print("No image type")
            print(pasteboard.types)
            return false
        }

        let userURL = FileManager.default.homeDirectoryForCurrentUser
        do {
            let temporaryDirectoryURL = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: userURL, create: true)

            let itemData = pasteboard.data(forType: itemType)
            guard let itemData else { return false }

            let type = UTType(itemType.rawValue)!
            let name = "Item.\(type.preferredFilenameExtension!)"
            let temporaryURL = temporaryDirectoryURL.appending(component: name)

            try itemData.write(to: temporaryURL)
            displayResult(url: temporaryURL, type: type)
        } catch {
            print(error.localizedDescription) // TODO: Better error handling
            return false
        }
        return true
    }

    func displayResult(url: URL, type: UTType) {
        let view = DocumentListView(item: ImportedItem(fileType: type, url: url))
        guard let popover = popover,
              let statusItem = statusItem,
              let statusItemButton = statusItem.button,
              !popover.isShown else {
            popover?.performClose(nil)
            return
        }

        popover.contentViewController = NSHostingController(rootView: view)
        popover.show(relativeTo: statusItemButton.bounds, of: statusItemButton, preferredEdge: .minY)
        popover.contentViewController?.view.window?.becomeKey()
    }

    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        true
    }
}
