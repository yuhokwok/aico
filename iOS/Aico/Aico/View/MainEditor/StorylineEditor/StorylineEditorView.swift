//
//  StorylineEditor.swift
//  Aico
//
//  Created by itst on 5/4/24.
//

import SwiftUI

struct StorylineEditorView: View {
    
    
    @ObservedObject var documentHandler : DocumentHandler
    
    @Binding var nodes : [StageGraph]
    @State private var draggedStage: StageGraph?
    
    
    //var baseWidth : CGFloat = 800
    
    var addAction : (()->(Void))?
    
    var body: some View {
        
        //ZStack {
        VStack {
            Spacer()
            
            
            GeometryReader {
                scrollviewGeometry in
                ScrollView (.horizontal) {
                    
                    ZStack (alignment: .leading) {
                        

                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color("BarColor", bundle: .main))
                            .stroke(Color("BarColorStroke", bundle: .main), lineWidth: 1)
                            .frame(width: getBarWidth(scrollviewGeometry, nodes.count),
                                   height: 31)
                            .offset(x: 75, y: 0)
                        
                        HStack (spacing: 30) {
                            Spacer().frame(width: 100)
                            
                            ForEach(nodes) {
                                stage in
                                
                                
                                StorylineCell(title: stage.name,
                                              subtitle: stage.description,
                                              selected: documentHandler.project.editorState.selectedId == stage.identifier)
                                .onDrag({
                                    self.draggedStage = stage
                                    return NSItemProvider()
                                })
                                .onDrop(of: [.text],
                                        delegate: DropStageGraphCellDelegate(destinationItem: stage,
                                                                             nodes: $nodes,
                                                                             draggedItem: $draggedStage)
                                )
                                .onTapGesture {
                                    documentHandler.project.editorState.selectedId = stage.identifier
                                }
                            }
                            
                            
                            Button (action: {
                                addAction?()
                            }, label: {
                                HStack {
                                    HStack {
                                        Spacer()
                                        VStack (alignment: .center) {
                                            
                                            Spacer()
                                            
                                            Text("Create Scene")
                                                .font(.system(size: 17))
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color(hex: "#00296B"))
                                            
                                        }
                                        Spacer()
                                    }
                                }
                                .frame(width: 160, height: 106)
                                .overlay {
                                    Image("addScene")
                                        .frame(width: 72, height: 72)
                                        .background {
                                            Circle()
                                                .fill(LinearGradient(colors: [Color(hex: "#4CCDFF"), Color(hex: "#259EFF")], startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1.0)))
                                                .stroke(.white, lineWidth: 1)
                                                .shadow(color: .blue, radius: 5)
                                        }
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.white)
                                        .stroke(.white, lineWidth: 1)
                                }
                                .padding(5)
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Material.ultraThin)
                                        .shadow(radius: 10)
                                    //.opacity(0.5)
                                }
                            })
                            
                            Spacer().frame(width: 30)
                        }
                        .padding(.vertical, 20)
                    }
                    
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                .frame(maxWidth: .infinity)
                
            }
            
            Spacer()
        }
        .frame(height: 180)
        
    }
    
    func getBarWidth(_ scrollViewProxy : GeometryProxy,
                     _ nodeCount : Int) -> CGFloat {
        print("\(scrollViewProxy.size) vs \(nodeCount)")
        return max(scrollViewProxy.size.width, CGFloat(nodeCount + 1) * (30 + 165) + 200 )
    }
    
}

#Preview {
    
    @Previewable @State var documentHandler = DocumentHandler(document: nil)
    
    
    ZStack {
        
        Image("Bitmap", bundle: .main)
            .resizable()
            .opacity(0.5)
        
        VStack {
            Spacer()
            StorylineEditorView(documentHandler: documentHandler,
                                nodes: $documentHandler.project.projectGraph.nodes)
        }
    }
    
}
