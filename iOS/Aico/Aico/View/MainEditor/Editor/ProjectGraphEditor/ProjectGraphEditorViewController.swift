//
//  ProjectEditorViewController.swift
//  Aico
//
//  Created by Yu Ho Kwok on 11/10/2023.
//

import UIKit

@MainActor
class ProjectGraphEditorViewController: BaseEditorViewController<ProjectGraph> {

    override func viewDidLoad() {
        //TODO: - update
        super.viewDidLoad()
        
//        if let mainEditorVC = self.navigationController as? MainEditorViewController {
//            self.delegate = mainEditorVC
//        }
//        
//        if let handler = self.delegate?.editorViewControllerRequestDocumentHandler() {
//            print("use existing graph")
//            self.graph = handler.project.projectGraph
//        } else {
//            print("fall back to new project graph")
//            self.graph = ProjectGraph.new(for: self.view)
//        }
//        
//        guard let graph = self.graph else {
//            return
//        }
//        
//        self.reconstruct(graph: graph)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if let mainEditorVC = self.navigationController as? MainEditorViewController {
//            self.delegate = mainEditorVC
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.delegate = nil
    }
    
    @IBAction func addStage(){
        let stage = StageGraph.new(for: self.view)
        
        guard var graph = self.graph else {
            return
        }
        
        graph.nodes.append(stage)
        self.commit(action: "Add Stage", redoAction: "Remove Stage", with: graph)
    }
    
    @IBAction func deleteChannel() {
        guard let selectedChannelId = nodeEditorState.selectedChannelId else {
            return
        }
        
        if let channel = graph?.channel(with: selectedChannelId) {
            editorView.removeCurve(channel.identifier)
            
            if var graph = self.graph {
                
                graph.deleteChannel(channel)
                
                //commit the update
                self.commit(action: "Remove Connection", redoAction: "Add Connection", with: graph)
            }
        }
    }
    
    @IBAction func deleteNode() {
        guard let selectedNodeId = self.nodeEditorState.selectedNodeId else {
            return
        }
        
        for (identifier, _) in nodeViewRepo {
            if identifier == selectedNodeId {
                
                if let node = graph?.node(with: selectedNodeId) {
                    
                    guard node.isDeletable else {
                        print("can't delete")
                        return
                    }
                    
                    //remove at node view curves
                    editorView.removeDependedCurve(node.portIdentifiers)
                    
                    if var graph = self.graph {
                        //remove node and dependencies
                        graph.deleteNode(node)
                        
                        //commit the update
                        self.commit(action: "Remove Node", redoAction: "Add Node", with: graph)
                    }
                }

                //remove blockview
                //blockView.removeFromSuperview()
                //nodeViewRepo[identifier] = nil
            }
        }

        self.nodeEditorState.selectedNodeId = nil

        //redraw all node in the editor
        self.editorView.redraw()
    }

    
    override func dblTapGesture(gesture: UITapGestureRecognizer) {
        
        if let nodeView = gesture.view as? NodeView {
            if let node = graph?.node(with: nodeView.identifier) {
                print("identifier: \(node.identifier) - \(node.name)")
                guard node.name != "bigbang" else {
                    return
                }
                
                print("graph double clicked, go to: \(node.identifier)")
                //gotoStage(identifier: node.identifier)
                self.delegate?.editorViewDidDoubleTapEntityWithIdentifier(node.identifier)
            }
        }
        
        
        
    }
    
    
    var selectedStageId : String? = nil
    func gotoStage(identifier : String) {
        self.selectedStageId = identifier
        self.performSegue(withIdentifier: "editStageSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editStageSegue" {
            if let selectedStageId = self.selectedStageId,
               let destination = segue.destination as? StageGraphEditorViewController {
                if let graph = graph?.node(with: selectedStageId) {
                    destination.graph = graph
                    self.selectedStageId = nil
                }
            }
        }
    }
    
    @IBAction func gobackToStage(segue : UIStoryboardSegue){
        if segue.identifier == "gobacktoStage" {
           print("unwind")
            if let stageGraphvC = segue.source as? StageGraphEditorViewController {
                if let graph = stageGraphvC.graph {
                    self.graph?.updateNode(graph)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: for quick test
    @IBAction func clear() {
        UserDefaults.standard.removeObject(forKey: "qsave")
    }
    
    @IBAction func quickSave() {
        if let string = JSON.serialize(self.graph) {
            UserDefaults.standard.setValue(string, forKey: "qsave")
        }
    }
    
    @IBAction func quickLoad() {
        if let string = UserDefaults.standard.string(forKey: "qsave") {
            if let graph = JSON.deserialize(graph.self!, from: string) {
                self.graph = graph
                self.load(graph: graph)
            }
        } else {
            print("\(#function)::Can't Quick Load")
        }
    }

    
    @IBAction public func undo(){
        guard self.undoManager?.canUndo == true else {
            return
        }
        self.undoManager?.undo()
    }
    
    @IBAction public func redo(){
        guard self.undoManager?.canRedo == true else {
            return
        }
        self.undoManager?.redo()
    }
}
