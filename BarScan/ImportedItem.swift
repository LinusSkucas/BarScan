//
//  ImportedItem.swift
//  BarScan
//
//  Created by Linus Skucas on 1/21/23.
//

import Foundation
import QuickLookThumbnailing

struct ImportedItem {
    var fileType: FileType
    var url: URL
    
    enum FileType: String {
        case png
        case jpeg
        case pdf
    }
}


