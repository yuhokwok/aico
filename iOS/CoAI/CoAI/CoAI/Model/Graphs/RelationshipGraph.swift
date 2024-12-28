//
//  RelationshipGraph.swift
//  CoAI
//
//  Created by itst on 9/10/2023.
//

import Foundation


struct RelationshipGraph : Graph, Codable, Equatable  {
    static func == (lhs: RelationshipGraph, rhs: RelationshipGraph) -> Bool {
        return lhs.identifier != rhs.identifier
    }
    
    typealias T = PlayActor
    
    var id: String {
        return identifier
    }
    
    var identifier : String
    //the people exist in the project

    var attribute: Attribute
    var property: Property = Property.new
    
    //Communication Channel
    var nodes: [PlayActor]

    var channels: [Channel]
   
    
    func node(with identifier: String) -> PlayActor? {
        for node in nodes {
            if node.identifier == identifier {
                return node
            }
        }
        return nil
    }
    
    mutating func updateNode(_ node: PlayActor) {
        if let firstIndex = nodes.firstIndex(where:
                            { $0.identifier == node .identifier }) {
            nodes[firstIndex] = node
        }
    }
    
    mutating func deleteNode(_ node: PlayActor) {
        self.removeDependedChannels(node.portIdentifiers)
        print("Relationship::\(#function)::BlockCountBeforeRemoval: \(nodes.count)")
        self.nodes = self.nodes.filter({ $0.identifier != node.identifier })
        print("Relationship::\(#function)::BlockCountAfterRemoval: \(nodes.count)")
    }
    
    func portFromNodes(with identifier: String) -> Port? {
        for node in nodes {
            for port in node.inChannels {
                if port.identifier == identifier {
                    return port
                }
            }
            
            for port in node.outChannels {
                if port.identifier == identifier {
                    return port
                }
            }
            
            for port in node.comChannels {
                if port.identifier == identifier {
                    return port
                }
            }
        }
        return nil
    }
 
    func channel(with identifier: String) -> Channel? {
        for channel in channels {
            if channel.identifier == identifier {
                return channel
            }
        }
        return nil
    }
    
    mutating func deleteChannel(_ channel: Channel) {
        self.channels = Channel.filterChannel(for: self, with: channel.identifier)
    }
    
    mutating func removeDependedChannels(_ portIds: [String]) {
        print("Stage::\(#function)::ChannelCountBeforeRemoval: \(channels.count)")
        self.channels = Channel.filterChannels(for: self, with: portIds)
        print("Stage::\(#function)::ChannelCountAfterRemoval: \(channels.count)")
    }
    

    
    static func new(for bounds : CGRect) -> RelationshipGraph {
        let uuid = UUID().uuidString
        
        var role = PlayActor.new(for: bounds)
        role.name = "Worker"
        
        let graph = RelationshipGraph(identifier: uuid, attribute: Attribute.new, nodes: [role], channels: [])
        return graph
    }
}
