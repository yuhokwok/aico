//
//  BlockView.swift
//  Aico
//
//  Created by Yu Ho Kwok on 7/21/24.
//

import SwiftUI

enum BlockColor : String {
    case yellow = "yellow"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case red = "red"
    case gray = "gray"
}


struct BlockPortView  : View {
    
    var colorSet : BlockColorSet

    var centre : CGPoint = .zero

    

    
    var isLeft : Bool = true
    
    @Binding var currentLine: (start: CGPoint, end: CGPoint)?
    

    var body: some View {
        
        RoundedRectangle(cornerRadius: 5)
            .fill(gradient)
            .frame(width: 30, height: 48)
            .overlay {
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(colorSet.handleColor)
                        .frame(width: 10, height: 48)
                    Spacer()
                }
            }
            .highPriorityGesture (
                DragGesture()
                    .onChanged { value in
                        print("changed")
                        
                        if isLeft == false {
                            self.currentLine = (start: CGPoint(x: centre.x + 130, y: centre.y + 15),
                                                end: CGPoint(x: centre.x + 130 + value.location.x - 40, y: centre.y + value.location.y))
                        } else {
                            self.currentLine = (start: CGPoint(x: centre.x - 100, y: centre.y + 15),
                                                end: CGPoint(x: centre.x - 100 + value.location.x + 20, y: centre.y + value.location.y))
                        }
                        //manager.nodeViewModel.currentLine = (start: position(), end: value.location)
                    }
                    .onEnded { value in
//                        let endPoint = value.location
//                        let closeDistance: CGFloat = 30.0
//                        var didConnect = false
//                        
//                        for targetNode in manager.nodeViewModel.nodeCreator.nodes {
//                            let nodePositionAdjustment = port.portType == .input ? node.width / 2 : -node.width / 2
//                            let targetPorts = port.portType == .input ? targetNode.outputPorts : targetNode.inputPorts
//                            
//                            if attemptToConnect(port: port, from: node, to: targetPorts, targetNode: targetNode, nodePositionAdjustment: nodePositionAdjustment, nodeViewModel: manager.nodeViewModel, endPoint: endPoint, closeDistance: closeDistance) {
//                                didConnect = true
//                                break
//                            }
//                        }
//                        
//                        if !didConnect {
//                            manager.nodeViewModel.currentLine = nil
//                        }
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


struct BlockView: View {
    
    
    var colorSet = BlockColorSet.yellow
    

    @Binding var node : PlayActor
    
    
    @State var selected = true
    @Binding var currentLine : (start: CGPoint, end: CGPoint)?
    
    var name : String = "王詮勝"
    var roleName : String = "男主角"
    
    @State var translation : CGPoint? = nil
    @State var offset : CGSize? = nil
    
    var screenSize : CGSize
    
    var body: some View {
        
        
        GeometryReader {
            
            geometry in
            
            ZStack {
                
                HStack (spacing: 0) {
                    BlockPortView(colorSet: colorSet, centre: .zero,  currentLine: $currentLine)
                    Spacer()
                    BlockPortView(colorSet: colorSet, centre: .zero, isLeft: false, currentLine: $currentLine)
                }
                
                VStack {
                    
                    Circle()
                        .fill(Color(hex:"#F4F4F4"))
                        .shadow(radius: 10, y: 2)
                        .frame(width: 96)
                        .overlay {
                            Circle()
                                .fill(.blue)
                                .frame(width: 81)
                        }
                    
                    Text(name)
                        .foregroundStyle(Color(hex: "#00296B"))
                        .font(.system(size: 17, weight: .semibold))
                    Text(roleName)
                        .foregroundStyle(Color(hex: "#1668AC"))
                        .font(.system(size: 13, weight: .semibold))
                }
                .frame(width: 160, height: 170)
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.white)
                        .stroke(colorSet.innerBorderGradient, lineWidth: 1)
                        .shadow(color: colorSet.shadowColor.opacity(0.5), radius: 40, y: 6)
                        .shadow(color: Color(hex: "#000000").opacity(0.08), radius: 20)
                }
                .overlay {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 21)
                            .fill(.clear)
                            .stroke(.white.opacity(0.7), lineWidth: 5)
                            .frame(width: 166, height: 176)
                    }
                }
            }
            .frame(width: 204, height: 170)
            .overlay {
                
                if selected {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.clear)
                        .stroke(colorSet.outterBorderGradient, lineWidth: 10)
                        .frame(width: 194, height: 204)
                        .shadow(color: colorSet.shadowColor.opacity(0.5), radius: 8, y: 4)
                        .allowsHitTesting(false)
                }
            }
            .gesture(
                DragGesture(coordinateSpace: .named("Editor"))
                    .onChanged { value in
                        
                        //print("\(geometry.size)")
                        
                        if offset == nil {
                            
                            
                            //self.offset = CGSize(width: (self.center.x - value.startLocation.x), height: (self.center.y - value.startLocation.y))
                            
                            
                            //offset = CGPoint( x: (value.startLocation.x - self.center.x) / 2 , y: (value.startLocation.y - self.center.y) / 2)
//                            print(self.center)
//                            print(value.startLocation)
//                            print(offset)
                        }
                        
                        print(value.translation)
                        //self.translation = CGPoint(x: value.location.x, y: value.location.y)
                        self.offset = CGSize(width: value.location.x, height: value.location.y)
                    }
                    .onEnded {
                        value in
                        
                        node.center = CGPoint(x: (value.location.x ) - screenSize.width / 2, y: (value.location.y) - screenSize.height / 2)
                        self.translation = nil
                        self.offset = nil
                    }
            )
            .position(self.center)
            .offset(offset ?? .zero)
        }
    }
    
    var center : CGPoint {
        return CGPoint(x: node.center.x + screenSize.width / 2, y: node.center.y + screenSize.height / 2)
    }
}


struct BlockColorSet {
    var handleColor : Color
    var shadowColor : Color
    var innerBorderGradient : LinearGradient
    var outterBorderGradient : LinearGradient

    
    static var yellow : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#FFC95F"),
                             shadowColor: Color(hex: "#FFE06C"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#FAFF00"), Color(hex:"#FEB97B")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#FFB63D"), Color(hex:"#FFD87A")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
    
    
    static var green : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#65FF93"),
                             shadowColor: Color(hex: "#D4FF6F"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#D1FF65"), Color(hex:"#B0FFBC")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#65FF93"), Color(hex:"#B0FFBC")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
    
    
    static var blue : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#6ED7FF"),
                             shadowColor: Color(hex: "#AFF8FF"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#9DF6FF"), Color(hex:"#B0DBFF")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#6ED7FF"), Color(hex:"#AFE7FF")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
    
    static var purple : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#C692FF"),
                             shadowColor: Color(hex: "#CACDFF"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#9DA3FF"), Color(hex:"#FF9EED")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#C692FF"), Color(hex:"#FFC1F3")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
    
    static var red : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#FF6565"),
                             shadowColor: Color(hex: "#FFD2D7"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#FFC3CA"), Color(hex:"#F83A3A")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#FF6464"), Color(hex:"#FFB1B1")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
    
    static var gray : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#B2B2B2"),
                             shadowColor: Color(hex: "#C1C1C1"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#DADADA"), Color(hex:"#4F4F4F")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#B2B2B2"), Color(hex:"#DBDBDB")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
}


//#Preview {
//    VStack {
//        HStack {
//            BlockView(currentLine: .constant(nil))
//                .padding()
//            Spacer()
//        }
//        Spacer()
//    }
//}
