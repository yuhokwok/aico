//
//  MainEditorView.swift
//  Aico
//
//  Created by itst on 8/10/2023.
//

import SwiftUI
import Observation
import UIKit
import FirebaseAuth

@MainActor
struct MainEditorView: View {
    
    @State var isShowInspector = true
    @State var isShowInspectorPhone = false
    
    @StateObject var documentHandler : DocumentHandler
    
    @State var isShowRuntime = false
    
    @State var size : CGSize = .zero
    
    @State var shouldExpand = false
    

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
            
            Image("Bitmap", bundle: .main)
                .resizable()
            //.scaledToFill()
                .opacity(0.5)
            
            HStack {
                
                //Main Editor
                HStack (spacing: 0){
                    
                    //Main Editor
                    GeometryReader(content: { geometry in
                        
                        ZStack (alignment: .topTrailing) {
                            
                            if editorState.mode.contains(.relationship) {
                                
                                RelationshipGraphEditorContainer( mainEditorState: $documentHandler.project.editorState, documentHandler: documentHandler)
                                    .offset(x: 0, y: -yOffSet(height: geometry.size.height))
                                    .zIndex(1)
                                    .shadow( color: Color.gray.opacity(0.7),
                                             radius: 8,
                                             x: 0,
                                             y: 0
                                    )
                                    .background(.white.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 28))
                                    .transition(.scale.combined(with: .opacity))
                                
                            } else if editorState.mode.contains(.project) &&  !editorState.mode.contains(.stage) {
                                //MARK: - Stroyline Editor
                                
                                GeometryReader {
                                    reader in
                                    
                                    StorylineEditorView(documentHandler: documentHandler,
                                                        nodes: $documentHandler.project.projectGraph.nodes,
                                                        baseWidth: reader.size.width,
                                                        addAction: {
                                                                self.addNode()
                                                        })
                                }
                                
                                
                            } else {
                                
                                
                                MainEditorContainer(
                                    mainEditorState: $documentHandler.project.editorState,
                                    documentHandler: documentHandler)
                                .coordinateSpace(name: "mainEditorContainer")
                                .offset(x: 0, y: -yOffSet(height: geometry.size.height))
                                .onAppear {
                                    self.size = geometry.size
                                }
                                .onChange(of: geometry.size, {
                                    value, inInitial in
                                    print("size changed: \(value)")
                                    self.size = value
                                })
                                .zIndex(0)
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
                                .transition(.scale.combined(with: .opacity))
                                
                            }
                            
                            //MARK: - Tool Bar
                            HStack (alignment: .top) {
                                
                                HStack (alignment: .top) {

                                    VStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            Image(systemName: "photo.fill")
                                                .font(.system(size: 22, weight: .semibold))
                                                .foregroundColor(.blue)
                                            Text(sceneName)
                                                .padding(.horizontal, 10)
                                            
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                withAnimation {
                                                    shouldExpand.toggle()
                                                }
                                            }, label: {
                                                Image(systemName: shouldExpand ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                                    .font(.system(size: 22, weight: .semibold))
                                            })
                                            .tint(.orange)
                                        }
                                        .frame(height: 58)
                                        
                                        if (shouldExpand) {
                                            VStack (alignment:.leading, spacing: 0) {
                                                Text("Plot")
                                                    .font(.system(size: 17, weight: .semibold))
                                                    .padding(.vertical, 5)
                                                    .offset(y: -5)
                                                TextField(text: .constant("Hello"), label: {
                                                    Text("")
                                                })
                                                .padding(.horizontal, 10)
                                                .frame(maxWidth:.infinity)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(.gray, lineWidth: 1)
                                                        .frame(height: 56)
                                                        .padding(.horizontal, 1)
                                                }
                                                .frame(height: 56)
                                                Spacer()
                                            }
                                            .frame(height: 111)
                                       }
                                    }
                                    .frame(height: shouldExpand ? 169 : 58)
                                    .clipped()
                                    
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .frame(width: 402, height: shouldExpand ? 169 : 58)
                                .tint(.blue)
                                .background {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.white)
                                        .shadow( color: Color.gray.opacity(0.1),
                                                 radius: 5,
                                                 x: 0,
                                                 y: 0
                                        )
                                }
                                
                                
                                if (editorState.mode.contains(.stage)) {
                                    
                                    HStack {
                                        
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundColor(.blue)
                                        Text("Actors")
                                          
                                        Spacer()
                                        
                                        Button(action: {
                                            
                                            addNode()
                                            
                                        }, label: {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 22, weight: .semibold))
                                        })
                                        .tint(.orange)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .frame(width: 202, height: 58)
                                    .tint(.blue)
                                    .background {
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(.white)
                                            .shadow( color: Color.gray.opacity(0.1),
                                                     radius: 5,
                                                     x: 0,
                                                     y: 0
                                            )
                                    }
//                                    .onTapGesture {
//                                        documentHandler.project.editorState.mode.insert(.relationship)
//                                    }
                                }
                                
                                
                            }
                            .padding(20)
                        }
                        
                    })

                }
                
                //Inspector
                if (isShowInspector && UIDevice.current.userInterfaceIdiom == .pad && true) {
                    VStack{
     
                        //Inspector
                        if let id = editorState.selectedId, let entity = documentHandler.entity(for: id) {
                            //HStack {
                            
                            ZStack {
                                
                                VStack {
                                    
                                    Spacer().frame(height: 120)
                                    
                                    VStack {
                                        if let entity = entity as? Block {
                                            BlockInspector(editorState: $documentHandler.project.editorState,
                                                           name: entity.name,
                                                           attribute: entity.attribute,
                                                           handler: documentHandler,
                                                           showDelete: !(entity.name == "stageInput" || entity.name == "stageOutput"))
                                            .padding()
                                            
                                        } else if entity is Channel {
                                            if let entity = entity as? Channel {
                                                ChannelInspector(editorState: $documentHandler.project.editorState, name: entity.name, attribute: entity.attribute, handler: documentHandler)
                                                    .padding()
                                            }
                                        } else if let graph = entity as? StageGraph {
                                            if graph.name == "bigbang" {
                                                
                                                BigBangInspector(editorState: $documentHandler.project.editorState,
                                                                 description: graph.description,
                                                                 handler: documentHandler)
                                                .padding()
                                                
                                            } else {
                                                StageGraphInspector(editorState: $documentHandler.project.editorState,
                                                                    name: graph.name,
                                                                    attribute: graph.attribute,
                                                                    handler: documentHandler,
                                                                    showDelete: !documentHandler.project.editorState.mode.contains(.stage))
                                                .padding()
                                            }
                                            
                                        } else if entity is ProjectGraph{
                                            
                                            ProjectInspector(editorState: $documentHandler.project.editorState, selectedMode: .preset, description: "", handler: documentHandler)
                                                .padding()
                                            
                                        } else if entity is RelationshipGraph{
                                            RelationshipGraphInspector()
                                                .padding()
                                        } else if entity is PlayActor {
                                            if let entity = entity as? PlayActor {
                                                PlayActorInspector(editorState: $documentHandler.project.editorState, name: entity.name,
                                                                   attribute: entity.attribute, personality: entity.personality,
                                                                   handler: documentHandler)
                                                .padding()
                                            }
                                        }
                                    } .background {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.white)
                                            .stroke(.gray, lineWidth: 1)
                                    }
                                }
                                .padding()
                                .transition(.move(edge: .trailing))
                                .scaleEffect(x: isShowRuntime ? 0.95 : 1.0,
                                             y: isShowRuntime ? 0.95 : 1.0,
                                             anchor: .top)
                                .offset(y: isShowRuntime ? -10 : 0)
                                .opacity(isShowRuntime ? 0.7 : 1.0)
                                .zIndex(11)
                                
                                if isShowRuntime {
                                    VStack {
                                        
                                        Spacer().frame(height: 120)
                                        VStack {
                                            ExecuteView(runtime: Runtime(project: documentHandler.project))
                                        }
                                        
                                        .background {
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(.white)
                                                .stroke(.gray, lineWidth: 1)
                                        }
                                        
                                    }
                                    .padding()
                                    .zIndex(12)
                                    .transition(.move(edge: .bottom))
                                }
                                
                            }
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
                    .frame(width: 362)
                    .zIndex(0)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .background {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.white)
                            .shadow( color: Color.gray.opacity(0.3),
                                     radius: 15,
                                     x: 0,
                                     y: 0
                            )
                            .opacity(0.5)
                    }
                    .transition(.move(edge: .trailing))
                }

            }
            .padding(30)
            
            if true {
                //toolbar
                VStack {
                    Spacer().frame(height:10)
                    
                    HStack (spacing: 15) {
                        Spacer().frame(width: 0)
                        Button(action: {
                            if editorState.mode.contains(.stage) == false {
                                documentHandler.document?.project = documentHandler.project
                                
                                documentHandler.document?.close(completionHandler: {
                                    _ in
                                    hostCoordinator.delegate?.mainEditorDidRequestClosingDocument()
                                })
                            } else {
                                //back to project graph
                                
                                withAnimation {
                                    documentHandler.project.editorState.selectedId = documentHandler.project.editorState.selectedStageId
                                    documentHandler.project.editorState.selectedStageId = nil
                                    documentHandler.project.editorState.mode.remove(.stage)
                                }
                            }
                            
                        }, label: {
                            if editorState.mode.contains(.stage) == false {
                                Image(systemName: "chevron.backward")
                                    .frame(width: buttonSize, height: buttonSize)
                            } else {
                                Image(systemName: "chevron.backward")
                                    .frame(width: buttonSize, height: buttonSize)
                            }
                        })
                        .disabled(editorState.mode.contains(.relationship))
                        .frame(width: 68, height: 68)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .gray.opacity(0.3), radius: 5)
                        .offset(x: -40)
                        
                        
                        
                        Spacer()
                        
                        HStack (spacing: 15) {
                            
                            
//                            Button(action: {
//                                documentHandler.undo()
//                            }, label: {
//                                Image(systemName: "arrow.uturn.backward")
//                                    .frame(width: buttonSize, height: buttonSize)
//                            })
//                            .frame(width: buttonSize, height: buttonSize)
//                            .background(.regularMaterial)
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .shadow(color: .gray.opacity(0.3), radius: 5)
//                            
//                            if UIDevice.current.userInterfaceIdiom == .pad {
//                                Button(action: {
//                                    documentHandler.redo()
//                                }, label: {
//                                    Image(systemName: "arrow.uturn.forward")
//                                        .frame(width: buttonSize, height: buttonSize)
//                                })
//                                .frame(width: buttonSize, height: buttonSize)
//                                .background(.regularMaterial)
//                                .clipShape(RoundedRectangle(cornerRadius: 12))
//                                .shadow(color: .gray.opacity(0.3), radius: 5)
//                            }
//                            
                            Button(action: {
                                withAnimation {
                                    isShowRuntime.toggle()
                                }
                            }, label: {
                                Image(systemName: "play.fill")
                                    .frame(width: buttonSize, height: buttonSize)
                            })
                            .disabled(editorState.mode.contains(.relationship))
                            .frame(width: buttonSize, height: buttonSize)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray.opacity(0.3), radius: 5)
                            
//                            
//                            Button(action: {
//                                withAnimation(.bouncy) {
//                                    
//                                    if editorState.mode.contains(.relationship) {
//                                        self.documentHandler.project.editorState.mode.remove(.relationship)
//                                    } else {
//                                        self.documentHandler.project.editorState.mode.insert(.relationship)
//                                    }
//                                }
//                            }, label: {
//                                Image(systemName: "figure.stand.line.dotted.figure.stand")
//                            })
//                            .frame(width: buttonSize, height: buttonSize)
//                            .background(.regularMaterial)
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .shadow(color: .gray.opacity(0.3), radius: 5)
//                            
//                            
                            Button(action: {
                                withAnimation {
                                    if UIDevice.current.userInterfaceIdiom == .pad {
                                        isShowInspector.toggle()
                                    } else {
                                        isShowInspectorPhone.toggle()
                                    }
                                    
                                }
                            }, label: {
                                Image(systemName: UIDevice.current.userInterfaceIdiom == .pad ? "sidebar.right" : "rectangle.portrait.bottomhalf.inset.filled" )
                                    .frame(width: buttonSize, height: buttonSize)
                            })
                            .frame(width: buttonSize, height: buttonSize)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray.opacity(0.3), radius: 5)
                            
                        }
                        Spacer().frame(width: 15)
                    }
                    
                    Spacer()
                }
                .padding(40)
            }
            
        }
        .sheet(isPresented: $isShowInspectorPhone, content: {
            if let id = editorState.selectedId, let entity = documentHandler.entity(for: id) {
                //HStack {
                VStack {
                    
                    Spacer().frame(height: 20)
                    
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
                .background(.gray.opacity(0.05))
                .transition(.move(edge: .trailing))
                .presentationDetents([.fraction(0.5)])
                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.5)))
                .presentationCornerRadius(30)
                
            } else {
                Text("No Inspection")
                    .frame(width: 300)
                    .transition(.move(edge: .trailing))
            }
        })
        .ignoresSafeArea()
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
    
    @Environment(\.horizontalSizeClass) var horitzontalSizeClass
    
    var isTablet : Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isPortrait : Bool {
        return horitzontalSizeClass == .compact ? true : false
    }
    
    func yOffSet (height : CGFloat) -> CGFloat {
        return (isPortrait && isShowInspectorPhone) ? height / 5 : 0
    }
    
    
    var buttonSize : CGFloat {
        return isTablet ? 48 : 40
    }
    
    var sceneName : String {
        if editorState.mode.contains(.project) {
            return "Storyline"
        } else if editorState.mode.contains(.stage) {
            return "Scene 1"
        }
        return ""
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
