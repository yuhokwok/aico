//
//  MainEditorController.swift
//  Aico
//
//  Created by Yu Ho Kwok on 9/10/2023.
//

import SwiftUI
import Observation

protocol IsEditorViewControllerContainer {
    var mainEditorState : EditorState { get set }
    var documentHandler : DocumentHandler { get set }
}

struct MainEditorContainer : UIViewControllerRepresentable, IsEditorViewControllerContainer {

    @Binding var mainEditorState : EditorState
    @ObservedObject var documentHandler : DocumentHandler
        
    typealias UIViewControllerType = MainEditorViewController
    

    func makeUIViewController(context: Context) -> MainEditorViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MainEditorViewController") as? MainEditorViewController {
            
            vc.documentHandler = documentHandler
            vc.mainEditorDelegate = context.coordinator
            vc.view.backgroundColor = .clear
            //coordinator?.delegate = context.coordinator
        
            if let projectGraphVC = vc.topViewController as? ProjectGraphEditorViewController {
                projectGraphVC.graphIdentifier = documentHandler.project.projectGraph.identifier
            }
            
            return vc
        }
        
        let vc = MainEditorViewController()
        vc.documentHandler = documentHandler
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MainEditorViewController, context: Context) {
        
        if mainEditorState.mode.contains(.stage) == false && uiViewController.topViewController is StageGraphEditorViewController {
            uiViewController.popToRootViewController(animated: true)
            return
        } else if mainEditorState.mode.contains(.stage) && uiViewController.topViewController is ProjectGraphEditorViewController {
            //print("push to new VC")
            if let identifier = self.mainEditorState.selectedStageId {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                if let vc = storyboard.instantiateViewController(withIdentifier: "NodeEditorViewController") as? StageGraphEditorViewController {
                    vc.graphIdentifier = identifier
                    uiViewController.pushViewController(vc, animated: true)
                }
            }
            return
        }
        
        if let graphVC = uiViewController.topViewController as? ProjectGraphEditorViewController {
            print("\(String(describing: type(of: self)))::\(#function)::ProjectGraph")
            graphVC.refresh()
        } else if let graphVC = uiViewController.topViewController as? StageGraphEditorViewController {
            print("\(String(describing: type(of: self)))::\(#function)::StageGraph\(documentHandler.project.editorState.selectedStageId)")
            graphVC.refresh()
        }
        
    }
    
    func makeCoordinator() -> MainEditorViewControllerCoordinator {
        return MainEditorViewControllerCoordinator(self)
    }
    

}

class MainEditorViewControllerCoordinator : MainEditorViewControllerDelegate {

    
    func editorViewControllerRequestDocumentHandler() -> DocumentHandler {
        return self.parent.documentHandler
    }
    
    var parent : IsEditorViewControllerContainer
    
    init(_ parent : IsEditorViewControllerContainer){
        self.parent = parent
    }
    
    func editorViewControllerDidLoad(_ editor: UIViewController) {
        
    }
    
    func editorViewControllerWillAppear(_ editor: UIViewController) {
        if editor is ProjectGraphEditorViewController {
            print("\(String(describing: type(of: self)))::\(#function)::\(String(describing: type(of: editor)))")
            //parent.mainEditorState.mode = .project
            //print("\(String(describing: type(of: self)))::\(#function)::\(parent.mainEditorState.mode))")
        } else if editor is StageGraphEditorViewController {
            print("\(String(describing: type(of: self)))::\(#function)::\(String(describing: type(of: editor)))")
            //parent.mainEditorState.mode = .stage
            //print("\(String(describing: type(of: self)))::\(#function)::\(parent.mainEditorState.mode))")
        }
    }
    
    func editorViewDidDoubleTapEntityWithIdentifier(_ identifier: String) {
        if parent.mainEditorState.mode.contains(.stage) == false {
            if parent.mainEditorState.selectedId != identifier {
                parent.mainEditorState.selectedId = identifier
            }
            
            if parent.mainEditorState.selectedStageId != identifier {
                parent.mainEditorState.selectedStageId = identifier
            }
            
            parent.mainEditorState.mode.insert(.stage)
        }
    }
    
    func editorViewDidSelectEntityWithIdentifier(_ identifier: String) {
        self.parent.mainEditorState.selectedId = identifier
    }
    
    
    func editorViewDidSelectNode(_ node: Node) {
        self.parent.mainEditorState.selectedId = node.identifier
    }
    
    func editorViewDidSelectChannel(_ channel: Channel) {
        self.parent.mainEditorState.selectedId = channel.identifier
    }
 

}

