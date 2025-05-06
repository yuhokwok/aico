//
//  Role.swift
//  Aico
//
//  Created by itst on 9/10/2023.
//

import Foundation
import UIKit

extension UIImage {
    /// Convert UIImage to a Base64 encoded string.
    func toBase64() -> String? {
        // Option 1: Using PNG representation (lossless)
        if let imageData = self.pngData() {
            return imageData.base64EncodedString(options: .lineLength64Characters)
        }

        return nil
    }
    
    /// Create a UIImage from a Base64 encoded string.
    static func fromBase64(_ base64String: String) -> UIImage? {
        // Decode the Base64 string to Data.
        guard let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
            return nil
        }
        // Create and return a UIImage from the Data.
        return UIImage(data: imageData)
    }
}

struct PlayActor : Node, HasPort, Codable {
    
    var id: String {
        return identifier
    }
    
    var identifier : String = UUID().uuidString
    var name : String
    var thumbnailData : String?
    var role : String
    var config : RoleConfig
    var color : String = colors[Int.random(in: 0...999) % 6]
    
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
    
    
    var thumbnail : UIImage? {
        set {
            if let v = newValue {
                thumbnailData = v.toBase64()
            } else {
                thumbnailData = nil
            }
        }
        
        get {
            if let data = thumbnailData {
                return UIImage.fromBase64(data)
            }
            return nil
        }
    }
    
    static func defaultActor(for bounds : CGRect) -> PlayActor {
        let identifier = "default"
        
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
                        role: "Code for Web",
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

    
    static func new(for bounds : CGRect) -> PlayActor {
        let identifier = UUID().uuidString
        
        let relationshipPort = Port(kind: .comChannel,  name: "relationship")
        
        let inPort = Port(kind: .inChannel, name: "inPort")
        let outPort = Port(kind: .outChannel, name: "outPort")
       
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
                        role: "Code for Web", 
                        config: RoleConfig(),
                        center: CGPoint(x: 0, y: 0),
                        size: CGSize(width: 206, height: 217),
                        attribute: Attribute.new,
                        personality: Attribute.new, 
                             inChannels: [inPort],
                             outChannels: [outPort],
                             comChannels: [relationshipPort])
    
        return node
    }

}

struct RoleConfig : Codable {
    var identifier : String = UUID().uuidString
}

