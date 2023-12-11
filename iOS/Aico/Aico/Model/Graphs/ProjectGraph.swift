//
//  ProjectGraph.swift
//  Aico
//
//  Created by Yu Ho Kwok on 9/10/2023.
//

import Foundation
import UIKit


struct ProjectGraph : Graph, Codable {
    
    var identifier : String
    var nodes: [StageGraph]
    
    var attribute: Attribute
    var description : String = ""
    var property: Property = Property.new
    
    //Communication Channel
    var channels : [Channel]

    var mode : Mode = .preset
    
    enum Mode : String, Codable {
        case preset = "static"
        case dynamic = "dynamic"
    }
    
    

    static func new(for editor : UIView) -> ProjectGraph {
        let identifier = UUID().uuidString
        
        //just start channels
        var startNode = StageGraph.new(for: editor)
        startNode.name = "bigbang"
        startNode.inChannels.removeAll()
        startNode.outChannels.removeAll()
        startNode.outChannels.append(Port(kind: .outChannel, name: "bigbang"))
        
        let nodeSize = startNode.size
        let centerX : CGFloat = -editor.bounds.width / 2 + nodeSize.width / 2 + 15 //30 is margin
        let centerY : CGFloat = 0
        startNode.center = CGPoint(x: centerX, y: centerY)
        
        
        let graph = ProjectGraph(identifier: identifier,
                                 nodes: [startNode],
                                 attribute: Attribute.new, 
                                 channels: [])
        return graph
    }
    
    //MARK: - Block
    typealias T = StageGraph
    
    func indexForNode(id : String) -> Int? {
        for (index, element) in nodes.enumerated() {
            if element.identifier == id {
                return index
            }
        }
        return nil
    }
    
    func indexForChannel(id : String) -> Int? {
        for (index, element) in channels.enumerated() {
            if element.identifier == id {
                return index
            }
        }
        return nil
    }
    
    /// Get the block in the stage with given identifier
    /// - Parameter identifier: identifier of the block
    /// - Returns: optional value of the block or nil
    func node(with identifier: String) -> StageGraph? {
        for node in nodes {
            if node.identifier == identifier {
                return node
            }
        }
        return nil
    }
    
    mutating func updateNode(_ node: StageGraph) {
        if let firstIndex = nodes.firstIndex(where:
                            { $0.identifier == node .identifier }) {
            nodes[firstIndex] = node
        }
    }
    
    mutating func deleteNode(_ node: StageGraph) {
        self.removeDependedChannels(node.portIdentifiers)
        print("Stage::\(#function)::StageCountBeforeRemoval: \(nodes.count)")
        self.nodes = self.nodes.filter({ $0.identifier != node.identifier })
        print("Stage::\(#function)::StageCountAfterRemoval: \(nodes.count)")
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

    //MARK: - HasPort
    /// Get the port in the stage with given identifier
    /// - Parameter identifier: identifier of the port
    /// - Returns: optional value of the port or nil
    func port(with identifier : String) -> Port? {
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
    
    //MARK: - HasChannel
    func channel(with identifier : String) -> Channel? {
        for channel in channels {
            if channel.identifier == identifier {
                return channel
            }
        }
        return nil
    }
    
    mutating func deleteChannel(_ channel : Channel) {
        self.channels = Channel.filterChannel(for: self, with: channel.identifier)
    }
    
    mutating func removeDependedChannels(_ portIds : [String]){
        print("Stage::\(#function)::ChannelCountBeforeRemoval: \(channels.count)")
        self.channels = Channel.filterChannels(for: self, with: portIds)
        print("Stage::\(#function)::ChannelCountAfterRemoval: \(channels.count)")
    }
}
