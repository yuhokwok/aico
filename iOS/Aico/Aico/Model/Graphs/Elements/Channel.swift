//
//  Channel.swift
//  Aico
//
//  Created by itst on 9/10/2023.
//

import Foundation

struct Channel : Codable, HasIdentifier, HasAttribute, HasProperty {
    
    var id: String {
        return identifier
    }
    
    var identifier : String

    var name : String = ""
    
    var startId : String
    var endId : String
    
    var attribute : Attribute
    var description : String = ""
    
    var property: Property = Property.new
    
    func hasDependencies(_ portIds : [String]) -> Bool {
        for portId in portIds {
            if startId == portId || endId == portId {
                return true
            }
        }
        return false
    }
    
    static func new(from fromId : String, to toId : String) -> Channel {
        let identifier = UUID().uuidString
        let channel = Channel(identifier: identifier, startId: fromId, endId: toId, attribute: Attribute.new)
        return channel
    }
    
    
    /// Remove all channels from the given node with the given portIds and return a new channel array
    /// - Parameters:
    ///   - input: any input confronts to HasChannel protocol
    ///   - portIds: id for all ports to be removed
    /// - Returns: a filtered channel array
    static func filterChannels(for input : any HasChannel, with portIds : [String]) -> [Channel] {
        return input.channels.filter({ $0.hasDependencies(portIds) == false })
    }
    
    /// Remove all channel from the given node with the given portIds and return a new channel array
    /// - Parameters:
    ///   - input: any input confronts to HasChannel protocol
    ///   - channelId: channel id of the channel to be removed
    /// - Returns: a filtered channel array
    static func filterChannel(for input : any HasChannel, with channelId : String) -> [Channel] {
        return input.channels.filter({ $0.identifier != channelId })
    }
}
