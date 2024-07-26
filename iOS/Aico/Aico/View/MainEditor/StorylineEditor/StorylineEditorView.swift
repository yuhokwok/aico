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
            
            
            ScrollView (.horizontal) {
                
                HStack (spacing: 50) {
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
                        .onTapGesture(count: 2){
                            print("dbl tap")
                            documentHandler.project.editorState.selectedStageId = stage.identifier
                            documentHandler.project.editorState.mode.insert(.stage)
                            
                        }
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
                                        .font(.system(size: 18))
                                        .bold()
                                    
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
                                        .fill(.blue)
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
                }
                    .padding(.vertical, 20)
            }
            .scrollIndicators(.hidden)
            
        }
        .background {
            GeometryReader {
                reader in
                
                
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("BarColor", bundle: .main))
                    .stroke(Color("BarColorStroke", bundle: .main), lineWidth: 1)
                    .frame(width: barWidth(baseWidth: reader.size.width), height: 31)
                    .offset(x: 75, y: 65)
                
                
            }
        }
        
    }
    
    
    func barWidth (baseWidth : CGFloat) -> CGFloat {
        let nodeWidth = CGFloat(nodes.count) * 260
        if nodeWidth < baseWidth {
            return 2000
        }
        return nodeWidth
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
