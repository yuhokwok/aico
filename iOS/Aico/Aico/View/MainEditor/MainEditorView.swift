//
//  MainEditorView.swift
//  Aico
//
//  Created by Yu Ho Kwok on 8/10/2023.
//

import SwiftUI
import Observation


@MainActor
struct MainEditorView: View {
    
    @State var showInspector = true
    
    
    @StateObject var documentHandler : DocumentHandler
    
    @State var isShowRuntime = false
    
    @State var size : CGSize = .zero
    
    
    var editorState : EditorState {
        documentHandler.project.editorState
    }
    
    
    //communication with hosting VC
    var hostCoordinator = MainEditorHostingCoorindator()
    
    //@State var editorState = EditorState()
    
    
    @State var isPresentRelationship : Bool = false {
        didSet {
            print("\(isPresentRelationship)")
        }
    }
    
    var body: some View {
        //defind the container
        
        
        ZStack {
            //Main Editor
            HStack {
                
                //Main Editor
                GeometryReader(content: { geometry in
                    
                    ZStack {
                        
                        MainEditorContainer(
                            mainEditorState: $documentHandler.project.editorState,
                            documentHandler: documentHandler)
                        .coordinateSpace(name: "mainEditorContainer")
                        .onAppear {
                            self.size = geometry.size
                        }
                        .onChange(of: geometry.size, {
                            value, inInitial in
                            print("size changed: \(value)")
                            self.size = value
                        }).zIndex(0)
                        
                            
                        if editorState.mode.contains(.relationship) {
                            ZStack (alignment: .topLeading){
                                Text("Relationship")
                                    .padding(25)
                                    .font(.title)
                                VStack {
                                    
                                    
                                    RelationshipGraphEditorContainer( mainEditorState: $documentHandler.project.editorState, documentHandler: documentHandler)
                                }
                            }
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .overlay {
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(.gray.opacity(0.1), lineWidth: 1)
                            }
                            .padding(60)
                            .shadow(color: .gray.opacity(0.2), radius: 10)
                            .transition(.scale.combined(with: .opacity))
                            .offset(y: 24)
                            .zIndex(1)
                            
                        }
                    }
                })
                
                //Inspector
                if (showInspector) {
                    //Inspector
                    if let id = editorState.selectedId, let entity = documentHandler.entity(for: id) {
                        //HStack {
                        VStack {
                            
                            Spacer().frame(height: 48)
                            
                            if let entity = entity as? Block {
                                BlockInspector(editorState: $documentHandler.project.editorState,
                                               name: entity.name,
                                               attribute: entity.attribute,
                                               handler: documentHandler,
                                               showDelete: !(entity.name == "stageInput" || entity.name == "stageOutput"))
                                
                            } else if entity is Channel {
                                if let entity = entity as? Channel {
                                    ChannelInspector(editorState: $documentHandler.project.editorState, name: entity.name, attribute: entity.attribute, handler: documentHandler)
                                }
                            } else if let graph = entity as? StageGraph {
                                if graph.name == "bigbang" {
                                    
                                    BigBangInspector(editorState: $documentHandler.project.editorState,
                                                     description: graph.description,
                                                     handler: documentHandler)
                                    
                                } else {
                                    StageGraphInspector(editorState: $documentHandler.project.editorState,
                                                        name: graph.name,
                                                        attribute: graph.attribute,
                                                        handler: documentHandler,
                                                        showDelete: !documentHandler.project.editorState.mode.contains(.stage))
                                }
                                
                            } else if entity is ProjectGraph{
                                
                                ProjectInspector(editorState: $documentHandler.project.editorState, selectedMode: .preset, description: "", handler: documentHandler)
                                
                            } else if entity is RelationshipGraph{
                                RelationshipGraphInspector()
                            } else if entity is PlayActor {
                                if let entity = entity as? PlayActor {
                                    PlayActorInspector(editorState: $documentHandler.project.editorState, name: entity.name,
                                                       attribute: entity.attribute, personality: entity.personality, 
                                                       handler: documentHandler)
                                }
                            }
                        }
                        .padding()
                        .frame(width: 300)
                        .background(.gray.opacity(0.05))
                        .transition(.move(edge: .trailing))
                        //.clipShape(RoundedRectangle(cornerRadius: 20))
                        //.shadow(radius: 10)
                        //.padding()
                        // }.transition(.move(edge: .trailing))
                    } else {
                        Text("No Inspection")
                            .frame(width: 300)
                            .transition(.move(edge: .trailing))
                    }
                }
            }
            
            
            //toolbar
            VStack {
                Spacer().frame(height:10)
                
                HStack (spacing: 15) {
                    Spacer().frame(width: 15)
                    Button(action: {
                        if editorState.mode.contains(.stage) == false {
                            documentHandler.document?.project = documentHandler.project

                            documentHandler.document?.close(completionHandler: {
                                _ in
                                hostCoordinator.delegate?.mainEditorDidRequestClosingDocument()
                            })
                        } else {
                            //back to project graph
                            documentHandler.project.editorState.selectedId = documentHandler.project.editorState.selectedStageId
                            documentHandler.project.editorState.selectedStageId = nil
                            documentHandler.project.editorState.mode.remove(.stage)
                        }
                         
                    }, label: {
                        if editorState.mode.contains(.stage) == false {
                            Image(systemName: "xmark")
                                .frame(width: 48, height: 48)
                        } else {
                            Image(systemName: "chevron.backward")
                                .frame(width: 48, height: 48)
                        }
                    })
                    .disabled(editorState.mode.contains(.relationship))
                    .frame(width: 48, height: 48)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .gray.opacity(0.3), radius: 5)
                    
                    
                    Button(action: {
                        documentHandler.undo()
                    }, label: {
                        Image(systemName: "arrow.uturn.backward")
                            .frame(width: 48, height: 48)
                    })
                    .frame(width: 48, height: 48)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .gray.opacity(0.3), radius: 5)

                    
                    Button(action: {
                        documentHandler.redo()
                    }, label: {
                        Image(systemName: "arrow.uturn.forward")
                            .frame(width: 48, height: 48)
                    })
                    .frame(width: 48, height: 48)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .gray.opacity(0.3), radius: 5)
                    
                    
                    Button(action: {
                        isShowRuntime = true
                    }, label: {
                        Image(systemName: "play.fill")
                            .frame(width: 48, height: 48)
                    })
                    .disabled(editorState.mode.contains(.relationship))
                    .frame(width: 48, height: 48)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .gray.opacity(0.3), radius: 5)

                    
                    Spacer()
                    
                    HStack (spacing: 15) {
                        
                        Button(action: {
                            withAnimation(.bouncy) {
                                
                                if editorState.mode.contains(.relationship) {
                                    self.documentHandler.project.editorState.mode.remove(.relationship)
                                } else {
                                    self.documentHandler.project.editorState.mode.insert(.relationship)
                                }
                            }
                        }, label: {
                            Image(systemName: "figure.stand.line.dotted.figure.stand")
                        })
                        .frame(width: 48, height: 48)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray.opacity(0.3), radius: 5)
                        
                        Button(action: {
                            
                            addNode()
                            
                        }, label: {
                            Image(systemName: "plus")
                                .frame(width: 48, height: 48)
                        })
                        .frame(width: 48, height: 48)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray.opacity(0.3), radius: 5)
                        
                        Button(action: {
                            withAnimation {
                                showInspector.toggle()
                            }
                        }, label: {
                            Image(systemName: "sidebar.right")
                                .frame(width: 48, height: 48)
                        })
                        .frame(width: 48, height: 48)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .gray.opacity(0.3), radius: 5)
                        
                    }
                    Spacer().frame(width: 15)
                }
                
                Spacer()
            }
            
        }
        .sheet(isPresented: $isShowRuntime, content: {
            Text("Executing Aico")
        })
    }
    
    
    func addNode() {
        
        
        if documentHandler.project.editorState.mode.contains(.relationship) {
            
            let id = documentHandler.project.relationshipGraph.identifier
            let bounds = CGRect(origin: .zero, size: size)
            documentHandler.addNodeForGraph(with: id, for: bounds)
            
        } else if documentHandler.project.editorState.mode.contains(.stage) {
            
            if let stageGraphId = documentHandler.project.editorState.selectedStageId {

                let bounds = CGRect(origin: .zero, size: size)
                documentHandler.addNodeForGraph(with: stageGraphId, for: bounds)
            }
            
        } else if documentHandler.project.editorState.mode == .project {
            
            let id = documentHandler.project.projectGraph.identifier
            let bounds = CGRect(origin: .zero, size: size)
            documentHandler.addNodeForGraph(with: id, for: bounds)
            
        }
        
        
    }
}

class MainEditorHostingCoorindator {
    var delegate : MainEditorHostingDelegate?
}


protocol MainEditorHostingDelegate {
    func mainEditorDidRequestClosingDocument()
}


#Preview {
    MainEditorView(documentHandler:
                    DocumentHandler(document: nil))
}
