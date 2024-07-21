//
//  ProjectEditorViewController.swift
//  Aico
//
//  Created by itst on 11/10/2023.
//

import UIKit

@MainActor
class ProjectGraphEditorViewController: BaseEditorViewController<ProjectGraph> {

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
