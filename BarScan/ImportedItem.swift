//
//  ImportedItem.swift
//  BarScan
//
//  Created by Linus Skucas on 1/21/23.
//

import Foundation
import QuickLookThumbnailing
import UniformTypeIdentifiers

struct ImportedItem {
    var fileType: FileType
    var url: URL
    
    enum FileType: String {
        case png
        case jpeg
        case pdf
        
        var utType: UTType {
            switch self {
            case .png:
                return UTType.png
            case .jpeg:
                return UTType.jpeg
            case .pdf:
                return UTType.pdf
            }
        }
    }
}


