//
//  Attribute.swift
//  CoAI
//
//  Created by itst on 9/10/2023.
//

import Foundation

extension String {
    var tags : [String] {
        var components = self.components(separatedBy: ",")
        components = components.map({
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        })
        return components
    }
}

extension [String] {
    var string : String {
        let string = self.reduce("", {
            result, element in
            if result.isEmpty {
                return "\(result)\(element)"
            }
            return "\(result), \(element)"
        })
        return string
    }
}

struct Attribute : Codable, Identifiable {
    var id : String
    var contents : [AttributeEntry]
    
    static var new : Attribute {
        return Attribute(id: UUID().uuidString, contents: [])
    }
}

struct AttributeEntry : Codable, Identifiable {
    var id : String
    var content : String
}
