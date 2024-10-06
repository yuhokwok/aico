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
            
            //            if selected {
            Circle()
                .frame(width: 16, height: 16)
            //                .foregroundColor(.red)
                .foregroundColor(.yellow)
                .position(startPoint)
                .opacity(selected ? 1.0 : 0.0)
                .animation(.easeInOut, value: selected)
            
            Circle()
                .frame(width: 16, height: 16)
            //.foregroundColor(.green)
                .foregroundColor(.yellow)
                .position(endPoint)
                .opacity(selected ? 1.0 : 0.0)
                .animation(.easeInOut, value: selected)
            
            
            GeometryReader { geometry in
                GradientLine(startPoint: startPoint, endPoint: endPoint)
                    .stroke(.yellow,
                            lineWidth: 8)
                    .opacity(selected ? 1.0 : 0.0)
                    .animation(.easeInOut, value: selected)
                
                //                LinearGradient(
                //                    gradient: Gradient(colors: [.red, .green]),
                //                    startPoint: UnitPoint(x: startPoint.x / geometry.size.width, y: startPoint.y / geometry.size.height),
                //                    endPoint: UnitPoint(x: endPoint.x / geometry.size.width, y: endPoint.y / geometry.size.height))
            }
//            }
            


            
            Circle()
                .frame(width: 10, height: 10)
//                .foregroundColor(.red)
                .foregroundColor(.black)
                .position(startPoint)
            
            Circle()
                .frame(width: 10, height: 10)
                //.foregroundColor(.green)
                .foregroundColor(.black)
                .position(endPoint)
            
            GeometryReader { geometry in
                GradientLine(startPoint: startPoint, endPoint: endPoint)
                    .stroke(.black,
                        lineWidth: 2)
                
//                LinearGradient(
//                    gradient: Gradient(colors: [.red, .green]),
//                    startPoint: UnitPoint(x: startPoint.x / geometry.size.width, y: startPoint.y / geometry.size.height),
//                    endPoint: UnitPoint(x: endPoint.x / geometry.size.width, y: endPoint.y / geometry.size.height))
            }

        }
        .onTapGesture {
            //manager.selectedID = (manager.selectedID == connection.id) ? "" : connection.id
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
//        
//        var midX = (startPoint.x + endPoint.x) / 2
//        var midY = (startPoint.y + endPoint.y) / 2
//        
        
        
        var path = Path()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        return path
    }
}

//#Preview {
//    ConnectionView(connection: Connection(startPort: Port(offset: .zero, portType: .input, nodeID: "YoYo"), endPort: Port(offset: .zero, portType: .output, nodeID: "YoYo")), node: Node(name: "HIHI", position: .zero))
//}
