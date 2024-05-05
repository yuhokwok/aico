//
//  Protocol.swift
//  Aico
//
//  Created by Yu Ho Kwok on 12/10/2023.
//

import Foundation
import UIKit

enum NodeKind {
    case role
    case stageInput
    case stageOutput
    case normal
}



/// A protocol describes the basic elements of a node
protocol Node: HasIdentifier, HasAttribute, HasProperty {

    
    var name : String { get set }
    var center : CGPoint { get set }
    var size : CGSize { get set }
    var frame : CGRect { get set }
    
    var thumbnailPath : String? { get set }
    
    var inChannels : [Port] { get set }
    var outChannels : [Port] { get set }
    var comChannels : [Port] { get set }
    
    var portIdentifiers : [String] { get }
    
    var isDeletable : Bool { get }
    
    /// Get the centre of block in a given view
    /// - Parameter editor: given editor, nil means no conversion
    func frame(in view : UIView?) -> CGRect
    
    
    /// Set the centre of node, convert it from the coord in the editor view to local coordinate
    /// - Parameters:
    ///   - frame: frame of the view
    ///   - view: given editor, nil means no conversion
    mutating func set(frame: CGRect, from view: UIView?)
}

protocol Graph : HasIdentifier, HasNode, HasChannel, HasAttribute, HasProperty {}

/// An abstraction for structure which has node to manage
protocol HasNode {
    associatedtype T : Node
    var nodes : [T] { get set }
    func node(with identifier : String) -> T?
    mutating func updateNode(_ node : T)
    mutating func deleteNode(_ node : T)
    
    /// Get the port from one of the node  in the graphs with given identifier
    /// - Parameter identifier: identifier of the port
    /// - Returns: optional value of the port or nil
    func portFromNodes(with identifier : String) -> Port?
}

protocol HasIdentifier{
    var identifier : String { get set }

}

protocol HasAttribute {
    var attribute : Attribute { get set }
}

/// An abstraction for structure which has commuication port to manage
protocol HasPort {
    
}

/// An abstraction for structure which has commuication channel to manage
protocol HasChannel {
    var channels : [Channel] { get set }
    
    func channel(with identifier : String) -> Channel?
    mutating func deleteChannel(_ channel : Channel)
    mutating func removeDependedChannels(_ portIds : [String])
}

protocol HasProperty {
    var property : Property {get set}
}
