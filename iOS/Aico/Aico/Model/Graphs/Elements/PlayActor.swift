//
//  Role.swift
//  Aico
//
//  Created by Yu Ho Kwok on 9/10/2023.
//

import Foundation
import UIKit

struct PlayActor : Node, HasPort, Codable {

    var id: String {
        return identifier
    }
    
    var identifier : String = UUID().uuidString
    var name : String
    var config : RoleConfig
    
    //geometry
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
    
    var thumbnailPath: String?
    
    //role
    var attribute: Attribute
    var personality : Attribute
    var description : String = ""

    var property: Property = Property.new
    
    var inChannels : [Port]
    var outChannels : [Port]
    var comChannels : [Port]


    var isDeletable: Bool {
        return true
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
    
    var portIdentifiers: [String] {
        return Port.identifiers(from: self)
    }
    
    func warmUp() {
        
    }
    
    func listen() {
        
    }
    
    func think() {
        
    }
    
    func produce() {
        
    }
    
    func talk() {
        
    }
    
    static func new(for bounds : CGRect) -> PlayActor {
        let identifier = UUID().uuidString
        
        let relationshipPort = Port(kind: .comChannel,  name: "relationship")
       
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
        
        let node = PlayActor(identifier: identifier, 
                        name: "Worker",
                        config: RoleConfig(),
                        center: CGPoint(x: 0, y: 0),
                        size: CGSize(width: 206, height: 217),
                        attribute: Attribute.new,
                        personality: Attribute.new, 
                        inChannels: [],
                        outChannels: [],
                        comChannels: [relationshipPort])
    
        return node
    }

}

struct RoleConfig : Codable {
    var identifier : String = UUID().uuidString
}

