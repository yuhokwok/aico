//
//  ProjectEditorViewController.swift
//  Aico
//
//  Created by Yu Ho Kwok on 11/10/2023.
//

import UIKit

@MainActor
class RelationshipGraphEditorViewController: BaseEditorViewController<RelationshipGraph> {

    override func viewDidLoad() {
        //TODO: - update
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    @IBAction func addRole(){
        let role = PlayActor.new(for: self.view.bounds)
        
        guard var graph = self.graph else {
            return
        }
        
        graph.nodes.append(role)
        self.commit(action: "Add Role", redoAction: "Remove Role", with: graph)
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
                self.commit(action: "Remove Role", redoAction: "Add Role", with: graph)
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
        super.dblTapGesture(gesture: gesture)
        //no need to handle
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}
