//
//  MainEditorView.swift
//  Aico
//
//  Created by itst on 8/10/2023.
//

import SwiftUI
import Observation
import UIKit

@MainActor
struct MainEditorView: View {
    
    @State var isShowInspector = true
    @State var isShowInspectorPhone = false
    
    @StateObject var documentHandler : DocumentHandler
    
    @State var isShowRuntime = false

    @State var isShowRuntimePrompt = false
    @State var shouldExpand = false
    
    

    
    
    ///Editor
    ///
    ///
    @State var size : CGSize = .zero
    @State var selectedId: String? = nil///
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isScaling = false
    @State private var isDragging = false
    @State var currentLine: (start: CGPoint, end: CGPoint)? = nil
    
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
            
            AnimatedMeshView()
                .scaleEffect(x: 1.2, y: 1.2)
            
            HStack (spacing: 0){
                
                //Main Editor
                HStack (spacing: 0){
                    
                    
                    //Node Editor
                    GeometryReader(content: { geometry in
                        
                        ZStack (alignment: .topTrailing) {
                            
                            
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(.white.opacity(0.7), lineWidth: 5)
                                //.fill(Color.white.opacity(0.5))
                            
                            //Main Editor
                            ZStack (alignment: .topLeading)  {
                                
                                PlaceHolderView()
                            
                                Group {
                                    ForEach($documentHandler.project.relationshipGraph.nodes, id:\.identifier) {
                                        $node in
    
                                        BlockView(colorSet: BlockColorSet.get(node.color),
                                                  node: $node,
                                                  selected: (selectedId == node.id),
                                                  currentLine: $currentLine,
                                                  screenSize: geometry.size,
                                                  selectionHandler: { guard selectedId != node.id else { return }
                                            selectedId = node.id
                                        }, portConnectionHandler:  { connectionHandler(port: $0, endPt: $1, screenSize: geometry.size) } )
                                        
                                    }
                                                     
                                    ForEach(documentHandler.project.relationshipGraph.channels, id:\.identifier) {
                                        channel in
                                        
                                        ChannelView(channel: channel,
                                                    selected: (selectedId == channel.id),
                                                    graph: documentHandler.project.relationshipGraph,
                                                    screenSize: geometry.size, selectHandler: {
                                            selectedId = channel.identifier
                                        })
                                        
                                    }
                                                                        
                                    if let line = self.currentLine {
                                        
                                        Circle()
                                            .frame(width: 10, height: 10)
                                            .foregroundColor(.black)
                                            .position(line.start)
                                        
                                        GeometryReader { geometry in
                                            ZStack {
                                                
                                                Path { path in
                                                    path.move(to: line.start)
                                                    path.addLine(to: line.end)
                                                }
                                                .stroke(.black, lineWidth: 2)
                                            }
                                        }
                                        
                                        Circle()
                                            .frame(width: 10, height: 10)
                                            .foregroundColor(.black)
                                            .position(line.end)
                                        
                                    }
                                    
                                }
                                .scaleEffect(scale)
                                .offset(x: offset.width, y: offset.height)
                                
                                
                            }
                            .background(.regularMaterial)
                            .overlay {
                                ScrollView {
                                    DottedGrid(rows: Int(geometry.size.width / 27), columns: Int(geometry.size.height / 27))
                                        .allowsHitTesting(false)

                                }
                                .disabled(true)
                                .allowsHitTesting(false)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .contentShape(Rectangle())
                            .overlay {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(.clear)
                                    .strokeBorder(Color(hex: "#A8CBE7"), lineWidth: 1)
                            }
                            
                            .padding(5)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        if !isScaling {
                                            isScaling = true
                                            lastScale = scale
                                        }
                                        if !isDragging {
                                            withAnimation(.easeInOut(duration: 0.1)){
                                                scale = lastScale * value.magnitude
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        isDragging = false
                                        isScaling = false
                                    }
                                    .simultaneously(with: DragGesture()
                                        .onChanged { value in
                                            if !isDragging {
                                                isDragging = true
                                                lastOffset = offset
                                            }
                                            if !isScaling {
                                                offset = CGSize(width: lastOffset.width + value.translation.width, height: lastOffset.height + value.translation.height)
                                            }
                                        }
                                        .onEnded { _ in
                                            isDragging = false
                                            isScaling = false
                                        }
                                    )
                                    .simultaneously(with: TapGesture().onEnded({
                                        selectedId = nil
                                    }))
                            )
                            
                            
                            //Storyline Editor
                            VStack {
                                
                                Spacer()
                                
                                VStack {
                                    StorylineEditorView(documentHandler: documentHandler,
                                                        nodes: $documentHandler.project.projectGraph.nodes,
                                                        addAction: {
                                        self.addNode()
                                    })
                                }
                                .padding(.vertical, 10)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 26))
                                .overlay{
                                    RoundedRectangle(cornerRadius: 26)
                                        .fill(.clear)
                                        .stroke(.gray.opacity(0.2), lineWidth: 1)
                                }
                                .padding(10)
                                
                            }
                            .padding(15)
                            .zIndex(2)
                            
                                                        
                            //MARK: - Tool Bar
                            HStack (alignment: .top) {

                                HStack (alignment: .top) {
                                    
                                    VStack(spacing: 0) {
                                        
                                        ScrollView {
                                            
                                            HStack(spacing: 0) {
                                                Image(systemName: "photo.fill")
                                                    .foregroundStyle(Color(hex: "#008CFF"))
                                                    .font(.system(size: 26).weight(.semibold))
                                                Text(sceneName)
                                                    .padding(.horizontal, 10)
                                                    .foregroundStyle(Color(hex: "#00296B"))
                                                    .font(.system(size: 17).weight(.semibold))
                                                
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    withAnimation {
                                                        shouldExpand.toggle()
                                                    }
                                                }, label: {
                                                    Image(systemName: "chevron.down.circle.fill")
                                                        .font(.system(size: 26).weight(.semibold))
                                                        .rotationEffect(.degrees(shouldExpand ? 180 : 0))
                                                        .animation(.easeInOut(duration: 0.3), value: shouldExpand)
                                                })
                                                .tint(.orange)
                                            }
                                            .frame(height: 68)
                                            
                                            
                                            VStack (alignment:.leading, spacing: 0) {
                                                Text("Plot")
                                                    .foregroundStyle(Color(hex: "#00296B"))
                                                    .font(.system(size: 17).weight(.semibold))
                                                    .offset(y: -10)
                                                TextField(text: .constant("Hello"), label: {
                                                    Text("")
                                                })
                                                .foregroundStyle(Color(hex: "#00296B"))
                                                .font(.system(size: 17).weight(.semibold))
                                                .padding(.horizontal, 10)
                                                .frame(maxWidth:.infinity)
                                                .background {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(.white)
                                                        .stroke(Color(hex: "#E8E8E8"), lineWidth: 1)
                                                        .frame(height: 56)
                                                        .padding(.horizontal, 1)
                                                }
                                                .frame(height: 56)
                                                Spacer()
                                            }
                                            .frame(height: 111)
                                        }
                                        .scrollDisabled(true)
                                    }
                                    .frame(height: shouldExpand ? 169 : 68)
                                    .animation(.easeInOut, value: shouldExpand)
                                    .clipped()
                                    
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .frame(width: 402, height: shouldExpand ? 169 : 68)
                                .background(LinearGradient(colors: [.white.opacity(0.0), .white],
                                                           startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 0.5)))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.clear)
                                        .stroke(Color(hex: "#E6F2FC"), lineWidth: 1)
                                }
                                //.shadow(color: Color(hex: "#A8CBE7"), radius: 4, y: 2)
                                
                                HStack {
                                    Spacer().frame(width: 22)
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(Color(hex: "#008CFF"))
                                        .font(.system(size: 26).weight(.semibold))
                                    
                                    Text("Actors")
                                        .foregroundStyle(Color(hex: "#00296B"))
                                        .font(.system(size: 17).weight(.semibold))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        self.addBlock()
                                    }, label: {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundStyle(.orange)
                                            .font(.system(size: 26).weight(.semibold))
                                    })
                                    Spacer().frame(width: 22)
                                }
                                .frame(width: 212, height: 68)
                                .background(LinearGradient(colors: [.white.opacity(0.0), .white],
                                                           startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 0.5)))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.clear)
                                        .stroke(Color(hex: "#E6F2FC"), lineWidth: 1)
                                }
                                //.shadow(color: Color(hex: "#A8CBE7"), radius: 4, y: 2)
                                
                                
                                HStack  {
                                    Button(action: {
                                        withAnimation {
                                            isShowRuntimePrompt.toggle()
                                        }
                                    }, label: {
                                        Image(systemName: "play.fill")
                                            .frame(width: buttonSize, height: buttonSize)
                                            .foregroundStyle(Color(hex: "#008CFF"))
                                            .font(.system(size: 18).weight(.semibold))
                                    })
                                    .disabled(editorState.mode.contains(.relationship))
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(.regularMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .shadow(color: .gray.opacity(0.3), radius: 5)
                                    
//                                    Button(action: {
//                                        withAnimation {
//                                            if UIDevice.current.userInterfaceIdiom == .pad {
//                                                isShowInspector.toggle()
//                                            } else {
//                                                isShowInspectorPhone.toggle()
//                                            }
//                                            
//                                        }
//                                    }, label: {
//                                        Image(systemName: UIDevice.current.userInterfaceIdiom == .pad ? "sidebar.right" : "rectangle.portrait.bottomhalf.inset.filled" )
//                                            .frame(width: buttonSize, height: buttonSize)
//                                            .foregroundStyle(Color(hex: "#008CFF"))
//                                            .font(.system(size: 18).weight(.semibold))
//                                    })
//                                    .frame(width: buttonSize, height: buttonSize)
//                                    .background(.regularMaterial)
//                                    .clipShape(RoundedRectangle(cornerRadius: 18))
//                                    .shadow(color: .gray.opacity(0.3), radius: 5)
                                    
                                }

                            }
                            .padding(20)
                            .zIndex(3)
                        }
                        
                    })
                }
                

                //Inspector
                if (isShowInspector && UIDevice.current.userInterfaceIdiom == .pad) {
                    Spacer().frame(width: 5)
                    

                        VStack (spacing: 0) {
                            VStack(spacing : 0) {

                                //Inspector
                                if let id = selectedId, let entity = documentHandler.entity(for: id) {

                                    ZStack {
                                        
                                        VStack {
                                            
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
                                                        ChannelInspector(editorState: $documentHandler.project.editorState,
                                                                         selectedId: selectedId,
                                                                         name: entity.name, attribute: entity.attribute, handler: documentHandler)
                                                            .padding(10)
                                                    }
                                                } else if let graph = entity as? StageGraph {
                                                    if graph.name == "bigbang" {
                                                        
                                                        BigBangInspector(editorState: $documentHandler.project.editorState,
                                                                         description: graph.description,
                                                                         handler: documentHandler)
                                                        .padding(10)
                                                        
                                                    } else {
                                                        StageGraphInspector(editorState: $documentHandler.project.editorState,
                                                                            name: graph.name,
                                                                            attribute: graph.attribute,
                                                                            handler: documentHandler,
                                                                            showDelete: !documentHandler.project.editorState.mode.contains(.stage))
                                                        .padding(10)
                                                    }
                                                    
                                                } else if entity is ProjectGraph{
                                                    
                                                    ProjectInspector(editorState: $documentHandler.project.editorState, selectedMode: .preset, description: "", handler: documentHandler)
                                                        .padding(10)
                                                    
                                                } else if entity is RelationshipGraph{
                                                    RelationshipGraphInspector()
                                                        .padding(10)
                                                } else if entity is PlayActor {
                                                    if let entity = entity as? PlayActor {
                                                        PlayActorInspector(editorState: $documentHandler.project.editorState,
                                                                           selectedId: selectedId,
                                                                           colorSet: BlockColorSet.get(entity.color),
                                                                           name: entity.name,
                                                                           attribute: entity.attribute, personality: entity.personality,
                                                                           handler: documentHandler, deleteHandler : {
                                                            if let selecteId = self.selectedId {
                                                                documentHandler.deleteEntity(with: selecteId)
                                                                self.selectedId = nil
                                                            }
                                                        })
                                                        .padding(10)
                                                    }
                                                }
                                            } .background {
                                                RoundedRectangle(cornerRadius: 18)
                                                    .fill(.white)
                                                    .stroke(.gray.opacity(0.2), lineWidth: 1)
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
                                                    RoundedRectangle(cornerRadius: 26)
                                                        .fill(.white)
                                                        .stroke(.gray.opacity(0.2), lineWidth: 1)
                                                }
                                                
                                            }
                                            .padding()
                                            .zIndex(12)
                                            .transition(.move(edge: .bottom))
                                        }
                                        
                                    }

                                } else  if let id = documentHandler.project.editorState.selectedStageId, let entity = documentHandler.entity(for: id) {
                                    
                                    ZStack {
                                        
                                        VStack {
                                            
                                            VStack {
                                                if let graph = entity as? StageGraph {
                                                    if graph.name == "bigbang" {
                                                        
                                                        BigBangInspector(editorState: $documentHandler.project.editorState,
                                                                         description: graph.description,
                                                                         handler: documentHandler)
                                                        .padding(10)
                                                        
                                                    } else {
                                                        StageGraphInspector(editorState: $documentHandler.project.editorState,
                                                                            name: graph.name,
                                                                            attribute: graph.attribute,
                                                                            handler: documentHandler,
                                                                            showDelete: !documentHandler.project.editorState.mode.contains(.stage))
                                                        .padding(10)
                                                    }
                                                    
                                                } else if entity is ProjectGraph{
                                                    
                                                    ProjectInspector(editorState: $documentHandler.project.editorState, selectedMode: .preset, description: "", handler: documentHandler)
                                                        .padding(10)
                                                    
                                                } else if entity is RelationshipGraph{
                                                    RelationshipGraphInspector()
                                                        .padding(10)
                                                }
                                            } .background {
                                                RoundedRectangle(cornerRadius: 18)
                                                    .fill(.white)
                                                    .stroke(.gray.opacity(0.2), lineWidth: 1)
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
                                                    RoundedRectangle(cornerRadius: 26)
                                                        .fill(.white)
                                                        .stroke(.gray.opacity(0.2), lineWidth: 1)
                                                }
                                                
                                            }
                                            .padding()
                                            .zIndex(12)
                                            .transition(.move(edge: .bottom))
                                        }
                                        
                                    }
                                    
                                    
                                } else {
                                    VStack {
                                        Spacer()
                                        
                                        HStack {
                                            Spacer()
                                            Text("No Inspection")
                                            Spacer()
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(.clear)
                                    .strokeBorder(LinearGradient(colors: [Color(hex: "#8EB6FF"), Color(hex: "#787EFF"),
                                                                    Color(hex: "#FF89D7"), Color(hex: "#FFD589")],
                                                           startPoint: UnitPoint(x: -0.2, y: -0.2),
                                                           endPoint: UnitPoint(x: 1.2, y: 1.2)), lineWidth: 1)
                            }
                            .background {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Material.regularMaterial)
                                    .strokeBorder(LinearGradient(colors: [Color(hex: "#8EB6FF"), Color(hex: "#787EFF"),
                                                                    Color(hex: "#FF89D7"), Color(hex: "#FFD589")],
                                                           startPoint: UnitPoint(x: -0.2, y: -0.2),
                                                           endPoint: UnitPoint(x: 1.2, y: 1.2)), lineWidth: 1)
                            }
                            .padding(5)
                            .background() {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(.clear)
                                    .strokeBorder(.white.opacity(0.7), lineWidth: 5)
                            }

                        }
                        .zIndex(0)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .background {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.clear)
                                .shadow( color: Color(hex:"#FDFDFD").opacity(0.6),
                                         radius: 15,
                                         x: 0,
                                         y: 0
                                )
                                
                                .opacity(0.5)
                        }
                        
                        .frame(width: 350)
                        .transition(.move(edge: .trailing))
                    
                }
            }
            .padding(20)
            
            
            //toolbar
            
            VStack {

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
                                .foregroundStyle(Color(hex: "#1668AC"))
                                .font(.system(size: 17).weight(.semibold))
                        } else {
                            Image(systemName: "chevron.backward")
                                .frame(width: buttonSize, height: buttonSize)
                                .foregroundStyle(Color(hex: "#1668AC"))
                                .font(.system(size: 17).weight(.semibold))
                        }
                    })
                    .disabled(editorState.mode.contains(.relationship))
                    .frame(width: 68, height: 68)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.clear)
                            .stroke(Color(hex: "#E8E8E8"), lineWidth: 1)
                    }
                    .shadow(color: .gray.opacity(0.3), radius: 5)
                    .offset(x: -45)
                    
                    
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(40)
            
            
            
        }
        .ignoresSafeArea()
        .sheet(isPresented: $isShowRuntimePrompt, content: {
            VStack {

                    ExecuteView(runtime: Runtime(project: documentHandler.project))
                
            }
            .presentationCornerRadius(26)
        })
        
    }
    
    func connectionHandler(port : Port, endPt : CGPoint, screenSize : CGSize) {
        var hasTarget = false
        //let screenSize = geometry.size
        for targetNode in documentHandler.project.relationshipGraph.nodes {
            if port.kind == .inChannel {
                
                let center = CGPoint(x: targetNode.center.x + screenSize.width / 2 + 95,
                                     y: targetNode.center.y + screenSize.height / 2)
                
                
                var rect = CGRect(origin: center, size: CGSize(width: 1, height: 1))
                rect = CGRectInset(rect, -50, -50)
                
                if CGRectContainsPoint(rect, endPt) {
                    hasTarget = true
                    var canConnect = true
                    for channel in documentHandler.project.relationshipGraph.channels {
                        
                        if ((channel.startId == port.id && channel.endId == targetNode.outChannels.first!.id) ||
                            (channel.endId == port.id && channel.startId == targetNode.outChannels.first!.id)) {
                            
                            canConnect  = false
                            break
                        }
                    }
                    
                    if canConnect {
                        print("inPort \(port.id) to outPort \(targetNode.outChannels.first!.id)")
                        let channel = Channel(identifier: UUID().uuidString,
                                              startId: targetNode.outChannels.first!.id,
                                              endId: port.id,
                                              attribute: Attribute(id: UUID().uuidString, contents: []))
                        documentHandler.project.relationshipGraph.channels.append(channel)
                    }
                    
                    break
                }
                
            } else if port.kind == .outChannel {
                
                let center = CGPoint(x: targetNode.center.x + screenSize.width / 2 - 95,
                                     y: targetNode.center.y + screenSize.height / 2)
                
                
                var rect = CGRect(origin: center, size: CGSize(width: 1, height: 1))
                rect = CGRectInset(rect, -50, -50)
                
                if CGRectContainsPoint(rect, endPt) {
                    hasTarget = true
                    
                    print("try outPort \(port.id) to inPort \(targetNode.inChannels.first!.id)")
                    
                    var canConnect = true
                    for channel in documentHandler.project.relationshipGraph.channels {
                        if ((channel.startId == port.id && channel.endId == targetNode.inChannels.first!.id) ||
                            (channel.endId == port.id && channel.startId == targetNode.inChannels.first!.id)) {
                            
                            print("wtf ch outPort \(channel.startId) to inPort \(channel.endId)")
                            print("wtf outPort \(port.id) to inPort \(targetNode.inChannels.first!.id)")
                            
                            canConnect  = false
                            
                            
                            break
                        }
                    }
                    
                    if canConnect {
                        print("commit outPort \(port.id) to inPort \(targetNode.inChannels.first!.id)")
                        let channel = Channel(identifier: UUID().uuidString,
                                              startId: port.id,
                                              endId: targetNode.inChannels.first!.id,
                                              attribute: Attribute(id: UUID().uuidString, contents: []))
                        documentHandler.project.relationshipGraph.channels.append(channel)
                    }
                    
                    
                    break
                }
            }
        }
        
        if hasTarget == false {
            addBlock(from: port, at: endPt)
        }
        
    }
    
    func addBlock(from port : Port? = nil, at point : CGPoint? = nil ) {
        
        guard let port = port, let point = point else {
            //click add button
            let id = documentHandler.project.relationshipGraph.identifier
            let bounds = CGRect(origin: .zero, size: size)
            documentHandler.addNodeForGraph(with: id, for: bounds)
            return
        }
        
        //add at pooint
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
        return isTablet ? 68 : 58
    }
    
    var sceneName : String {
        return "Storyline"
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
