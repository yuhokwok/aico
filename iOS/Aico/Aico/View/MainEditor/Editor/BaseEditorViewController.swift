//
//  BaseEditorViewController.swift
//  Aico
//
//  Created by Yu Ho Kwok on 12/10/2023.
//

import UIKit


protocol EditorViewControllerDelegate {
    func editorViewControllerRequestDocumentHandler() -> DocumentHandler
    
    func editorViewDidSelectEntityWithIdentifier(_ identifier : String)
    func editorViewDidSelectNode(_ node : Node)
    func editorViewDidSelectChannel(_ channel : Channel)
    
    func editorViewDidDoubleTapEntityWithIdentifier(_ identifier : String)
    
    //lifecycle
    func editorViewControllerDidLoad(_ editor : UIViewController)
    func editorViewControllerWillAppear(_ editor : UIViewController )
}

@MainActor
class BaseEditorViewController<T : Graph >: UIViewController, UIGestureRecognizerDelegate {
    
    weak var documentHandler : DocumentHandler?
    
    var graphIdentifier : String?
    
    /// An generic type confronts to HasNode & HasChannel protocol
    var graph : T? {
        //computed property to
        get {
            guard let id = self.graphIdentifier else {
                return nil
            }
            
            guard let documentHandler = self.documentHandler else {
                return nil
            }
            
            if let graph = documentHandler.project.graph(with: id) as? T? {
                return graph
            }
            
            return nil
        }

    }
    
    //an editor view
    @IBOutlet public var editorView : NodeEditorView!
    
    var delegate : EditorViewControllerDelegate?
    
    var shouldNotReport = false
    var nodeEditorState = NodeEditorState() {
        didSet {
            

            
            if oldValue.selectedNodeId != nodeEditorState.selectedNodeId {
                if let oldId = oldValue.selectedNodeId {
                    nodeViewRepo[oldId]?.setSelected(false)
                }
                
                if let newId = nodeEditorState.selectedNodeId {
                    nodeViewRepo[newId]?.setSelected(true)
                    if shouldNotReport == false, let node = graph?.node(with: newId) {
                        self.delegate?.editorViewDidSelectNode(node)
                    }
                }
            }
            
            
            guard shouldNotReport == false else {
                
                editorView.setSelectedChannel(nodeEditorState.selectedChannelId)
                editorView.redraw()
                
                shouldNotReport = false
                return
            }
            
            if oldValue.selectedChannelId != nodeEditorState.selectedChannelId {
                if let selectedChannelId = nodeEditorState.selectedChannelId, let channel = graph?.channel(with: selectedChannelId) {
                    self.delegate?.editorViewDidSelectChannel(channel)
                }
                editorView.setSelectedChannel(nodeEditorState.selectedChannelId)
                editorView.redraw()
            }

            if oldValue.selectedNodeId != nodeEditorState.selectedNodeId {
                if nodeEditorState.selectedNodeId == self.documentHandler?.project.projectGraph.identifier, let project = self.documentHandler?.project {
                    self.delegate?.editorViewDidSelectEntityWithIdentifier(project.projectGraph.identifier)
                }
            }
            
            if oldValue.selectedNodeId != nodeEditorState.selectedNodeId {
                if nodeEditorState.selectedNodeId == self.graphIdentifier, let identifier = self.graphIdentifier {
                    self.delegate?.editorViewDidSelectEntityWithIdentifier(identifier)
                }
            }
            
            if oldValue.selectedNodeId != nodeEditorState.selectedNodeId {
                if nodeEditorState.selectedNodeId == self.documentHandler?.project.relationshipGraph.identifier, let project = self.documentHandler?.project {
                    self.delegate?.editorViewDidSelectEntityWithIdentifier(project.relationshipGraph.identifier)
                }
            }
        }
    }
    
    //a dictionary that holds all the node view
    var nodeViewRepo : [String : NodeView] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.prepareEditor()
        editorView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(String(describing: type(of: self)))::\(#function)::Trigged")
        
        if let mainEditorVC = self.navigationController as? MainEditorViewController {
            self.delegate = mainEditorVC
        }
        
        self.documentHandler = self.delegate?.editorViewControllerRequestDocumentHandler()
        
        self.delegate?.editorViewControllerWillAppear(self)

        guard let graph = graph else {
            return
        }
        self.load(graph: graph)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(String(describing: type(of: self)))::\(#function)::Trigged")
        self.delegate = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("\(String(describing: type(of: self)))::\(#function)::Trigged")
        super.viewDidDisappear(animated)
    }
    
    
    func prepareEditor() {
        //prepare the size,
        self.editorView.frame = CGRect(x: 0, y: 0, width: 3072, height: 3072)
        if let bounds = self.editorView.superview?.bounds {
            self.editorView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        }
        
        editorView.backgroundColor = .clear
        
        //prepare gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(BaseEditorViewController.editorGesture(gesture:)))
        panGesture.delegate = self
        editorView.addGestureRecognizer(panGesture)
        
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(BaseEditorViewController.editorGesture(gesture:)))
        pinchGesture.delegate = self
        editorView.addGestureRecognizer(pinchGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BaseEditorViewController.editorGesture(gesture:)))
        tapGesture.delegate = self
        editorView.addGestureRecognizer(tapGesture)
    }

    
    /// Load the given graph
    /// - Parameter graph: the graph
    func load(graph : T) {
        //self.graph = graph
        //reconstruct the graph
        self.reconstruct(graph: graph)
    }
    
    //for undo / redo
    func reconstruct(graph : any Graph) {
        
        //remove not exists view and curve
        for ( key, _ ) in nodeViewRepo {
            if !graph.nodes.contains(where: { key == $0.identifier }) {
                let view = nodeViewRepo.removeValue(forKey: key)
                view?.removeFromSuperview()
            }
        }
        
        self.editorView.curves = self.editorView.curves.filter({
            for channel in graph.channels {
                return $0.identifier == channel.identifier
            }
            return false
        })
        
        //remove all not exist curves
        let curves = self.editorView.curves.filter({
            guard let startId = $0.startId, let endId = $0.endId else {
                return false
            }
            
            let allNonNilPorts = graph.portFromNodes(with: startId) != nil && graph.portFromNodes(with: endId) != nil
            return allNonNilPorts
        })
        self.editorView.curves = curves
        
        //update exists view
        for node in graph.nodes {
            if nodeViewRepo[node.identifier] != nil {
                //update or
                nodeViewRepo[node.identifier]?.update(for: node,
                                                      for: self.editorView)
            } else {
                //create
                self.addNodeView(node)
            }
        }

        //add channel that not exists
        for channel in graph.channels {
            //add if no curve exists or there is no curve in editor view
            if self.editorView.curves.contains(where: { $0.identifier != channel.identifier }) ||
               self.editorView.curves.count <= 0{
                self.editorView.addCurve(for: channel)
            }
        }


        if let selectedChannelId = nodeEditorState.selectedChannelId {
            self.editorView.setSelectedChannel(selectedChannelId)
        }
        
        //update geometry of all curves
        self.updateGeometry()
        

        //update text label for curves
        for channel in graph.channels {
            for (index, curve) in self.editorView.curves.enumerated() {
                if channel.identifier == curve.identifier {
                    self.editorView.curves[index].content =  channel.name
                }
            }
        }
        
        
        if let selectedEntityId = documentHandler?.project.editorState.selectedId {
            if let entity = documentHandler?.entity(for: selectedEntityId) {
                if entity is Channel {
                    shouldNotReport = true
                    var editorState = self.nodeEditorState
                    editorState.selectedChannelId = entity.identifier
                    self.nodeEditorState = editorState
                } else if entity is Node {
                    shouldNotReport = true
                    var editorState = self.nodeEditorState
                    editorState.selectedNodeId = entity.identifier
                    self.nodeEditorState = editorState
                }
            }
        }
        
        //redraw the editor view
        self.editorView.redraw()
    }
    
    func addNodeView(_ node : Node){
        guard let editorView = self.editorView else {
            return
        }
        
        let nodeView = NodeView.build(for: node, for: editorView)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(BaseEditorViewController.panGesture(gesture:)))
        panGesture.delegate = self
        nodeView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BaseEditorViewController.tapGesture(gesture:)))
        tapGesture.delegate = self
        nodeView.addGestureRecognizer(tapGesture)
        
        let dblTapGesture = UITapGestureRecognizer(target: self, action: #selector(BaseEditorViewController.dblTapGesture(gesture:)))
        dblTapGesture.numberOfTapsRequired = 2
        dblTapGesture.delegate = self
        nodeView.addGestureRecognizer(dblTapGesture)
        
        nodeViewRepo [node.identifier] = nodeView
        
        self.editorView.addSubview(nodeView)
    }

    //MARK: - Gesture for Node Editor View
    @IBAction func editorGesture(gesture : UIGestureRecognizer) {
        
        guard let targetView = gesture.view else {
            return
        }
        
        if gesture is UITapGestureRecognizer {
            
            //self.editorState.selectedNodeId = nil
            self.nodeEditorState.selectedChannelId = nil
            self.nodeEditorState.selectedNodeId = self.graphIdentifier
            
            if self.editorView.isFirstResponder == false {
                self.editorView.becomeFirstResponder()
            }
            return
        }
                
        if let panGesture = gesture as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: view)
            //need to correct the movement with the zoom scale)
            //print("\(translation)")
            
            let frame = targetView.frame.offsetBy(dx: translation.x,
                                                   dy: translation.y)
            
            //var destX = frame.minX > 0 ? 0 : frame.minX
            var destX = frame.minX
            //var destY = frame.minY > 0 ? 0 : frame.minY
            var destY = frame.minY
            
            let destWidth = frame.width
            let destHeight = frame.height
            
            if frame.maxX < self.view.bounds.width {
                destX = self.view.bounds.width - destWidth
            } else if frame.minX > 0 {
                destX = 0
            }
            
            if frame.maxY < self.view.bounds.height {
                destY = self.view.bounds.height - destHeight
            } else if frame.minY > 0 {
                destY = 0
            }
            
            
            targetView.frame = CGRect(x: destX , y: destY,
                                       width: destWidth, height: destHeight)
            
            
            let xoffset = targetView.center.x - self.view.bounds.width / 2
            let yoffset = targetView.center.y - self.view.bounds.height / 2
            
            let containerOffset = CGSize(width: xoffset, height: yoffset)
            //self.editorSceneView.translateContentArea(with: containerOffset, for: coordSystem)
            
            panGesture.setTranslation(.zero, in: view)

            
        } else if let scaleGesture = gesture as? UIPinchGestureRecognizer {
            if let editorView = targetView as? NodeEditorView {
                
                if editorView.transform.a <= NodeEditorState.minScale && scaleGesture.scale < 1 {
                    editorView.transform.a = NodeEditorState.minScale
                    editorView.transform.d = NodeEditorState.minScale
                    
                    scaleGesture.scale = 1
                    
                    return
                } else if editorView.transform.a >= NodeEditorState.maxScale  && scaleGesture.scale > 1 {
                    editorView.transform.a = NodeEditorState.maxScale
                    editorView.transform.d = NodeEditorState.maxScale
                    
                    scaleGesture.scale = 1
                    return
                } else {
                    targetView.transform = targetView.transform.scaledBy(x: scaleGesture.scale, y: scaleGesture.scale)
                }
            }
            scaleGesture.scale = 1
            
            let scale = 1 / editorView!.transform.a
            //self.editorSceneView.scaleContentArea(with: scale)
            
            
            let xoffset = targetView.center.x - self.view.bounds.width / 2
            let yoffset = targetView.center.y - self.view.bounds.height / 2
            
            let containerOffset = CGSize(width: xoffset, height: yoffset)
            
            //self.editorSceneView.translateContentArea(with: containerOffset,
            //                                          for: coordSystem)
            
        }
        
        if self.editorView.isFirstResponder == false {
            self.editorView.becomeFirstResponder()
        }
    }
    
    //MARK: - Gesture for Node View
    @IBAction func tapGesture(gesture : UITapGestureRecognizer) {
        print("\(String(describing: type(of: self)))::\(#function)::trigger")
        guard let nodeView = gesture.view as? NodeView else {
            return
        }
        
        if nodeView.isFirstResponder == false {
            nodeView.becomeFirstResponder()
        }
        
        if nodeEditorState.selectedNodeId != nodeView.identifier {
            self.nodeEditorState.selectedNodeId = nodeView.identifier
        }
    }
    
    @IBAction func dblTapGesture(gesture : UITapGestureRecognizer) {
        print("\(String(describing: type(of: self)))::\(#function)::trigger")
    }
    
    @IBAction func panGesture(gesture : UIPanGestureRecognizer) {
        guard let nodeView = gesture.view as? NodeView else {
            return
        }
        
        if nodeView.isFirstResponder == false {
            nodeView.becomeFirstResponder()
        }
        
        if gesture.state == .began {
            
            
            //check if there is any dragged port
            let localPoint = gesture.location(in: nodeView)
            if let draggedPort = nodeView.touchedPort(at: localPoint) {
                
                if let port = graph?.portFromNodes(with: draggedPort.identifier) {
                    nodeEditorState.draggedPort = port
                    
                    let startPt = nodeView.convert(draggedPort.center, to: editorView)
                    editorView.startNewCurve(at: startPt )
                }
            } else {
                self.nodeEditorState.selectedNodeId = nodeView.identifier
            }
            
        } else if gesture.state == .changed {
            
            if self.nodeEditorState.draggedPort == nil {
                
                //handle block translation
                var translation = gesture.translation(in: self.view)
                let factor = 1 / editorView.transform.a
                translation = CGPoint(x: translation.x * factor, y: translation.y * factor)
                let center = nodeView.center
                let newCenter = center + translation
                nodeView.center = newCenter
                
            } else {
                
                //handle dragging port
                let location = gesture.location(in: self.editorView)
                editorView.updateNewCurve(to: location)
            }
            
        } else {
            //handle connection
            
            if let selectedPort = self.nodeEditorState.draggedPort {

                if let portView = self.lookupPort(for: gesture) {

                    if let targetPort = graph?.portFromNodes(with: portView.identifier) {
                        
                        if selectedPort.isConnectable(with: targetPort) {
                            
                            if let parent = portView.parent {
                                let endPt = parent.convert(portView.center, to: self.editorView)
                                                                
                                if let identifier = self.editorView.endNewCurve(at: endPt,
                                                                startId: selectedPort.identifier,
                                                                                    endId: targetPort.identifier) {
                                    let channel = Channel(identifier: identifier,
                                                          startId: selectedPort.identifier,
                                                          endId: targetPort.identifier, attribute: Attribute.new)
                                    
                                    //graph?.channels.append(channel)
                                    print("yoyoyoyoyo")
                                    if var graph = self.graph {
                                        graph.channels.append(channel)
                                        self.commit(action: "Delete Connection", redoAction: "Add Connection", with: graph)

                                    }
                                }
                                
                            } else {
                                self.editorView.discardNewCurve()
                            }
                        } else {
                            self.editorView.discardNewCurve()
                        }
                    } else {
                        self.editorView.discardNewCurve()
                    }

                } else {
                    self.editorView.discardNewCurve()
                }
                
                self.nodeEditorState.draggedPort = nil
            } else
            {
                //update for Node movement
                if var node = graph?.node(with: nodeView.identifier) {
                    //update the frame
                    node.set(frame: nodeView.frame, from: self.editorView)
                    //replace the old node
                    //graph?.updateNode(node)
                    if var graph = self.graph {
                        graph.updateNode(node)
                        self.commit(action: "Undo Move Node", redoAction: "Redo Move Node", with: graph)
                    }
                }
            }
        }
        

        gesture.setTranslation(.zero, in: self.view)
        
        updateGeometry()
        self.editorView.redraw()
    }
    
    func updateGeometry() {
        for (index, curve) in editorView.curves.enumerated() {
            if let startId = curve.startId, let endId = curve.endId {
                if let startPortView = self.lookupPort(with: startId),
                   let endPortView = self.lookupPort(with: endId) {
                    if let startCenter = startPortView.parent?.convert(startPortView.center, to: self.editorView),
                       let endCenter = endPortView.parent?.convert(endPortView.center, to: self.editorView) {
                        editorView.curves[index].startPt = startCenter
                        editorView.curves[index].endPt = endCenter
                        editorView.curves[index].updatePath()
                    }
                }
            }
        }
    }
    
    func lookupPort(with identifier : String) -> PortView? {
        for (_, nodeView) in nodeViewRepo {
            for inPort in nodeView.inPorts {
                if inPort.identifier == identifier {
                    return inPort
                }
            }
            
            for outPort in nodeView.outPorts {
                if outPort.identifier == identifier {
                    return outPort
                }
            }
            
            for comPort in nodeView.comPorts {
                if comPort.identifier == identifier {
                    return comPort
                }
            }
        }
        return nil
    }
    
    ///a local touch point at the gesture view (need to convert it if not local)
    func lookupPort(for gesture : UIPanGestureRecognizer) -> PortView? {
        for (_, nodeView) in nodeViewRepo {
            let localPoint = gesture.location(in: nodeView)
            if let port = nodeView.touchedPort(at: localPoint) {
                return port
            }
        }
        return nil
    }
    
    //MARK: - UIGestureRecognizer Delegate
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = gestureRecognizer.view else {
            return false
        }
        
        if let nodeView = view as? NodeView {
            return nodeView.shouldReceiveGesture(gestureRecognizer)
        }
        
        if let editorView = view as? NodeEditorView {
            return !editorView.hasTouchedChannel(gesture: gestureRecognizer)
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
              shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.view == otherGestureRecognizer.view
    }
    

    
    func commit(action undoActionName : String,
                redoAction redoActionName : String,
                with graph : T){
        
//        guard let oldGraph = self.graph else {
//            print("no undo action register")
//            return
//        }
//        
//        self.undoManager?.registerUndo(withTarget: self, handler: {
//            target in
//            target.commit(action: redoActionName,
//                          redoAction: undoActionName,
//                          with: oldGraph)
//        })
//        
//        undoManager?.setActionName(undoActionName)
//        print(undoActionName)
        
        documentHandler?.commit(graph, withId: graphIdentifier ?? "")
        
        //self.graph = graph
        self.load(graph: graph)
    }
    
    func refresh() {
        if let identifier = self.graphIdentifier {
            if let graph = documentHandler?.graph(for: identifier) as? T {
                self.load(graph: graph)
            }
        }
    }
    
}

extension BaseEditorViewController : NodeEditorViewDelegate {
    func nodeEditorViewDidSelectChannel(with identifier : String) {
        self.nodeEditorState.selectedChannelId = identifier
    }
}


