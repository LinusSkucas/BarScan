//
//  StatusItemConfigurator.swift
//  BarScan
//
//  Created by Linus Skucas on 12/21/22.
//

import Foundation
import Cocoa
import UniformTypeIdentifiers

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
    func readSelection(from pasteboard: NSPasteboard) -> Bool {  // TODO: Refactor out non pasteboard things
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
            
            let name = "Item.\(UTType(itemType.rawValue)!.preferredFilenameExtension!)"
            let temporaryURL = temporaryDirectoryURL.appending(component: name)
            
            try itemData.write(to: temporaryURL)
        } catch {
            print(error.localizedDescription)  // TODO: Better error handling
            return false
        }
        return true
    }
}
