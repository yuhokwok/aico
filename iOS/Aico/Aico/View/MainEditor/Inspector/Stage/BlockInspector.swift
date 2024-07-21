//
//  BlockInspector.swift
//  Aico
//
//  Created by itst on 18/10/2023.
//

import SwiftUI
import WrappingHStack

struct BlockInspector: View, BaseInspector {
 
    @FocusState private var focusState : Int?
    
    @Binding var editorState : EditorState
    
    
    @StateObject var client = GenerativeClient()
    
    
    @State var identifier : String = ""
    @State var name : String
    @State var role : String = ""
    @State var attrStr : String = ""
    @State var attribute : Attribute
    @State var thumbnail : String = ""

    
    @ObservedObject var handler : DocumentHandler
    
    var showDelete : Bool
    var isUndoEnabled: Bool = false
    
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading ) {
                InspectorTitle("Block")
                
                
                VStack {
                    HStack {
                        Spacer()
                        
                        if thumbnail.isEmpty == false {
                            
                            AsyncImage(url: URL(string: thumbnail), content: {
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
                            })

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

                        Spacer()
                        
                    }
                    Button(action: {
                        client.genThumbnail(prompt: "\(role)", completion: {
                            url in
                            if url != "error" && url.isEmpty == false {
                                self.thumbnail = url
                                save()
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
                }
                
                
                InspectorSectionTitle("name")
                TextField("", text: $name, prompt: Text("Name"))
                    .textFieldStyle(.roundedBorder)
                    .disabled(!showDelete)
                    .onSubmit {
                        save()
                    }
                
                InspectorSectionTitle("role")
                TextField("", text: $role, prompt: Text("Role"))
                    .textFieldStyle(.roundedBorder)
                    .disabled(!showDelete)
                    .onSubmit {
                        save()
                    }
                
                
                ZStack(alignment: .top) {
                    if attribute.contents.count == 0  {
                        HStack {
                            Spacer()
                            Text("This playactor has no specific task")
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
                
                
                if showDelete {
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
                self.thumbnail = entity.thumbnail ?? ""
                self.role = entity.role
                self.attribute = entity.attribute
            }
        })
    }
    
    func save() {
        if let id = editorState.selectedId, var entity = handler.entity(for: id) as? Block {
            
            entity.name = self.name
            entity.attribute = self.attribute
            entity.thumbnail = self.thumbnail
            entity.role = self.role
            entity.attribute = self.attribute

            if var graph = handler.graph(contains: id) as? StageGraph {
                for (index, role) in graph.nodes.enumerated() {
                    if role.identifier == entity.identifier {
                        graph.nodes[index] = entity
                    }
                }
                
                handler.commit(graph, withId: graph.identifier)
            }
            
        }
    }
    
    func addTag() {
        if attrStr.isEmpty == false {
            withAnimation {
                let t = attrStr
                attribute.contents.append(AttributeEntry(id: UUID().uuidString,
                                                         content: t))
                attrStr = ""
                
                save()
            }
        }
    }
    
    
    func deleteTag(_ index : Int){
        withAnimation {
            _ = attribute.contents.remove(at: index)
            save()
        }
    }
    
    func delete() {
        handler.deleteEntity(with: identifier)
    }
    
}

#Preview {
    @StateObject var handler = DocumentHandler(document: nil)
    return BlockInspector(editorState: $handler.project.editorState, name: "yo", attribute: Attribute(id: UUID().uuidString, contents: []), handler: handler, showDelete: true)
        .frame(width: 250)
}
