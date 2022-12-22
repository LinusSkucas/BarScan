//
//  StatusItemConfigurator.swift
//  BarScan
//
//  Created by Linus Skucas on 12/21/22.
//

import Foundation
import Cocoa

class StatusItem: NSResponder, NSServicesMenuRequestor {
    var statusItem: NSStatusItem?
    var statusItemMenu = NSMenu()
    
    func setUpMenu(importMenuItem: NSMenuItem) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem?.button else { return }
        button.image = NSImage(systemSymbolName: "camera", accessibilityDescription: nil)
        
        Task {
            importMenuItem.menu?.removeItem(importMenuItem)
            statusItemMenu.addItem(importMenuItem)
            statusItem?.menu = statusItemMenu
        }
    }
    
    // MARK - Continuity Camera Stuff
    override func validRequestor(forSendType sendType: NSPasteboard.PasteboardType?, returnType: NSPasteboard.PasteboardType?) -> Any? {
        if let pasteboardType = returnType,
            NSImage.imageTypes.contains(pasteboardType.rawValue) {
            return self
        } else {
            return super.validRequestor(forSendType: sendType, returnType: returnType)
        }
    }

    func readSelection(from pasteboard: NSPasteboard) -> Bool {
        guard pasteboard.canReadItem(withDataConformingToTypes: NSImage.imageTypes) else { return false }
        guard let image = NSImage(pasteboard: pasteboard) else { return false }
        
        testWritingPhoto(image: image)
//        self.imageView.image = image
        return true
    }
    
    func testWritingPhoto(image: NSImage) {
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let destinationURL = desktopURL.appending(component: "testPhoto.png")
        
        do {
            try image.pngWrite(to: destinationURL, options: .withoutOverwriting)
        } catch {
            print("fail!")
        }
    }
}
