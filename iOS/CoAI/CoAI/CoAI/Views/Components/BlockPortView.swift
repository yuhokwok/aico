//
//  BlockPortView.swift
//  Aico
//
//  Created by Yu Ho Kwok on 10/5/24.
//


import SwiftUI


struct BlockPortView  : View {
    
    var port : Port
    var colorSet : BlockColorSet
    var centre : CGPoint = .zero
    var isLeft : Bool = true
    var screenSize : CGSize
    
    @Binding var node : PlayActor
    @Binding var currentLine: (start: CGPoint, end: CGPoint)?
   
    var connectionHandler : (Port, CGPoint) -> ()?
    
    
    var body: some View {
        
        RoundedRectangle(cornerRadius: 5)
            .fill(gradient)
            .frame(width: 30, height: 48)
            .overlay {
                HStack(spacing: 0) {
                    if isLeft == false {
                        Spacer()
                    }
                    RoundedRectangle(cornerRadius: 5)
                        .fill(colorSet.handleColor)
                        .frame(width: 10, height: 48)
                    
                    if isLeft {
                        Spacer()
                    }
                }
            }
            .highPriorityGesture (
                DragGesture()
                    .onChanged { value in
                        if isLeft == false {
                            self.currentLine = (start: CGPoint(x: node.center.x + 100 + screenSize.width / 2 + 10,
                                                               y: node.center.y + screenSize.height / 2),
                                                end: CGPoint(x: node.center.x + 100 + value.location.x + screenSize.width / 2 + 10,
                                                             y: node.center.y + value.location.y + screenSize.height / 2))
                        } else {
                            self.currentLine = (start: CGPoint(x: node.center.x - 100 + screenSize.width / 2 - 10,
                                                               y: node.center.y  + screenSize.height / 2),
                                                end: CGPoint(x: node.center.x - 100 + value.location.x + screenSize.width / 2 - 10,
                                                             y: node.center.y + value.location.y + screenSize.height / 2))
                        }
                        //manager.nodeViewModel.currentLine = (start: position(), end: value.location)
                    }
                    .onEnded { value in
                        if let endPt = self.currentLine?.end {
                            connectionHandler(port, endPt)
                        }
                        self.currentLine = nil
                    }
            )

        
    }
    
    var gradient : LinearGradient {
        if isLeft {
            return LinearGradient(colors: [colorSet.handleColor, .white.opacity(0.0)], startPoint: UnitPoint(x: 0.0, y: 0.5), endPoint: UnitPoint(x: 1.0, y: 0.5))
        }
        return LinearGradient(colors: [.white.opacity(0.0), colorSet.handleColor], startPoint: UnitPoint(x: 0.0, y: 0.5), endPoint: UnitPoint(x: 1.0, y: 0.5))
    }
}

