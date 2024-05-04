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
    var detailLabel : UILabel?
    
    var hightlightView : UIView?
    
    //port for receive input
    var inPorts : [PortView] = []
    //port for send message
    var outPorts : [PortView] = []
    //two directional communication port
    var comPorts : [PortView] = []
    
    
    func setSelected(_ selected : Bool) {
        if selected {
            //contentView?.backgroundColor = .white
            hightlightView?.isHidden = false
        } else {
            //contentView?.backgroundColor = .orange
            hightlightView?.isHidden = true
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
        
        var color = UIColor.purple
        
        //convert the node coord to editor coord
        let frame = node.frame(in: editor)
        
        
        let blockView = NodeView(frame: frame)
        blockView.backgroundColor = .clear
        //blockView.backgroundColor = .gray
        blockView.identifier = node.identifier
        
        var numPorts : Int
        var segmentHeight : CGFloat
        
        let portDefaultSize = PortView.defaultSize
        
        //build the content view
        
        
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 170, height: 181))
        contentView.backgroundColor = .white
        contentView.center = CGPoint(x: blockView.bounds.size.width / 2, y: blockView.bounds.size.height / 2)
        
        contentView.layer.cornerRadius = 18
        contentView.layer.borderWidth = 5
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        contentView.layer.shadowColor = color.cgColor
        contentView.layer.shadowRadius = 15
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowOffset = .zero
        
        var innerFrame = contentView.bounds
        innerFrame = innerFrame.insetBy(dx: 5, dy: 5)
        
        let contentViewOverlay = UIView(frame: innerFrame)
        contentViewOverlay.layer.cornerRadius = 14
        contentViewOverlay.layer.borderWidth = 1
        contentViewOverlay.layer.borderColor = color.cgColor
        contentViewOverlay.backgroundColor = UIColor.clear
        contentView.addSubview(contentViewOverlay)
        
        contentView.clipsToBounds = false
        
        let highlightView = UIView(frame: blockView.bounds)
        blockView.hightlightView = highlightView
        highlightView.tag = 8
        highlightView.layer.cornerRadius = 28
        highlightView.layer.borderWidth = 10
        highlightView.layer.borderColor = color.cgColor
        highlightView.backgroundColor = .clear
        highlightView.isHidden = true
        blockView.addSubview(highlightView)
        
        let thumbnailCX = contentView.bounds.width / 2 - 96 / 2
        let thumbnailCY = 18.0 //contentView.bounds.height / 2 - 96 / 2
        let thumbnailContainerView = UIView(frame: CGRect(x: thumbnailCX, y: thumbnailCY, width: 96, height: 96))
        thumbnailContainerView.backgroundColor = .white
        thumbnailContainerView.layer.cornerRadius = 48
        thumbnailContainerView.layer.shadowColor = UIColor.lightGray.cgColor
        thumbnailContainerView.layer.shadowRadius = 5
        thumbnailContainerView.layer.shadowOpacity = 0.5
        thumbnailContainerView.layer.shadowOffset = .zero
        
        
        contentView.addSubview(thumbnailContainerView)
        
        let thumbnailX = 15.0 / 2
        let thumbnailY = 15.0 / 2
        let thumbnailView = UIImageView(frame: CGRect(x: thumbnailX, y: thumbnailY, width: 81, height: 81))
        thumbnailView.image = UIImage(named: "actress")
        thumbnailView.layer.cornerRadius = 40.5
        thumbnailView.layer.borderWidth = 0.5
        thumbnailView.layer.borderColor = UIColor.lightGray.cgColor
        thumbnailView.backgroundColor = .white
        thumbnailView.contentMode = .scaleAspectFit
        thumbnailView.clipsToBounds = true
        thumbnailContainerView.addSubview(thumbnailView)
        

        let labelX = contentView.bounds.width / 2 - 150 / 2
        let labelY = 120.0
        let label = UILabel(frame: CGRect(x: labelX, y: labelY, width: 150, height: 24))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        if node.name.count > 0 {
            //label.text = "\(node.name)"
            label.text = "小姐姐"
        } else {
            label.text = ""
        }
        blockView.nameLabel = label
        contentView.addSubview(label)
        
        //detailTextLabel
        let detailLabelX = contentView.bounds.width / 2 - 150 / 2
        let detailLabelY = 145.0
        let detailLabel = UILabel(frame: CGRect(x: detailLabelX, y: detailLabelY, width: 150, height: 18))
        detailLabel.numberOfLines = 0
        detailLabel.textAlignment = .center
        detailLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        if node.name.count > 0 {
            detailLabel.text = "女主角"
        } else {
            detailLabel.text = ""
        }
        blockView.detailLabel = detailLabel
        contentView.addSubview(detailLabel)
        
        
        
        blockView.contentView = contentView
        blockView.addSubview(contentView)
        
        //build inport
        numPorts = node.inChannels.count
        segmentHeight = blockView.bounds.height / CGFloat(numPorts + 1)
        
        for (index, port) in node.inChannels.enumerated() {

            let computedX = portDefaultSize.width / 2
            let computedY = CGFloat(index + 1) * segmentHeight
            let computedCenter = CGPoint(x: computedX, y: computedY)
            let portView = PortView.build(for: port, at: computedCenter, color: color)
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
            let portView = PortView.build(for: port, at: computedCenter, color: color)
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
            let portView = PortView.build(for: port, at: computedCenter, color: color)
            portView.parent = blockView
            blockView.comPorts.append(portView)
            blockView.addSubview(portView)
        }
        
        blockView.bringSubviewToFront(contentView)
        
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
