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
    
    static func build(for port : Port, at center : CGPoint, color : UIColor) -> PortView {
        let defaultSize = PortView.defaultSize
        let originalX = center.x - defaultSize.width / 2
        let originalY = center.y - defaultSize.height / 2
        
        let original = CGPoint(x: originalX, y: originalY)
        
        let portView = PortView(frame: CGRect(origin: original, size: defaultSize))
        portView.identifier = port.identifier
        
        portView.backgroundColor = color.withAlphaComponent(0.1)
        portView.layer.cornerRadius = 5

        var capsuleOriginalX = 0.0
        let capsuleOriginalY = 0.0
        
        switch port.kind {
        case .inChannel:
            capsuleOriginalX = 0.0
        case .outChannel:
            capsuleOriginalX = defaultSize.width - capsuleSize.width
        case .comChannel:
            capsuleOriginalX = capsuleSize.width / 2
        }
        
        let capsuleOriginal = CGPoint(x: capsuleOriginalX, y: capsuleOriginalY)
        
        let capsuleView = PortView(frame: CGRect(origin: capsuleOriginal, size: capsuleSize))
        capsuleView.layer.cornerRadius = 5
        capsuleView.backgroundColor = color
        portView.addSubview(capsuleView)
        
        
         return portView
    }
    
    static var capsuleSize = CGSize(width: 10, height: 48)
    static var defaultSize = CGSize(width: 30, height: 48)
}

