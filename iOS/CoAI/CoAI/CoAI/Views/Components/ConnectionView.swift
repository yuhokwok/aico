//
//  ConnectionView.swift
//  NodeCreater
//
//  Created by Po hin Ma on 7/5/2024.
//

import SwiftUI

struct ChannelView: View {
    
    
    var channel: Channel
    var selected : Bool
    var graph : any Graph
    var screenSize : CGSize
    var selectHandler : (() -> ())?
    
    var body: some View {
        
        return ZStack {
            
            Circle()
                .frame(width: 16, height: 16)
                .foregroundColor(.yellow)
                .position(startPoint)
                .opacity(selected ? 1.0 : 0.0)
                .animation(.easeInOut, value: selected)
            
            Circle()
                .frame(width: 16, height: 16)
                .foregroundColor(.yellow)
                .position(endPoint)
                .opacity(selected ? 1.0 : 0.0)
                .animation(.easeInOut, value: selected)
            
            if channel.name.count > 0 {
                
                Text("\(channel.name)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.yellow)
                    .padding()
                    .background(.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18).stroke(.yellow, lineWidth: 8)
                    }
                    .position( CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2))
                    .opacity(selected ? 1.0 : 0.0)
                    .animation(.easeInOut, value: selected)
            }
            
            GradientLine(startPoint: startPoint, endPoint: endPoint)
                .stroke(.yellow,
                        lineWidth: 8)
                .opacity(selected ? 1.0 : 0.0)
                .animation(.easeInOut, value: selected)



            
            Circle()
                .frame(width: 10, height: 10)
                .foregroundColor(.black)
                .position(startPoint)
            
            Circle()
                .frame(width: 10, height: 10)
                .foregroundColor(.black)
                .position(endPoint)
            
            GradientLine(startPoint: startPoint, endPoint: endPoint)
                .stroke(.black,
                        lineWidth: 2)
            
            
            if channel.name.count > 0 {
                
                
                Text("\(channel.name)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding()
                    .background(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .position( CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2))
                
                
            }

        }
        .onTapGesture {
            selectHandler?()
        }
    }
    
    
    var startPoint : CGPoint {
        if let node = graph.nodes.filter( { $0.outChannels.first?.id == channel.startId } ).first {
            return CGPoint(x: node.center.x +  screenSize.width / 2 + 100 + 10,
                           y: node.center.y +  screenSize.height / 2 )
        }
        return .zero
    }
    
    var endPoint : CGPoint {
        if let node = graph.nodes.filter( { $0.inChannels.first?.id == channel.endId } ).first {
            return CGPoint(x: node.center.x +  screenSize.width / 2 - 100 - 10,
                           y: node.center.y +  screenSize.height / 2 )
        }
        return .zero
    }
}

struct GradientLine: Shape {
    var startPoint: CGPoint
    var endPoint: CGPoint
    
    func path(in rect: CGRect) -> Path {

        let halfDist = abs(startPoint.x - endPoint.x) / 2
        let cPt1 : CGPoint
        let cPt2 : CGPoint
        if startPoint.x < endPoint.x {
            cPt1 =  startPoint + CGPoint(x: halfDist, y: 0)
            cPt2 =  endPoint - CGPoint(x: halfDist, y: 0)
        } else {
            cPt1 =  startPoint - CGPoint(x: halfDist, y: 0)
            cPt2 =  endPoint + CGPoint(x: halfDist, y: 0)
        }
        
        
        var path = Path()
        path.move(to: startPoint)
        //path.addLine(to: endPoint)
        path.addCurve(to: endPoint, control1: cPt1, control2: cPt2)
        return path
    }
}

//#Preview {
//    ConnectionView(connection: Connection(startPort: Port(offset: .zero, portType: .input, nodeID: "YoYo"), endPort: Port(offset: .zero, portType: .output, nodeID: "YoYo")), node: Node(name: "HIHI", position: .zero))
//}
