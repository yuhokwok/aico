//
//  ProjectInspector.swift
//  Aico
//
//  Created by Yu Ho Kwok on 12/8/23.
//

import SwiftUI

struct ProjectInspector: View {
    
    @FocusState private var focusState : Int?
    
    @Binding var editorState : EditorState
    
    @State var selectedMode : ProjectGraph.Mode = .preset
    @State var description : String
    
    @ObservedObject var handler : DocumentHandler
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                
                InspectorTitle("Project")
                
                InspectorSectionTitle("AI 模式")
                
                Picker(selection: $selectedMode, content: {
                    
                    Text("Preset").tag(ProjectGraph.Mode.preset)
                    Text("Dynamic").tag(ProjectGraph.Mode.dynamic)
                    
                }, label: {
                    Text("Mode")
                })
                .pickerStyle(.segmented)
                .onChange(of: selectedMode, {
                    commitChange()
                })
                
                
                if (selectedMode == .preset) {
                    
                    InspectorSectionFooter("預設模式，AI 運作 時只會按預先設定好的 Graph 運作去計算結果，比較安全的做法。")
                        .frame(height: 80)
                } else {
                    
                    InspectorSectionFooter("動態模式，AI 運作 時會按需要加入新的工作設定，或者加入新的人物及關係，可能會有意想不到的效果。")
                        .frame(height: 80)
                    
                }
                
                InspectorSectionTitle("Project Desciption")
                
                TextEditor(text: $description)
                    .font(.system(size: 14))
                    .contentMargins(10)
                    .frame(minHeight: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.gray.opacity(0.3), lineWidth: 0.5)
                    }
                    .focused($focusState, equals: 3)
                    .onSubmit(of: .text) {
                        commitChange()
                    }
                
                Button(action: {
                    self.commitChange()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Set")
                        Spacer()
                    }
                })
                .buttonStyle(.borderedProminent)
                .padding([.top, .bottom], 5)
                
                Spacer()
            }
            .onChange(of: editorState, initial: true, {
                if let id = editorState.selectedId, let projectGraph = handler.graph(for: id) as? ProjectGraph {
                    
                    self.selectedMode = projectGraph.mode
                    self.description = projectGraph.description
                    
                }
            })
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
//        .onDisappear {
//            print("on disappear")
//            commitChange()
//        }
    }
    
    @MainActor
    func commitChange() {
        
        if let id = editorState.selectedId, var graph = handler.graph(for: id) as? ProjectGraph {
            
            guard graph.mode != self.selectedMode ||
                  graph.description != self.description else {
                print("same context, ignore update")
                return
            }
            
            graph.mode = self.selectedMode
            graph.description = self.description
            handler.commit(graph, withId: graph.identifier)

        }
        
    }
}

#Preview {
    ProjectInspector(editorState: .constant(EditorState(mode: .project)), description: "", handler: DocumentHandler(document: nil))
        .frame(width: 250)
}


