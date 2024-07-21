//
//  BigBangInspector.swift
//  Aico
//
//  Created by itst on 18/10/2023.
//

import SwiftUI
import WrappingHStack
import UIKit



struct BigBangInspector: View, BaseInspector {
    
    @FocusState private var focusState : Int?
    
    @Binding var editorState : EditorState
    
    @State var identifier : String = ""
    @State var description : String

    @ObservedObject var handler : DocumentHandler
    

    //undo redo
    var isUndoEnabled: Bool = false
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                
                InspectorTitle("Big Bang")
                
                
                VStack(alignment: .leading) {
                    Text("Description of Task")
                        .lineLimit(nil)
                        .font(.system(size: 12, weight: .bold))
                    
                    Text("寫啲嘢嚟教下個 AI 點樣運作吧，唔唔是好聰明的，要靠你教佢做嘢了。")
                        .lineLimit(nil)
                        .font(.system(size: 12))
                }

                VStack(alignment: .leading) {
                                        
                    TextEditor(text: $description)
                        .font(.system(size: 12))
                        .onSubmit(of: .text) {
                            commitChange()
                        }
                        .focused($focusState, equals: 3)
                        .frame(height: 200)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 1)
                                .fill(.clear)
                                
                        }
                        .padding(2)
                    
                    Button(action: {
                        self.commitChange()
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Set")
                            Spacer()
                        }
                    }).buttonStyle(.bordered)
                }
                

                Text("\(identifier)")
                    .font(.system(size: 6))

            }
            .onChange(of: focusState, {
                commitChange()
            })
            .onChange(of: editorState, initial: true, {
                if let id = editorState.selectedId, let stageGraph = handler.graph(for: id) as? StageGraph {
                    
                    self.identifier = stageGraph.identifier
                    self.description = stageGraph.description
                }
            })

        }
        
    }
    
    @MainActor
    func commitChange(){

        if let id = editorState.selectedId, var graph = handler.graph(for: id) as? StageGraph {
            
            guard graph.description != self.description else {
                print("same context, ignore update")
                return
            }
            
            graph.description = self.description
            handler.commit(graph, withId: graph.identifier)

        }
    }
    
}

#Preview {
    BigBangInspector(editorState: .constant(EditorState(mode: .stage)), description: "", handler: DocumentHandler(document: nil))
        .frame(width: 250)
}

