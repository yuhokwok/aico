//
//  RoleInspector.swift
//  Aico
//
//  Created by Yu Ho Kwok on 18/10/2023.
//

import SwiftUI
import WrappingHStack
import UIKit




struct PlayActorInspector: View, BaseInspector {
    
    @FocusState private var focusState : Int?
    
    @Binding var editorState : EditorState
    
    //@Binding var stage : StageGraph
    
    @State var identifier : String = ""
    @State var name : String
    @State var description : String = ""
    @State var attrStr : String = ""
    @State var attribute : Attribute
    @State var personalityStr : String = ""
    @State var personality : Attribute
    
    @ObservedObject var handler : DocumentHandler
    
    //undo redo
    var isUndoEnabled: Bool = false
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading ) {
                InspectorTitle("Playactor")
                
                InspectorSectionTitle("Name")
                
                HStack {
                    TextField("", text: $name, prompt: Text("PlayActor Name"))
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
                    }.buttonStyle(.bordered)
                }
                
                InspectorSectionTitle("Occupation")
                
                ZStack(alignment: .top) {
                    if attribute.contents.count == 0  {
                        HStack {
                            Spacer()
                            Text("This playactor has no occupation")
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                            Spacer()
                        }
                        .frame(minHeight: 60)
                        .zIndex(0)
                    } else {
                        
                        WrappingHStack (alignment: .leading) {
                            ForEach(0..<attribute.contents.count, id:\.self) {
                                i in
                                
                                HStack {
                                    Text(attribute.contents[i].content)
                                        .lineLimit(10)
                                        .padding([.leading, .trailing], 8)
                                        .font(.footnote)
                                    Button(action: {
                                        
                                        deleteTag(i)
                                        
                                    }, label: {
                                        Image(systemName: "xmark")
                                            .font(.footnote)
                                    })
                                    .padding(2)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.white.opacity(0.2))
                                    }
                                    .padding([.leading, .trailing], 2)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(UIColor.generateColor(from: attribute.contents[i].content).color)
                                }
                                .transition(.scale)
                            }
                        }
                        .zIndex(1)
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.opacity(0.1))
                }
                
                HStack {
                    TextField("Attribute", text: $attrStr)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                        .onSubmit(of: .text) {
                            self.addTag()
                        }
                    Button(action: {
                        self.addTag()
                    }, label: {
                        Image(systemName: "plus")
                    }).buttonStyle(.bordered)
                }
                
                InspectorSectionTitle("Personality")
                
                ZStack(alignment: .top) {
                    if personality.contents.count == 0  {
                        HStack {
                            Spacer()
                            Text("No Personality Set")
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                            Spacer()
                        }
                        .frame(minHeight: 60)
                        .zIndex(0)
                    } else {
                        
                        WrappingHStack (alignment: .leading) {
                            ForEach(0..<personality.contents.count, id:\.self) {
                                i in
                                
                                HStack {
                                    Text(personality.contents[i].content)
                                        .lineLimit(10)
                                        .padding([.leading, .trailing], 8)
                                        .font(.footnote)
                                    Button(action: {
                                        
                                        deletePersonlity(i)
                                        
                                    }, label: {
                                        Image(systemName: "xmark")
                                            .font(.footnote)
                                    })
                                    .padding(2)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.white.opacity(0.2))
                                    }
                                    .padding([.leading, .trailing], 2)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(UIColor.generateColor(from: personality.contents[i].content).color)
                                }
                                .transition(.scale)
                            }
                        }
                        .zIndex(1)
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.opacity(0.1))
                }
                
                HStack {
                    TextField("Personality", text: $personalityStr)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))
                        .onSubmit(of: .text) {
                            self.addPersonality()
                        }
                    Button(action: {
                        self.addPersonality()
                    }, label: {
                        Image(systemName: "plus")
                    }).buttonStyle(.bordered)
                }
                
                InspectorSectionTitle("Background Information")
                
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
                    
                    Button(action: {}, label: {
                        HStack {
                            Spacer()
                            Image(systemName: "doc.on.doc")
                            Spacer()
                        }
                        
                    })
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        delete()
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
                
                if let id = editorState.selectedId, let role = handler.entity(for: id) as? PlayActor {
                    self.identifier = role.identifier
                    self.name = role.name
                    self.description = role.description
                    self.attribute = role.attribute
                    self.personality = role.personality
                }
            })
            
        }
        
    }
    
    func updateName() {
        guard name.count > 0 else {
            return
        }
        commitChange()
    }
    
    func updateDescription(){
        guard description.count > 0 else {
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
    
    func delete() {
        handler.deleteEntity(with: identifier)
    }
    
    
    func deleteTag(_ index : Int){
        withAnimation {
            _ = attribute.contents.remove(at: index)
            commitChange()
        }
    }
    
    func addPersonality() {
        if personalityStr.isEmpty == false {
            withAnimation {
                let t = personalityStr
                personality.contents.append(AttributeEntry(id: UUID().uuidString,
                                                         content: t))
                personalityStr = ""
                
                commitChange()
            }
        }
    }
    
    func deletePersonlity(_ index : Int){
        withAnimation {
            _ = personality.contents.remove(at: index)
            commitChange()
        }
    }
    
    @MainActor
    func commitChange(){
        if let id = editorState.selectedId, var entity = handler.entity(for: id) as? PlayActor {
            entity.attribute = self.attribute
            entity.personality = self.personality
            entity.name = self.name
            entity.description = self.description

            if var graph = handler.graph(contains: id) as? RelationshipGraph {
                for (index, role) in graph.nodes.enumerated() {
                    if role.identifier == entity.identifier {
                        graph.nodes[index] = entity
                    }
                }
                
                handler.commit(graph, withId: graph.identifier)
            }
            
        }
    }
}

#Preview {
    PlayActorInspector(editorState: .constant(EditorState(mode: .stage)),
                  name: "",
                  attrStr: "",
                       attribute: Attribute.new, personality: Attribute.new, handler: DocumentHandler(document: nil))
    .frame(width: 250)
}

