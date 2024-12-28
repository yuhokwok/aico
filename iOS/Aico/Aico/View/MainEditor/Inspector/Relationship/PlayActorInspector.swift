//
//  RoleInspector.swift
//  Aico
//
//  Created by itst on 18/10/2023.
//

import SwiftUI
import WrappingHStack
import UIKit




struct PlayActorInspector: View, BaseInspector {
    
    @State var url : String? = nil
    
    @StateObject var client = GenerativeClient()
    
    @FocusState private var focusState : Int?
    @Binding var editorState : EditorState
    
    var selectedId : String?
    var colorSet : BlockColorSet? 
    
    //@Binding var stage : StageGraph
    
    @State var identifier : String = ""
    @State var name : String
    @State var role : String = ""
    @State var description : String = ""
    @State var attrStr : String = ""
    @State var attribute : Attribute
    @State var personalityStr : String = ""
    @State var personality : Attribute
    
    @ObservedObject var handler : DocumentHandler
    
    var deleteHandler : (() -> ())?
    
    //undo redo
    var isUndoEnabled: Bool = false
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading ) {
                
                HStack {
                    InspectorTitle("Actor")
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            updateDescription()
                        }, label: {
                            HStack {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14).weight(.semibold))
                            }
                        })
                        .tint(.gray)
                        .frame(width: 32, height: 32)
                        .background {
                            Circle()
                                .fill(.gray.opacity(0.1))
                        }
                        .overlay {
                            Circle().fill(.clear).stroke(.gray.opacity(0.5), lineWidth: 1)
                        }
                        .padding(2)
                        
                        Button(action: {
                            deleteHandler?()
                        }, label: {
                            HStack {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14).weight(.semibold))
                            }
                        })
                        .tint(.gray)
                        .frame(width: 32, height: 32)
                        .background {
                            Circle()
                                .fill(.gray.opacity(0.1))
                        }
                        .overlay {
                            Circle().fill(.clear).stroke(.gray.opacity(0.5), lineWidth: 1)
                        }
                        .padding(2)
                    }
                    
                }
                    
                VStack {
                    HStack {
                        Spacer()
                        
                        if let url = url {
                            
                            AsyncImage(url: URL(string: url), content: {
                                image in
                                image                                .resizable()
                                    .frame(width:81, height: 81)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle()
                                            .fill(.clear)
                                            .stroke(.white, lineWidth: 5)
                                        
                                    }
                                    .shadow(radius: 5)
                                    .padding(10)
                            }, placeholder: {
                                if let colorSet = self.colorSet {
                                    
                                    Circle()
                                        .fill(Color(hex:"#F4F4F4"))
                                        .shadow(radius: 10, y: 2)
                                        .frame(width: 96)
                                        .overlay {
                                            Circle()
                                                .fill(colorSet.outterBorderGradient)
                                                .frame(width: 81)
                                        }
                                    
                                } else {
                                    Image("actress")
                                        .resizable()
                                        .frame(width:81, height: 81)
                                        .clipShape(Circle())
                                        .overlay {
                                            Circle()
                                                .fill(.clear)
                                                .stroke(.white, lineWidth: 5)
                                            
                                        }
                                        .shadow(radius: 5)
                                        .padding(10)
                                }
                            })

                        } else {
                            if let colorSet = self.colorSet {
                                
                                Circle()
                                    .fill(Color(hex:"#F4F4F4"))
                                    .shadow(radius: 10, y: 2)
                                    .frame(width: 96)
                                    .overlay {
                                        Circle()
                                            .fill(colorSet.outterBorderGradient)
                                            .frame(width: 81)
                                    }
                                
                            } else {
                                Image("actress")
                                    .resizable()
                                    .frame(width:81, height: 81)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle()
                                            .fill(.clear)
                                            .stroke(.white, lineWidth: 5)
                                        
                                    }
                                    .shadow(radius: 5)
                                    .padding(10)
                            }
                        }

                        Spacer()
                        
                    }
                }
                
                InspectorSectionTitle("Name")
                
                HStack {
                    TextField("", text: $name, prompt: Text("PlayActor Name"))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12, weight: .bold))
                        .onSubmit(of: .text) {
                            updateName()
                        }
                        .focused($focusState, equals: 1)
                }
                
                InspectorSectionTitle("Role")
                HStack {
                    TextField("", text: $role, prompt: Text("Role of the Actor"))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12, weight: .bold))
                        .onSubmit(of: .text) {
                            updateRole()
                        }
                        .focused($focusState, equals: 1)
                }
                
//                ZStack(alignment: .top) {
//                    if attribute.contents.count == 0  {
//                        HStack {
//                            Spacer()
//                            Text("This playactor has no occupation")
//                                .font(.system(size: 12))
//                                .foregroundStyle(.gray)
//                            Spacer()
//                        }
//                        .frame(minHeight: 60)
//                        .zIndex(0)
//                    } else {
//                        
//                        WrappingHStack (alignment: .leading) {
//                            ForEach(0..<attribute.contents.count, id:\.self) {
//                                i in
//                                
//                                HStack {
//                                    Text(attribute.contents[i].content)
//                                        .lineLimit(10)
//                                        .padding([.leading, .trailing], 8)
//                                        .font(.footnote)
//                                    Button(action: {
//                                        
//                                        deleteTag(i)
//                                        
//                                    }, label: {
//                                        Image(systemName: "xmark")
//                                            .font(.footnote)
//                                    })
//                                    .padding(2)
//                                    .background {
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .fill(.white.opacity(0.2))
//                                    }
//                                    .padding([.leading, .trailing], 2)
//                                }
//                                .background {
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .fill(UIColor.generateColor(from: attribute.contents[i].content).color)
//                                }
//                                .transition(.scale)
//                            }
//                        }
//                        .zIndex(1)
//                    }
//                }
//                .background {
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(.gray.opacity(0.1))
//                }
//                
//                HStack {
//                    TextField("Attribute", text: $attrStr)
//                        .textFieldStyle(.roundedBorder)
//                        .font(.system(size: 12))
//                        .onSubmit(of: .text) {
//                            self.addTag()
//                        }
//                    Button(action: {
//                        self.addTag()
//                    }, label: {
//                        Image(systemName: "plus")
//                    }).buttonStyle(.bordered)
//                }
                
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
                    client.genThumbnail(prompt: "a thumbnail", completion: {
                        url in
                        if url != "error" && url.isEmpty == false {
                            self.url = url
                        }
                        
                    })
                }, label: {
                    Text("Generate")
                        .font(.footnote)
                })
                .buttonStyle(.bordered)
                .tint(.black)
                
                if client.loading {
                    ProgressView().progressViewStyle(.circular)
                }
                                
                Text("\(identifier)")
                    .font(.system(size: 6))
            }
            .onChange(of: focusState, {
                
                
                //updateName()
                
            })
            .onChange(of: selectedId, initial: true, {
                print("changed")
                
                if let id = selectedId, let role = handler.entity(for: id) as? PlayActor {
                    self.identifier = role.identifier
                    self.name = role.name
                    self.role = role.role
                    self.description = role.description
                    self.attribute = role.attribute
                    self.personality = role.personality
                }
            })
            .onChange(of: editorState, initial: true, {
                print("changed")
                
                if let id = selectedId, let role = handler.entity(for: id) as? PlayActor {
                    self.identifier = role.identifier
                    self.name = role.name
                    self.role = role.role
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
    
    func updateRole() {
        guard role.count > 0 else {
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
        if let id = selectedId, var entity = handler.entity(for: id) as? PlayActor {
            entity.attribute = self.attribute
            entity.personality = self.personality
            entity.name = self.name
            entity.role  = self.role
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

