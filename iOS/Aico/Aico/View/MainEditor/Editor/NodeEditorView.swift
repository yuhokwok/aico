//
//  NodeEditorView.swift
//  Aico
//
//  Created by Yu Ho Kwok on 7/10/2023.
//

import UIKit

struct NodeCurve {

    var identifier : String
    var content : String
    var selected : Bool = false
    
    var startPt : CGPoint
    var startId : String?
    
    var endPt : CGPoint
    var endId : String?
    
    
    
    var beizer : UIBezierPath?
    
  
    func hasDependencies(_ portIds : [String]) -> Bool {
        for portId in portIds {
            if startId == portId || endId == portId {
                return true
            }
        }
        return false
    }
    
    mutating func updatePath(){

        let path = UIBezierPath()

        path.move(to: self.startPt)
        
        let halfDist = abs(startPt.x - endPt.x) / 2
        
        let cPt1 : CGPoint
        let cPt2 : CGPoint
        
        if startPt.x < endPt.x {
            
            cPt1 =  startPt + CGPoint(x: halfDist, y: 0)
            cPt2 =  endPt - CGPoint(x: halfDist, y: 0)

        } else {

            cPt1 =  startPt - CGPoint(x: halfDist, y: 0)
            cPt2 =  endPt + CGPoint(x: halfDist, y: 0)
            
        }

        // Draw the first line
        path.addCurve(to: self.endPt, controlPoint1: cPt1, controlPoint2: cPt2)
        
        
        //path.close()
        path.lineWidth = 3
        
        self.beizer = path
    }
    
    mutating func updatePath(startPt : CGPoint, endPt : CGPoint){
        
        self.startPt = startPt
        self.endPt = endPt
        
        let path = UIBezierPath()
        
        path.move(to: self.startPt)
        
        let halfDist = abs(startPt.x - endPt.x) / 2
        
        let cPt1 : CGPoint
        let cPt2 : CGPoint
        
        if startPt.x < endPt.x {
            
            cPt1 =  startPt + CGPoint(x: halfDist, y: 0)
            cPt2 =  endPt - CGPoint(x: halfDist, y: 0)

        } else {

            cPt1 =  startPt - CGPoint(x: halfDist, y: 0)
            cPt2 =  endPt + CGPoint(x: halfDist, y: 0)
            
        }
        
        // Draw the first line
        path.addCurve(to: self.endPt, controlPoint1: cPt1, controlPoint2: cPt2)
        
        path.close()
        
        self.beizer = path
    }
}

protocol NodeEditorViewDelegate {
    func nodeEditorViewDidSelectChannel(with identifier : String)
}

@MainActor
class NodeEditorView : UIView {
    
    var delegate : NodeEditorViewDelegate?

    var tempCurve : NodeCurve? = nil
    var curves : [NodeCurve] = []
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func redraw(){
        self.setNeedsDisplay()
    }
    
    func startNewCurve(at point : CGPoint) {
        let identifier = UUID().uuidString
        tempCurve = NodeCurve(identifier: identifier, content: "", startPt: point, endPt: point)
    }
    
    func updateNewCurve(to point : CGPoint){
        tempCurve?.endPt = point
    }
    
    func hasTouchedChannel(gesture : UIGestureRecognizer) -> Bool {
        guard let gesture = gesture as? UITapGestureRecognizer else {
            return false
        }
        
        for curve in curves {
            
            let pt = gesture.location(in: self)
            
            let touchPath = CGPath(roundedRect: CGRectMake(pt.x - 22, pt.y - 22, 44, 44), cornerWidth: 22, cornerHeight: 22, transform: nil)
            
            if curve.beizer?.cgPath.intersects(touchPath) == true {
                return true
            }
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for curve in curves {
            if let touch = touches.first {
                
                let pt = touch.location(in: self)

                let touchPath = CGPath(roundedRect: CGRectMake(pt.x - 22, pt.y - 22, 44, 44), cornerWidth: 22, cornerHeight: 22, transform: nil)
                
                if curve.beizer?.cgPath.intersects(touchPath) == true {
                    self.delegate?.nodeEditorViewDidSelectChannel(with: curve.identifier)
                    break
                }
            }
        }
    }
    
    func addCurve(for channel : Channel) {
        let curve = NodeCurve(identifier: channel.identifier,
                               content: channel.name,
                               startPt: .zero,
                               startId: channel.startId,
                               endPt: .zero,
                               endId : channel.endId)
        self.curves.append(curve)
    }
    
    func setSelectedChannel(_ identifier : String?) {
        print("\(#function)::\(identifier ?? "")")
        guard let identifier = identifier else {
            for (index, _) in curves.enumerated() {
                self.curves[index].selected = false
            }
            return
        }
        
        for (index, curve ) in curves.enumerated() {
            
            self.curves[index].selected = (curve.identifier == identifier)
            
        }
        
    }

    
    /// End the New Curve if it can be created
    /// - Parameters:
    ///   - point: the end point of the curve
    ///   - startId: the id of start point
    ///   - endId: the id of the end point
    /// - Returns: the uuid of the curve if it can be created
    func endNewCurve(at point : CGPoint, startId : String, endId : String) -> String? {
        
        //avoid repeated curve
        for curve in curves {
            if (curve.startId == startId && curve.endId == endId) || (curve.startId == endId && curve.endId == startId)  {
                print("NodeEditorView::\(#function)::RejectNewCurveDueToDuplication")
                tempCurve = nil
                return nil
            }
        }
        
        if var curve = tempCurve {
            curve.startId = startId
            curve.endId = endId
            curve.updatePath()
            curves.append(curve)
        }
        
        let identifier = tempCurve?.identifier
        tempCurve = nil
        return identifier
    }
    
    func discardNewCurve() {
        tempCurve = nil
    }
    
    func removeCurve(_ id : String) {
        if let index = curves.firstIndex(where: { $0.identifier == id }) {
            self.curves.remove(at: index)
        }
    }
    
    func removeDependedCurve(_ portIds : [String]){
        print("NodeEditorView::\(#function)::CurveCountBeforeRemoval: \(curves.count)")
        for curve in curves {
            if curve.hasDependencies(portIds) {
                if let index = curves.firstIndex(where: { $0.startId == curve.startId && $0.endId == curve.endId }) {
                    curves.remove(at: index)
                }
            }
        }
        print("NodeEditorView::\(#function)::CurveCountAfterRemoval: \(curves.count)")
    }
    
    override func draw(_ rect: CGRect) {
        //draw the center link
        

        
        // Get the current drawing context
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setLineWidth(1.0)
        let color = UIColor.lightGray.withAlphaComponent(0.3)
        context.setStrokeColor(color.cgColor)
        context.move(to: CGPoint(x: self.bounds.width / 2, y: 0))
        context.addLine(to: CGPoint(x: self.bounds.width / 2, y: self.bounds.height))
        context.strokePath()
        
        context.move(to: CGPoint(x: 0, y: self.bounds.height / 2))
        context.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height / 2))
        context.strokePath()
        
        // Set line width
        //context.setLineWidth(3.0)
        
        // Set line color
        context.setStrokeColor(UIColor.darkGray.cgColor)
        
        for curve in curves {
            
            
            
            if let path = curve.beizer {
                
                //TODO: - for selected path
                if curve.selected == true {
                    if let copiedPath = path.copy() as? UIBezierPath {
                        copiedPath.lineWidth = 10
                        UIColor.yellow.setStroke()
                        copiedPath.stroke()
                    }
                }
                
                
                UIColor.darkGray.setStroke()
                //path.lineWidth = 3
                path.stroke()
                
                //draw text
                let content = curve.content
                if content.count > 0 {
                    let strX = (curve.startPt.x + curve.endPt.x) / 2
                    let strY = (curve.startPt.y + curve.endPt.y) / 2

                    
                    var textAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                            .foregroundColor: UIColor.white
                        ]
                    
                    if curve.selected == false {
                        textAttributes[.foregroundColor] = UIColor.darkGray
                    }
                    
                    let text = content
                    let curveCenter = CGPoint(x: strX, y: strY)
                    // Calculate size of the text
                    let textSize = text.size(withAttributes: textAttributes)
                    
                    // Define padding
                    let padding = CGPoint(x: 10, y: 5)
                    let capsuleHeight = textSize.height + padding.y * 2
                    
                    // Calculate the capsule width
                    let capsuleWidth = textSize.width + padding.x * 2
                    
                    // Calculate the origin of the capsule so that curveCenter is at its center
                    let capsuleOrigin = CGPoint(
                        x: curveCenter.x - capsuleWidth / 2,
                        y: curveCenter.y - capsuleHeight / 2
                    )
                    
                    let capsuleRect = CGRect(
                        origin: capsuleOrigin,
                        size: CGSize(width: capsuleWidth, height: capsuleHeight)
                    )
                    
                    let capsulePath = UIBezierPath(roundedRect: capsuleRect, cornerRadius: capsuleHeight / 2)
                    
                    // Set capsule color
                    if curve.selected == false {
                        UIColor.white.setFill()
                    } else {
                        UIColor.darkGray.setFill()
                    }
                    capsulePath.fill()
                    
                    
                    if curve.selected == false {
                        // Stroke the capsule
                        //UIColor.yellow.setStroke()
                        UIColor.darkGray.setStroke()
                        capsulePath.lineWidth = 2
                        capsulePath.stroke()
                    }
                    
                    // Draw the text
                    let textRect = CGRect(
                        x: capsuleRect.origin.x + padding.x,
                        y: capsuleRect.origin.y + padding.y,
                        width: textSize.width,
                        height: textSize.height
                    )
                    
                    text.draw(in: textRect, withAttributes: textAttributes)
                }
            }

        }

        if let tempCurve = tempCurve {
            //draw current curve
            context.move(to: tempCurve.startPt)
            
            
            let halfDist = abs(tempCurve.startPt.x - tempCurve.endPt.x) / 2
            
            let cPt1 : CGPoint
            let cPt2 : CGPoint
            
            if tempCurve.startPt.x < tempCurve.endPt.x {
                
                cPt1 =  tempCurve.startPt + CGPoint(x: halfDist, y: 0)
                cPt2 =  tempCurve.endPt - CGPoint(x: halfDist, y: 0)

            } else {

                cPt1 =  tempCurve.startPt - CGPoint(x: halfDist, y: 0)
                cPt2 =  tempCurve.endPt + CGPoint(x: halfDist, y: 0)
                
            }
            
            // Draw the first line
            context.addCurve(to: tempCurve.endPt, control1: cPt1, control2: cPt2)
        }
        
        // Stroke the path
        context.setLineWidth(3)
        context.strokePath()
    }
    
}
