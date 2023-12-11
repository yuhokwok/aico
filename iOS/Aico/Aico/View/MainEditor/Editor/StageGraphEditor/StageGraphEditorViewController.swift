//
//  NodEditorViewController.swift
//  Aico
//
//  Created by Yu Ho Kwok on 6/10/2023.
//

import UIKit


@MainActor
class StageGraphEditorViewController: BaseEditorViewController<StageGraph> {

    override func viewDidLoad() {
        //TODO: - update
        //self.graph = StageGraph.new()
        super.viewDidLoad()
    }
    
    
    @IBAction func back(send : Any) {
        self.performSegue(withIdentifier: "gobacktoStage", sender: nil)
    }
    
//    @IBAction func addBlock(){
//        let block = Block.new()
//        graph?.nodes.append(block)
//        self.addNodeView(block)
//    }
    
    @IBAction func deleteChannel() {
        guard let selectedChannelId = nodeEditorState.selectedChannelId else {
            return
        }
        
        if let channel = graph?.channel(with: selectedChannelId) {
            editorView.removeCurve(channel.identifier)
            graph?.deleteChannel(channel)
            editorView.redraw()
        }
    }
    
    @IBAction func deleteNode() {
        guard let selectNodeId = self.nodeEditorState.selectedNodeId else {
            return
        }
        
        for (identifier, nodeView) in nodeViewRepo {
            if identifier == selectNodeId {
                
                if let node = graph?.node(with: selectNodeId) {
                    
                    guard node.isDeletable else {
                        print("can't delete")
                        return
                    }
                    
                    //remove at node view curves
                    editorView.removeDependedCurve(node.portIdentifiers)
                    
                    //remove dependencies
                    graph?.deleteNode(node)
                }

                //remove blockview
                nodeView.removeFromSuperview()
                nodeViewRepo[identifier] = nil
            }
        }

        self.nodeEditorState.selectedNodeId = nil

        //redraw all node in the editor
        self.editorView.redraw()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func refresh() {
        //load another stage graph id for undo / redo
        if documentHandler?.project.editorState.selectedStageId != self.graphIdentifier {
            self.graphIdentifier = documentHandler?.project.editorState.selectedStageId
        }
        super.refresh()
    }

}

