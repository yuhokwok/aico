//
//  MainEditorView.swift
//  CoAI
//
//  Created by Yu Ho Kwok on 10/8/24.
//

import SwiftUI

struct MainEditorView: View {
    var namespace : Namespace.ID
    @StateObject var handler : DocumentHandler
    var backAction : (() -> ())
    
    var sceneName = "Storyline"
    @State var shouldExpand = false
    @State var isShowRuntime = false

    
    //Editor
    @State var size : CGSize = .zero
    @State var selectedId: String? = nil///
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isScaling = false
    @State private var isDragging = false
    @State var currentLine: (start: CGPoint, end: CGPoint)? = nil
    
    
    var body: some View {
        
        ZStack {
            HStack {
                ZStack  (alignment: .topTrailing) {
                    
                    ZStack{
                        
                        GeometryReader {
                            geometry in
                            
                            ZStack {
                                
                                PlaceHolderView()
                                
                                //Editor Thing
                                if handler.isReady {
                                    
                                    ZStack {
                                        Group {
                                            
                                            ForEach(handler.project.relationshipGraph.channels, id:\.identifier) {
                                                channel in
                                                
                                                ChannelView(channel: channel,
                                                            selected: (selectedId == channel.id),
                                                            graph: handler.project.relationshipGraph,
                                                            screenSize: geometry.size, selectHandler: {
                                                    selectedId = channel.identifier
                                                })
                                            }
                                            
                                            
                                            ForEach($handler.project.relationshipGraph.nodes, id:\.identifier) {
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
                                    .overlay {
                                        ScrollView {
                                            DottedGrid(rows: Int(geometry.size.width / 27),
                                                       columns: Int(geometry.size.height / 27))
                                            .allowsHitTesting(false)
                                            
                                        }
                                        .disabled(true)
                                        .allowsHitTesting(false)
                                    }
                                    .contentShape(Rectangle())
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
                                    .onAppear {
                                        if let offset = handler.project.editorState.editorOffset,
                                            let scale = handler.project.editorState.editorScale {
                                            
                                            withAnimation {
                                                self.offset = offset
                                                self.scale = scale
                                            }
                                        }
                                    }
                                    
                                    //Storyline Editor
                                    VStack {
                                        
                                        Spacer()
                                        
                                        VStack {
                                            StorylineEditorView(documentHandler: handler,
                                                                nodes: $handler.project.projectGraph.nodes,
                                                                addAction: {
                                                self.addNode()
                                            })
                                        }
                                        .padding(.vertical, 10)
                                        .background(
                                            ZStack {
                                                Rectangle().fill(Material.ultraThin)
                                                Rectangle().fill(LinearGradient(colors: [.white.opacity(0), .white],
                                                                                startPoint: UnitPoint(x: 0.5, y: 0.5),
                                                                                endPoint: UnitPoint(x: 0.5, y: 1.0)))
                                            }
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 26))
                                        .overlay{
                                            RoundedRectangle(cornerRadius: 26)
                                                .fill(.clear)
                                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                                        }
                                        .shadow(color: Color(hex: "#A8CBE7").opacity(0.33), radius: 5, y: 4)
                                        .padding(10)
                                        
                                    }
                                    .padding(15)
                                    .zIndex(2)
                                    
                                    
                                } else {
                                    VStack {
                                        ProgressView().progressViewStyle(.circular)
                                        Text("Loading")
                                    }
                                }
                                
                            }
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .shadow(color: Color(hex: "#A8CBE7").opacity(0.33), radius: 10, y: 4)
                            .contentShape(Rectangle())
                            .overlay {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(.clear)
                                    .strokeBorder(Color(hex: "#A8CBE7"), lineWidth: 1)
                            }
                            .padding(5)
                            
                        }
                        
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.clear)
                            .strokeBorder(.white.opacity(0.7), lineWidth: 5)
                        
                    }
                    .matchedGeometryEffect(id: "TheBox", in: namespace)
                    .onAppear {
                        print("on appear")
                        
                        
                    }
                    
                    
                    //toolbar
                    VStack {
                        
                        Spacer().frame(height: 25)
                        HStack (spacing: 0) {
                            Spacer().frame(width: 0)
                            Button(action: {
                                
                                guard handler.document != nil else {
                                    self.backAction()
                                    return
                                }
                                
                                //save the editor offset and scale
                                handler.project.editorState.editorOffset = offset
                                handler.project.editorState.editorScale = scale

                                handler.document?.project = handler.project
                                

                                handler.document?.close(completionHandler: {
                                    _ in
                                    self.backAction()
                                })
                                
                            }, label: {
                                Image(systemName: "chevron.backward")
                                    .frame(width: buttonSize, height: buttonSize)
                                    .foregroundStyle(Color(hex: "#1668AC"))
                                    .font(.system(size: 17).weight(.semibold))
                            })
                            //.disabled(editorState.mode.contains(.relationship))
                            .frame(width: 68, height: 68)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(.clear)
                                    .stroke(Color(hex: "#E8E8E8"), lineWidth: 1)
                            }
                            .shadow(color: .gray.opacity(0.3), radius: 5)
                            .offset(x: -10)
                            .transition(.move(edge: .leading))
                            
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
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
                        .background(
                            ZStack {
                                Rectangle().fill(Material.ultraThin)
                                LinearGradient(colors: [.white.opacity(0.0), .white],
                                               startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 0.5))
                            }
                        )
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
                        .background(
                            ZStack {
                                Rectangle().fill(Material.ultraThin)
                                LinearGradient(colors: [.white.opacity(0.0), .white],
                                               startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 0.5))
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.clear)
                                .stroke(Color(hex: "#E6F2FC"), lineWidth: 1)
                        }
                        //.shadow(color: Color(hex: "#A8CBE7"), radius: 4, y: 2)
                        
                        
                        //                    HStack  {
                        //                        Button(action: {
                        //                            withAnimation {
                        //                                //isShowRuntime.toggle()
                        //                            }
                        //                        }, label: {
                        //                            Image(systemName: "play.fill")
                        //                                .frame(width: buttonSize, height: buttonSize)
                        //                                .foregroundStyle(Color(hex: "#008CFF"))
                        //                                .font(.system(size: 18).weight(.semibold))
                        //                        })
                        //                        .frame(width: buttonSize, height: buttonSize)
                        //                        .background(.regularMaterial)
                        //                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        //                        .shadow(color: .gray.opacity(0.3), radius: 5)
                        //
                        //                        //                                    Button(action: {
                        //                        //                                        withAnimation {
                        //                        //                                            if UIDevice.current.userInterfaceIdiom == .pad {
                        //                        //                                                isShowInspector.toggle()
                        //                        //                                            } else {
                        //                        //                                                isShowInspectorPhone.toggle()
                        //                        //                                            }
                        //                        //
                        //                        //                                        }
                        //                        //                                    }, label: {
                        //                        //                                        Image(systemName: UIDevice.current.userInterfaceIdiom == .pad ? "sidebar.right" : "rectangle.portrait.bottomhalf.inset.filled" )
                        //                        //                                            .frame(width: buttonSize, height: buttonSize)
                        //                        //                                            .foregroundStyle(Color(hex: "#008CFF"))
                        //                        //                                            .font(.system(size: 18).weight(.semibold))
                        //                        //                                    })
                        //                        //                                    .frame(width: buttonSize, height: buttonSize)
                        //                        //                                    .background(.regularMaterial)
                        //                        //                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                        //                        //                                    .shadow(color: .gray.opacity(0.3), radius: 5)
                        //
                        //                    }
                        
                    }
                    .padding(20)
                    .zIndex(3)
                }
                
                //inspector
                Spacer().frame(width: 5)
                
                
                VStack (spacing: 0) {
                    VStack(spacing : 0) {
                        
                        ZStack {
                            
                            VStack {
                                
                                VStack {
                                    
                                    if let id = selectedId, let entity = handler.entity(for: id) {
                                        if let entity = entity as? Block {
                                            BlockInspector(editorState: $handler.project.editorState,
                                                           name: entity.name,
                                                           attribute: entity.attribute,
                                                           handler: handler,
                                                           showDelete: !(entity.name == "stageInput" || entity.name == "stageOutput"))
                                            .padding()
                                            
                                        } else if entity is Channel {
                                            if let entity = entity as? Channel {
                                                ChannelInspector(editorState: $handler.project.editorState,
                                                                 selectedId: selectedId,
                                                                 name: entity.name, attribute: entity.attribute, handler: handler)
                                                .padding(10)
                                            }
                                        } else if entity is ProjectGraph{
                                            
                                            ProjectInspector(editorState: $handler.project.editorState, selectedMode: .preset, description: "", handler: handler)
                                                .padding(10)
                                            
                                        } else if entity is PlayActor {
                                            if let entity = entity as? PlayActor {
                                                PlayActorInspector(editorState: $handler.project.editorState,
                                                                   selectedId: selectedId,
                                                                   colorSet: BlockColorSet.get(entity.color),
                                                                   name: entity.name,
                                                                   attribute: entity.attribute, personality: entity.personality,
                                                                   handler: handler, deleteHandler : {
                                                    if let selecteId = self.selectedId {
                                                        handler.deleteEntity(with: selecteId)
                                                        self.selectedId = nil
                                                    }
                                                })
                                                .padding(10)
                                            }
                                        }
                                    } else if let id = handler.project.editorState.selectedStageId, let entity = handler.entity(for: id) {
                                        if let graph = entity as? StageGraph {
                                            
                                            StageGraphInspector(editorState: $handler.project.editorState,
                                                                name: graph.name,
                                                                attribute: graph.attribute,
                                                                handler: handler,
                                                                showDelete: !handler.project.editorState.mode.contains(.stage))
                                            .padding(10)
                                            
                                        } else if entity is ProjectGraph{
                                            
                                            ProjectInspector(editorState: $handler.project.editorState, selectedMode: .preset, description: "", handler: handler)
                                                .padding(10)
                                            
                                        } else {
                                            VStack {
                                                Spacer()
                                                
                                                HStack {
                                                    Spacer()
                                                    Text("No Inspection: \(selectedId) | \(handler.project.editorState.selectedStageId)")
                                                    Spacer()
                                                }
                                                
                                                Spacer()
                                            }
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
                                        ExecuteView(runtime: Runtime(project: handler.project))
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
            
            HStack {
                Spacer()
                Button(action: {
                }, label: {
                    
                    Image("magic.arrow")
                        .offset(y: 2)
                })
                .frame(width: 72, height: 72)
                .background(LinearGradient(colors: [Color(hex: "#4CCDFF"), Color(hex: "#259EFF")], startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1.0)))
                .clipShape(Circle())
                .shadow(color: Color(hex: "#259EFF").opacity(0.4 ), radius: 24)
                .shadow(color: Color(hex: "#25C3FF").opacity(0.66 ), radius: 5)
                .overlay {
                    
                    Circle().fill(.clear).stroke(.white, lineWidth: 2)
                    
                }
                .padding()
                .matchedGeometryEffect(id: "theButton", in: namespace)
                .offset(x: -300)
            }
        }
    }
    
    
    var buttonSize : CGFloat {
        return 68
    }
    
    
    func connectionHandler(port : Port, endPt : CGPoint, screenSize : CGSize) {
        var hasTarget = false
        //let screenSize = geometry.size
        for targetNode in handler.project.relationshipGraph.nodes {
            if port.kind == .inChannel {
                
                let center = CGPoint(x: targetNode.center.x + screenSize.width / 2 + 95,
                                     y: targetNode.center.y + screenSize.height / 2)
                
                
                var rect = CGRect(origin: center, size: CGSize(width: 1, height: 1))
                rect = CGRectInset(rect, -50, -50)
                
                if CGRectContainsPoint(rect, endPt) {
                    hasTarget = true
                    var canConnect = true
                    for channel in handler.project.relationshipGraph.channels {
                        
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
                        handler.project.relationshipGraph.channels.append(channel)
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
                    for channel in handler.project.relationshipGraph.channels {
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
                        handler.project.relationshipGraph.channels.append(channel)
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
            let id = handler.project.relationshipGraph.identifier
            let bounds = CGRect(origin: .zero, size: size)
            handler.addNodeForGraph(with: id, for: bounds)
            return
        }
        
        //add at pooint
    }
    
    func addNode() {
        
        
        if handler.project.editorState.mode.contains(.relationship) {
            
            let id = handler.project.relationshipGraph.identifier
            let bounds = CGRect(origin: .zero, size: size)
            handler.addNodeForGraph(with: id, for: bounds)
            
        } else if handler.project.editorState.mode.contains(.stage) {
            
            if let stageGraphId = handler.project.editorState.selectedStageId {
                
                let bounds = CGRect(origin: .zero, size: size)
                handler.addNodeForGraph(with: stageGraphId, for: bounds)
            }
            
        } else if handler.project.editorState.mode == .project {
            
            let id = handler.project.projectGraph.identifier
            let bounds = CGRect(origin: .zero, size: size)
            handler.addNodeForGraph(with: id, for: bounds)
            
        }
    }
    
}

#Preview {
    @Previewable @Namespace var namespace
    MainEditorView(namespace: namespace, handler: DocumentHandler(document: nil), backAction: {})
}
