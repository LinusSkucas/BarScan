//
//  AppDelegate.swift
//  BarScan
//
//  Created by Linus Skucas on 12/20/22.
//

import Cocoa

@main
class AppDelegate: NSResponder, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    @IBOutlet var importMenuItem: NSMenuItem!
    var statusItem = StatusItem()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // MARK - Continuity Camera Stuff
    override func validRequestor(forSendType sendType: NSPasteboard.PasteboardType?, returnType: NSPasteboard.PasteboardType?) -> Any? {
        if let pasteboardType = returnType,
            NSImage.imageTypes.contains(pasteboardType.rawValue) {
            return statusItem
        } else {
            return super.validRequestor(forSendType: sendType, returnType: returnType)
        }
    }
    
    override func awakeFromNib() {
        statusItem.setUpMenu(importMenuItem: importMenuItem)
        super.awakeFromNib()
    }

}

