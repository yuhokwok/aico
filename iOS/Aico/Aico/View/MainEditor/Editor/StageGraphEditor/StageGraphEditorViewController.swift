//
//  NodEditorViewController.swift
//  Aico
//
//  Created by itst on 6/10/2023.
//

import UIKit


@MainActor
class StageGraphEditorViewController: BaseEditorViewController<StageGraph> {

    override func viewDidLoad() {
        //TODO: - update
        //self.graph = StageGraph.new()
        super.viewDidLoad()
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

