//
//  Stage.swift
//  Aico
//
//  Created by Yu Ho Kwok on 7/10/2023.
//

import Foundation
import UIKit



struct StageGraph : Node, Graph, HasPort, Codable, Equatable {
    static func == (lhs: StageGraph, rhs: StageGraph) -> Bool {
        return lhs.identifier != rhs.identifier
    }
    
    
    typealias T = Block

    var id: String {
        return identifier
    }
    
    //Node protocol
    var identifier : String
    var name : String
    var center: CGPoint
    var size: CGSize
    var frame: CGRect {
        set {
            self.center = CGPoint(x: newValue.midX, y: newValue.midY)
            self.size = newValue.size
        }
        get {
            return CGRect(x: center.x - size.width / 2,
                          y: center.y - size.height / 2,
                          width: size.width,
                          height: size.height)
        }
    }
    
    var attribute: Attribute
    var description : String
    var property: Property = Property.new
    
    var inChannels : [Port]
    var outChannels : [Port]
    var comChannels : [Port]
    
    var isDeletable: Bool {
        return self.name != "bigbang"
    }
    
    //the working block
    var nodes: [Block]
    //Communication Channel
    var channels : [Channel]
    
    /// return an array for all ports
    var portIdentifiers : [String] {
        return Port.identifiers(from: self)
    }
    
    func frame(in view: UIView?) -> CGRect {
        guard let view = view else {
            return self.frame
        }
        
        return frame.offsetBy(dx: view.bounds.size.width / 2,
                              dy: view.bounds.size.height / 2)
    }
    
    mutating func set(frame: CGRect, from view: UIView?) {
        guard let view = view else {
            self.frame =  frame
            return
        }
        
        self.frame =  frame.offsetBy(dx: -view.bounds.size.width / 2,
                                     dy: -view.bounds.size.height / 2)
    }

    //MARK: - Block
    
    /// Get the block in the stage with given identifier
    /// - Parameter identifier: identifier of the block
    /// - Returns: optional value of the block or nil
    func node(with identifier: String) -> Block? {
        for node in nodes {
            if node.identifier == identifier {
                return node
            }
        }
        return nil
    }
    
    mutating func updateNode(_ node: Block) {
        if let firstIndex = nodes.firstIndex(where: 
                            { $0.identifier == node .identifier }) {
            nodes[firstIndex] = node
        }
    }
    
    /// Delete block a block and all depended channels
    /// - Parameter block: the block to be deleted
    mutating func deleteNode(_ node: Block) {
        self.removeDependedChannels(node.portIdentifiers)
        print("Stage::\(#function)::BlockCountBeforeRemoval: \(nodes.count)")
        self.nodes = self.nodes.filter({ $0.identifier != node.identifier })
        print("Stage::\(#function)::BlockCountAfterRemoval: \(nodes.count)")
    }

    //MARK: - Port
    /// Get the port in the stage with given identifier
    /// - Parameter identifier: identifier of the port
    /// - Returns: optional value of the port or nil
    func portFromNodes(with identifier : String) -> Port? {
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
    
    //MARK: - Channel
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
    
    mutating func removeDependedChannels(_ portIds : [String]) {
        print("Stage::\(#function)::ChannelCountBeforeRemoval: \(channels.count)")
        self.channels = Channel.filterChannels(for: self, with: portIds)
        print("Stage::\(#function)::ChannelCountAfterRemoval: \(channels.count)")
    }

    
    static func new(for editor : UIView) -> StageGraph {
        let identifier = UUID().uuidString
        
        let listenPort = Port(kind: .inChannel,  name: "listen")
        let tellPort = Port(kind: .outChannel, name: "tell")
        
        //two default  block, stage Input and stage Output
        var stageInput = Block.new(.stageInput, for: editor.bounds)
        var nodeSize = stageInput.size
        var centerX : CGFloat = -editor.bounds.width / 2 + nodeSize.width / 2 + 15 //30 is margin
        var centerY : CGFloat = 0
        stageInput.center = CGPoint(x: centerX, y: centerY)
        
        
        var stageOutput = Block.new(.stageOutput, for: editor.bounds)
        nodeSize = stageOutput.size
        centerX = editor.bounds.width / 2 - nodeSize.width / 2 - 15 //30 is margin
        centerY = 0
        stageOutput.center = CGPoint(x: centerX, y: centerY)
        
        let node = StageGraph(identifier: identifier,
                               name : "Stage",
                               center: CGPoint(x: 0, y: 0),
                               size: CGSize(width: 206, height: 217),
                               attribute: Attribute.new,
                              description: "", 
                               inChannels: [listenPort],
                               outChannels: [tellPort],
                               comChannels: [],
                               nodes: [stageInput, stageOutput],
                               channels: [])

        return node
    }
    
    
    static func new(for bounds : CGRect) -> StageGraph {
        let identifier = UUID().uuidString
        
        let listenPort = Port(kind: .inChannel,  name: "listen")
        let tellPort = Port(kind: .outChannel, name: "tell")
        
        //two default  block, stage Input and stage Output
        var stageInput = Block.new(.stageInput, for: bounds)
        var nodeSize = stageInput.size
        var centerX : CGFloat = -bounds.width / 2 + nodeSize.width / 2 + 15 //30 is margin
        var centerY : CGFloat = 0
        stageInput.center = CGPoint(x: centerX, y: centerY)
        
        
        var stageOutput = Block.new(.stageOutput, for: bounds)
        nodeSize = stageOutput.size
        centerX = bounds.width / 2 - nodeSize.width / 2 - 15 //30 is margin
        centerY = 0
        stageOutput.center = CGPoint(x: centerX, y: centerY)
        
        let node = StageGraph(identifier: identifier,
                               name : "Stage",
                               center: CGPoint(x: 0, y: 0),
                               size: CGSize(width: 206, height: 217),
                               attribute: Attribute.new,
                              description: "",
                               inChannels: [listenPort],
                               outChannels: [tellPort],
                               comChannels: [],
                               nodes: [stageInput, stageOutput],
                               channels: [])

        return node
    }
    
}
