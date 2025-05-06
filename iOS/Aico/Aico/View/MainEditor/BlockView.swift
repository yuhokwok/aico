//
//  BlockView.swift
//  Aico
//
//  Created by Yu Ho Kwok on 7/21/24.
//

import SwiftUI


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
                                .overlay {
                                    if let image = node.thumbnail {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 81, height: 81)
                                            .clipShape(Circle())
                                    }
                                }
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
                RoundedRectangle(cornerRadius: 28)
                    .fill(.clear)
                    .stroke(colorSet.outterBorderGradient, lineWidth: 10)
                    .frame(width: 194, height: 204)
                    .shadow(color: colorSet.shadowColor.opacity(0.5), radius: 8, y: 4)
                    .allowsHitTesting(false)
                    .opacity(selected ? 1.0 : 0.0)
                    .scaleEffect(selected ? 1.0 : 0.9)
                    .animation(.easeInOut, value: selected)
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
