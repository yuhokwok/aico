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


struct BlockView: View {

    var colorSet = BlockColorSet.yellow
    
    @Binding var node : PlayActor
    
    var selected : Bool
    @Binding var currentLine : (start: CGPoint, end: CGPoint)?
    
    var name : String = "王詮勝"
    var roleName : String = "男主角"
    
    @State var translation : CGPoint? = nil
    @State var offset : CGSize? = nil
    
    var screenSize : CGSize
    
    @State private var location: CGPoint = CGPoint(x: 0, y: 0)
    @GestureState private var startLocation: CGPoint? = nil // 1
    
    var selectionHandler : (() -> ())?
    
    var portConnectionHandler : (Port, CGPoint) -> ()?
    
    var body: some View {

        GeometryReader {
            
            geometry in
            
            ZStack {
                
                HStack (spacing: 0) {
                    BlockPortView(port: node.inChannels.first!,
                                  colorSet: colorSet,
                                  centre: .zero,
                                  screenSize: screenSize, node: $node,
                                  currentLine: $currentLine,
                                  connectionHandler: portConnectionHandler)
                    Spacer()
                    BlockPortView(port: node.outChannels.first!,
                                  colorSet: colorSet,
                                  centre: .zero,
                                  isLeft: false,
                                  screenSize: screenSize, node: $node,
                                  currentLine: $currentLine,
                                  connectionHandler: portConnectionHandler)
                }
                
                VStack {
                    
                    Circle()
                        .fill(Color(hex:"#F4F4F4"))
                        .shadow(radius: 10, y: 2)
                        .frame(width: 96)
                        .overlay {
                            Circle()
                                .fill(colorSet.outterBorderGradient)
                                .frame(width: 81)
                        }
                    
                    Text(node.name)
                        .foregroundStyle(Color(hex: "#00296B"))
                        .font(.system(size: 17, weight: .semibold))
                    Text(node.role)
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
                //if selected {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.clear)
                        .stroke(colorSet.outterBorderGradient, lineWidth: 10)
                        .frame(width: 194, height: 204)
                        .shadow(color: colorSet.shadowColor.opacity(0.5), radius: 8, y: 4)
                        .allowsHitTesting(false)
                        .opacity(selected ? 1.0 : 0.0)
                        .scaleEffect(selected ? 1.0 : 0.9)
                        .animation(.easeInOut, value: selected)
                //}
            }
            .position(location)
            .gesture(
                dragGesture.simultaneously(with: TapGesture().onEnded({selectionHandler?()}))
            )
            .onChange(of: screenSize, initial: false, {
                oldValue, newValue in
                self.location = center
            })
            .onAppear {
                self.location = center
            }
        }
    }
    
    var center : CGPoint {
        return CGPoint(x: node.center.x + screenSize.width / 2, y: node.center.y + screenSize.height / 2)
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                selectionHandler?()
                var newLocation = startLocation ?? location // 3
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation
                self.node.center = CGPoint(x: location.x - screenSize.width / 2, y: location.y - screenSize.height / 2)
            }.updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location // 2
            }.onEnded {
                _ in
                self.node.center = CGPoint(x: location.x - screenSize.width / 2, y: location.y - screenSize.height / 2)
            }
    }
    
}



struct BlockColorSet {
    var handleColor : Color
    var shadowColor : Color
    var innerBorderGradient : LinearGradient
    var outterBorderGradient : LinearGradient

    static func get(_ string : String) -> BlockColorSet {
        guard let blockColor = BlockColor(rawValue: string) else {
            return .blue
        }
        
        switch(blockColor){
            
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .red:
            return .red
        case .gray:
            return .gray
        }
    }

    
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
