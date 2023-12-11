//
//  PortView.swift
//  Aico
//
//  Created by Yu Ho Kwok on 12/10/2023.
//

import UIKit


class PortView : UIView {

    var identifier : String = ""
    weak var parent : NodeView?
    
    static func build(for port : Port, at center : CGPoint) -> PortView {
        let defaultSize = PortView.defaultSize
        let originalX = center.x - defaultSize.width / 2
        let originalY = center.y - defaultSize.height / 2
        
        let original = CGPoint(x: originalX, y: originalY)
        
        let portView = PortView(frame: CGRect(origin: original, size: defaultSize))
        portView.identifier = port.identifier
        
        switch port.kind {
        case .inChannel:
            portView.backgroundColor = .green
        case .outChannel:
            portView.backgroundColor = .red
        case .comChannel:
            portView.backgroundColor = .blue
        }
        
        
        return portView
    }
    
    static var defaultSize = CGSize(width: 20, height: 20)
}

