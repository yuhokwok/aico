//
//  Port.swift
//  Aico
//
//  Created by Yu Ho Kwok on 12/10/2023.
//

import Foundation


struct Port : Codable, HasIdentifier {
    
    var id: String {
        return identifier
    }
    
    var kind : Kind
    var identifier : String = UUID().uuidString
    var name : String
    
    
    func isConnectable(with target : Port) -> Bool {
        if self.kind == .inChannel && target.kind == .outChannel ||
            self.kind == .outChannel && target.kind == .inChannel ||
            self.kind == .comChannel && target.kind == .comChannel {
            return true
        }
        return false
    }
    
    enum Kind : String, Codable {
        case inChannel = "input"
        case outChannel = "outout"
        case comChannel = "communication"
    }
    
    //function to retrieve all ports ID from a node type
    static func identifiers(from node : Node) -> [String] {
        //create a string array with the identifeir of ports using map function
        var portsId = node.inChannels.map { $0.identifier }
        portsId += node.outChannels.map { $0.identifier }
        portsId += node.comChannels.map { $0.identifier }
        return portsId
    }
}

