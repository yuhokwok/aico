//
//  MainEditorViewController.swift
//  Aico
//
//  Created by Yu Ho Kwok on 9/10/2023.
//

import UIKit

protocol MainEditorViewControllerDelegate : EditorViewControllerDelegate {
    
}

//@MainActor
class MainEditorViewController: UINavigationController, EditorViewControllerDelegate  {

    
    
    var documentHandler : DocumentHandler!
    
    var mainEditorDelegate : MainEditorViewControllerDelegate?
    
    func editorViewControllerDidLoad(_ editor: UIViewController) {
        
    }
    
    func editorViewControllerWillAppear(_ editor: UIViewController) {
        self.mainEditorDelegate?.editorViewControllerWillAppear(editor)
    }
    
    func editorViewDidSelectEntityWithIdentifier(_ identifier: String) {
        self.mainEditorDelegate?.editorViewDidSelectEntityWithIdentifier(identifier)
    }
    
    func editorViewDidDoubleTapEntityWithIdentifier(_ identifier: String) {
        self.mainEditorDelegate?.editorViewDidDoubleTapEntityWithIdentifier(identifier)
    }
    
    func editorViewDidSelectNode(_ node: Node) {
        print("\(String(describing: type(of: self)))::\(#function)::\(node.identifier)")
        self.mainEditorDelegate?.editorViewDidSelectNode(node)
    }
    
    func editorViewDidSelectChannel(_ channel: Channel) {
        print("\(String(describing: type(of: self)))::\(#function)::\(channel.identifier)")
        self.mainEditorDelegate?.editorViewDidSelectChannel(channel)
    }

    func editorViewControllerRequestDocumentHandler() -> DocumentHandler {
        if let handler = self.mainEditorDelegate?.editorViewControllerRequestDocumentHandler() {
            return handler
        }
        return DocumentHandler(document: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
