//
//  ChannelInspector.swift
//  Aico
//
//  Created by itst on 12/8/23.
//

import SwiftUI

struct ChannelInspector: View {
    
    @FocusState private var focusState : Int?
    
    @Binding var editorState : EditorState
    
    var selectedId : String? = ""
    
    //@Binding var stage : StageGraph
    
    @State var identifier : String = ""
    @State var name : String
    @State var description : String = ""
    @State var attrStr : String = ""
    @State var attribute : Attribute
    
    @ObservedObject var handler : DocumentHandler
    
    //undo redo
    var isUndoEnabled: Bool = false
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading ) {
                
                if editorState.mode.contains(.relationship) {
                    InspectorTitle("Relationship")
                } else {
                    InspectorTitle("Channel")
                }
                
                InspectorSectionTitle("Name")
                
                HStack {
                    TextField("", text: $name, prompt: Text( editorState.mode.contains(.relationship) ? "Worker" : "Name"))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12, weight: .bold))
                        .onSubmit(of: .text) {
                            updateName()
                        }
                        .focused($focusState, equals: 1)
                    Button {
                        updateName()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
                

                InspectorSectionTitle("Additional Information")
                
                TextEditor(text: $description)
                    .font(.system(size: 12))
                    .onSubmit(of: .text) {
                        updateDescription()
                    }
                    .focused($focusState, equals: 3)
                    .frame(height: 100)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(lineWidth: 1)
                    }
                    .padding(1)
                
                Button(action: {
                    updateDescription()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Set")
                        Spacer()
                    }
                }).buttonStyle(.borderedProminent)
                
                
                HStack {

                    Button(action: {
                        
                        self.delete()
                        
                    }, label: {
                        Spacer()
                        Image(systemName: "trash")
                        Spacer()
                    })
                    .buttonStyle(.bordered)
                    
                }
                
                Text("\(identifier)")
                    .font(.system(size: 6))
            }
            .onChange(of: focusState, {
                
                
                //updateName()
                
            })
            .onChange(of: editorState, initial: true, {
                print("changed")
                
                if let id = selectedId, let channel = handler.entity(for: id) as? Channel {
                    self.identifier = channel.identifier
                    self.name = channel.name
                    self.description = channel.description
                    self.attribute = channel.attribute
                }
            })
            
        }
        
    }
    
    func delete() {
        handler.deleteEntity(with: identifier)
    }
    
    func updateName(){
        guard name.count > 0 else {
            return
        }
        
        guard let id = selectedId, let entity = handler.entity(for: id) as? Channel, entity.name != self.name else {
            return
        }
        commitChange()
    }
    
    func updateDescription() {
        guard description.count > 0 else {
            return
        }
        
        guard let id = selectedId, let entity = handler.entity(for: id) as? Channel, entity.description != self.description else {
            return
        }
        commitChange()
    }
    
    func addTag() {
        if attrStr.isEmpty == false {
            withAnimation {
                let t = attrStr
                attribute.contents.append(AttributeEntry(id: UUID().uuidString,
                                                         content: t))
                attrStr = ""
                
                commitChange()
            }
        }
    }
    
    func deleteTag(_ index : Int){
        withAnimation {
            _ = attribute.contents.remove(at: index)
            commitChange()
        }
    }
    
    
    
    @MainActor
    func commitChange(){
        if let id = selectedId, var entity = handler.entity(for: id) as? Channel {
            entity.attribute = self.attribute
            entity.name = self.name
            entity.description = self.description

            if var graph = handler.graph(contains: id) as? RelationshipGraph {
                for (index, channel) in graph.channels.enumerated() {
                    if channel.identifier == entity.identifier {
                        graph.channels[index] = entity
                    }
                }
                
                handler.commit(graph, withId: graph.identifier)
            } else if var graph = handler.graph(contains: id) as? ProjectGraph {
                for (index, channel) in graph.channels.enumerated() {
                    if channel.identifier == entity.identifier {
                        graph.channels[index] = entity
                    }
                }
                
                handler.commit(graph, withId: graph.identifier)
            } else if var graph = handler.graph(contains: id) as? StageGraph {
                for (index, channel) in graph.channels.enumerated() {
                    if channel.identifier == entity.identifier {
                        graph.channels[index] = entity
                    }
                }
                
                handler.commit(graph, withId: graph.identifier)
            }
            
        }
    }
}

#Preview {
    ChannelInspector(editorState: .constant(EditorState(mode: .stage)),
                  name: "",
                  attrStr: "",
                  attribute: Attribute(id: UUID().uuidString, contents: []), handler: DocumentHandler(document: nil))
    .frame(width: 250)
}
