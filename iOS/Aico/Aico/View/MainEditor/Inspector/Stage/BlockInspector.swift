//
//  BlockInspector.swift
//  Aico
//
//  Created by Yu Ho Kwok on 18/10/2023.
//

import SwiftUI

struct BlockInspector: View, BaseInspector {
 
    @FocusState private var focusState : Int?
    
    @Binding var editorState : EditorState
    
    @State var identifier : String = ""
    @State var name : String
    @State var attrStr : String = ""
    @State var attribute : Attribute
            
    @ObservedObject var handler : DocumentHandler
    
    var showDelete : Bool
    
    var isUndoEnabled: Bool = false
    
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading ) {
                InspectorTitle("Block")
                InspectorSectionTitle("name")
                TextField("", text: $name, prompt: Text("Block Name"))
                    .textFieldStyle(.roundedBorder)
                    .disabled(!showDelete)
                if showDelete {
                    HStack {
                        
                        Button(action: {}, label: {
                            HStack {
                                Spacer()
                                Image(systemName: "doc.on.doc")
                                Spacer()
                            }
                            
                        })
                        .buttonStyle(.bordered)
                        
                        Button(action: {
                            self.delete()
                        }, label: {
                            Spacer()
                            Image(systemName: "trash")
                            Spacer()
                        })
                        .buttonStyle(.bordered)
                        
                    }
                }
                
                Text("\(identifier)")
                    .font(.system(size: 6))
            }
            
        }
        .onChange(of: editorState, initial: true, {
            print("changed")
            
            if let id = editorState.selectedId, let entity = handler.entity(for: id) as? Block {
                self.identifier = entity.identifier
                self.name = entity.name
                self.attribute = entity.attribute
            }
        })
    }
    
    
    func delete() {
        handler.deleteEntity(with: identifier)
    }
    
}

//#Preview {
//    BlockInspector(node: Block.init(name: "yo", center: .zero, size: .zero, role: Role(name: "", config: RoleConfig(), attribute: Attribute.new), attribute: Attribute.new, inChannels: [], outChannels: [], comChannels: []), text: "")
//}
