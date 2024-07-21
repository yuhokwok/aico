//
//  Item.swift
//  Aico
//
//  Created by itst on 5/1/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct Note: Codable, Identifiable {
    var id : String = UUID().uuidString
    let title: String
    let body: String
}


extension Note: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .note)
        ProxyRepresentation(exporting: \.title)
    }
}

extension UTType {
    static var note: UTType { UTType(exportedAs: "com.example.note") }
}
