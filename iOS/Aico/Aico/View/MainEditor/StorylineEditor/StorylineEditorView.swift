//
//  StorylineEditor.swift
//  Aico
//
//  Created by Yu Ho Kwok on 5/4/24.
//

import SwiftUI

struct StorylineEditorView: View {
    
    
    @ObservedObject var documentHandler : DocumentHandler
    
    @Binding var nodes : [StageGraph]
    @State private var draggedStage: StageGraph?
    
    
    var baseWidth : CGFloat = 800
    
    var addAction : (()->(Void))?
    
    var body: some View {
        
        ZStack {
            VStack {
                Spacer()
                ScrollView (.horizontal) {
                    
                    Spacer()
                    ZStack (alignment: .leading) {
                        
                        HStack{
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color("BarColor", bundle: .main))
                                .stroke(Color("BarColorStroke", bundle: .main), lineWidth: 1)
                                .frame(width: barWidth, height: 31)
                                .offset(x: 75)
                            
                        }
                        
                        HStack (spacing: 50) {
                            Spacer().frame(width: 100)
                            ForEach(nodes, id:\.identifier) {
                                stage in
                                
                                
                                StorylineCell(title: stage.name, subtitle: stage.description, selected: documentHandler.project.editorState.selectedId == stage.identifier)
                                    .onDrag({
                                        self.draggedStage = stage
                                        return NSItemProvider()
                                    })
                                    .onDrop(of: [.text],
                                            delegate: DropViewDelegate(destinationItem: stage,
                                                                       nodes: $nodes,
                                                                       draggedItem: $draggedStage)
                                    )
                                    
                                    .onTapGesture(count: 2){
                                        print("dbl tap")
                                        documentHandler.project.editorState.selectedStageId = stage.identifier
                                        documentHandler.project.editorState.mode = .stage
                                        
                                    }
                                    .onTapGesture {
                                        documentHandler.project.editorState.selectedId = stage.identifier
                                    }
                                
                            }
                        }
                    }
                    Spacer()
                }
                .scrollIndicators(.hidden)
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        addAction?()
                    }, label: {
                        Text("Create Scene")
                    })
                    Text("hihi")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Spacer()
                }
                .background(.white.opacity(0.4))
                .frame(height: 237)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding()
            }
        }
        .background(.clear)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .background {
            RoundedRectangle(cornerRadius: 28)
                .fill(.white)
                .shadow( color: Color.gray.opacity(1.0),
                         radius: 15,
                         x: 0,
                         y: 0
                )
                .opacity(0.4)
        }
        
        
    }
    
    var barWidth : CGFloat {
        let nodeWidth = CGFloat(nodes.count) * 260
        if nodeWidth < baseWidth {
            return baseWidth
        }
        return nodeWidth
    }
}

#Preview {
    
    @State var documentHandler = DocumentHandler(document: nil)
    
    return GeometryReader {
        reader in
        
        ZStack {
            
            Image("Bitmap", bundle: .main)
                .resizable()
            //.scaledToFill()
                .opacity(0.5)
            
            
            StorylineEditorView(documentHandler: documentHandler,
                                nodes: $documentHandler.project.projectGraph.nodes,
                                baseWidth: reader.size.width)
            
        }
    }
}
