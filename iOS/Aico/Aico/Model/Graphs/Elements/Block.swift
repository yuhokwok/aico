//
//  Block.swift
//  Aico
//
//  Created by itst on 5/10/2023.
//

import Foundation
import UIKit

var colors = ["orange", "red", "blue", "green", "purple", "gray"]

struct Block : Node, HasPort, Codable  {
    

    var id: String {
        return identifier
    }
    
    var identifier : String = UUID().uuidString
    var name : String
    var role : String = ""
    var color : String = colors[Int.random(in: 0...999) % 6]
    
    
    var thumbnail : String?
    
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
    //var roleIdentifier : String
    var attribute: Attribute

    var property: Property = Property.new
    
    var inChannels : [Port]
    var outChannels : [Port]
    var comChannels : [Port]

    var isDeletable: Bool {
        return self.name != "stageInput" && self.name != "stageOutput"
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
    
    //MARK: - HasPort
    /// return an array for all ports
    var portIdentifiers : [String] {
        return Port.identifiers(from: self)
    }


    static func new( _ kind : NodeKind = .normal, for bounds : CGRect) -> Block {
        
        


//        let role = Role(name: "PM", config: RoleConfig(), attribute: Attribute.new)
        var block = Block(name: "Worker",
                          center: CGPoint(x: 0, y: 0),
                          size: CGSize(width: 206, height: 217),
                          //roleIdentifier: "default",
                          attribute: Attribute.new,
                          inChannels: [],
                          outChannels: [],
                          comChannels: [])
        
        
        let nodeSize = block.size
        let centerX : CGFloat = -bounds.width / 2 + nodeSize.width / 2 + 15 //30 is margin
        let centerY : CGFloat = 0
        block.center = CGPoint(x: centerX, y: centerY)
        
        
        switch kind {
        case .stageInput:
            block.name = "stageInput"
            let tellPort = Port(kind: .outChannel, name: "tell")
            block.outChannels.append(tellPort)
        case .stageOutput:
            block.name = "stageOutput"
            let listenPort = Port(kind: .inChannel,  name: "listen")
            block.inChannels.append(listenPort)
        default:
            let listenPort = Port(kind: .inChannel,  name: "listen")
            let referencePort = Port(kind: .inChannel,  name: "reference")
            block.inChannels.append(listenPort)
            //block.inChannels.append(referencePort)
            
            let tellPort = Port(kind: .outChannel, name: "tell")
            block.outChannels.append(tellPort)
            
            //let comPort = Port(kind: .comChannel, name: "com")
            //block.comChannels.append(comPort)
        }
        

        
        return block
    }
}



struct RelationshipAttribute : Codable {
    //direction?
    var identifier : String = UUID().uuidString
}


enum ColorSet : String, Codable {
    case orange = "oranage"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case red = "red"
    case gray = "gray"
}



