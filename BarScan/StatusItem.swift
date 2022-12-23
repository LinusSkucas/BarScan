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
    func readSelection(from pasteboard: NSPasteboard) -> Bool {
        guard pasteboard.canReadItem(withDataConformingToTypes: NSImage.imageTypes) else { return false }
        guard let image = NSImage(pasteboard: pasteboard) else { return false }
        
        saveFileToDesktop(image: image)
        return true
    }
    
    func saveFileToDesktop(image: NSImage) {
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let date = Date()
        let name = "BarScan Image at \(date.formatted(date: .abbreviated, time: .shortened)).png"
        let destinationURL = desktopURL.appending(component: name)
        
        do {
            try image.pngWrite(to: destinationURL, options: .withoutOverwriting)
        } catch let error {
            print(error.localizedDescription)
            print("fail!")
        }
    }
}
