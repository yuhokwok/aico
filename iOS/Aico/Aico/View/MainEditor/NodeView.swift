//
//  BlockView.swift
//  Aico
//
//  Created by Yu Ho Kwok on 5/10/2023.
//

import UIKit


class NodeView : UIView {
    
    var identifier : String = ""

    var contentView : UIView?
    var nameLabel : UILabel?
    
    //port for receive input
    var inPorts : [PortView] = []
    //port for send message
    var outPorts : [PortView] = []
    //two directional communication port
    var comPorts : [PortView] = []
    
    
    func setSelected(_ selected : Bool) {
        if selected {
            contentView?.backgroundColor = .yellow
        } else {
            contentView?.backgroundColor = .orange
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    /// Check should receive gesture
    /// - Parameter point: local point
    /// - Returns: should or should not receive gesture
    func shouldReceiveGesture(_ gesture : UIGestureRecognizer) -> Bool {
        let point = gesture.location(in: self)
        if gesture is UITapGestureRecognizer {
            
            if let contentView = self.contentView {
                return contentView.frame.contains(point)
            }
            return false
            
        } else if gesture is UIPanGestureRecognizer {
            
            if let contentView = self.contentView {
                return contentView.frame.contains(point) || self.touchedPort(at: point) != nil
            }
        }
        return false
    }
    
    func touchedPort(at point : CGPoint) -> PortView? {

        for inPort in inPorts {
            //放大少少易 d touch
            //print("inport rect: \(inPort.frame.insetBy(dx: -10, dy: -10))")
            if inPort.frame.insetBy(dx: -11, dy: -11).contains(point) {
                //print("BlockView::DraggedPort::Return inPort")
                return inPort
            }
        }
        
        for outPort in outPorts {
            //放大少少易 d touch
            //print("outPort rect: \(outPort.frame.insetBy(dx: -10, dy: -10))")
            if outPort.frame.insetBy(dx: -11, dy: -11).contains(point) {
                //print("BlockView::DraggedPort::Return outPort")
                return outPort
            }
        }
        
        for comPort in comPorts {
            //放大少少易 d touch
            //print("outPort rect: \(outPort.frame.insetBy(dx: -10, dy: -10))")
            if comPort.frame.insetBy(dx: -11, dy: -11).contains(point) {
                //print("BlockView::DraggedPort::Return outPort")
                return comPort
            }
        }
        
        //print("BlockView::DraggedPort::Return nil Port")
        return nil
    }
    
    func update(for node : Node, for editor : NodeEditorView) {
        let frame = node.frame(in: editor)
        
        if node.name.count > 0 {
            self.nameLabel?.text = node.name
        } else {
            self.nameLabel?.text = ""
        }
        
        self.frame = frame
    }
    
    static func build(for node : Node, for editor : NodeEditorView) -> NodeView {
        
        //convert the node coord to editor coord
        let frame = node.frame(in: editor)
        
        let blockView = NodeView(frame: frame)
        blockView.backgroundColor = .clear
        blockView.identifier = node.identifier
        
        var numPorts : Int
        var segmentHeight : CGFloat
        
        let portDefaultSize = PortView.defaultSize
        
        //build the content view
        
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 80))
        contentView.backgroundColor = .orange
        contentView.center = CGPoint(x: blockView.bounds.size.width / 2, y: blockView.bounds.size.height / 2 - 10)
        
        let label = UILabel(frame: contentView.bounds)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        if node.name.count > 0 {
            label.text = "\(node.name)"
        } else {
            label.text = ""
        }
        blockView.nameLabel = label
        contentView.addSubview(label)
        
        blockView.contentView = contentView
        blockView.addSubview(contentView)
        
        //build inport
        numPorts = node.inChannels.count
        segmentHeight = blockView.bounds.height / CGFloat(numPorts + 1)
        
        for (index, port) in node.inChannels.enumerated() {

            let computedX = portDefaultSize.width / 2
            let computedY = CGFloat(index + 1) * segmentHeight
            let computedCenter = CGPoint(x: computedX, y: computedY)
            let portView = PortView.build(for: port, at: computedCenter)
            portView.parent = blockView
            blockView.inPorts.append(portView)
            blockView.addSubview(portView)
        }
        
        //build outport
        numPorts = node.outChannels.count
        segmentHeight = blockView.bounds.height / CGFloat(numPorts + 1)
        for (index, port) in node.outChannels.enumerated() {
            
            let computedX = blockView.bounds.width - portDefaultSize.width / 2
            let computedY = CGFloat(index + 1) * segmentHeight
            
            let computedCenter = CGPoint(x: computedX, y: computedY)
            let portView = PortView.build(for: port, at: computedCenter)
            portView.parent = blockView
            blockView.outPorts.append(portView)
            blockView.addSubview(portView)
        }
        
        //build comPort
        numPorts = node.comChannels.count
        let segmentWidth = blockView.bounds.width / CGFloat(numPorts + 1)
        for (index, port) in node.comChannels.enumerated() {
            
            let computedY = blockView.bounds.height - portDefaultSize.height / 2
            let computedX = CGFloat(index + 1) * segmentWidth

            let computedCenter = CGPoint(x: computedX, y: computedY)
            let portView = PortView.build(for: port, at: computedCenter)
            portView.parent = blockView
            blockView.comPorts.append(portView)
            blockView.addSubview(portView)
        }
        
        return blockView
    }

}


class GraphView : UIView {
    
    
    static func build(for block : Block) -> GraphView {
        let blockView = GraphView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        blockView.backgroundColor = .orange
        return blockView
    }
    
}
