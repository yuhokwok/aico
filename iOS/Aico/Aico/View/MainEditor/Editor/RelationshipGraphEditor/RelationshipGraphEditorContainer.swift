//
//  RelationshipGraphEditorContainer.swift
//  Aico
//
//  Created by itst on 12/9/23.
//

import SwiftUI
import UIKit

struct RelationshipGraphEditorContainer : UIViewControllerRepresentable, IsEditorViewControllerContainer {
    
    @Binding var mainEditorState : EditorState
    @ObservedObject var documentHandler : DocumentHandler
    
    typealias UIViewControllerType = RelationshipGraphEditorViewController
    
    func makeUIViewController(context: Context) -> RelationshipGraphEditorViewController {
        
        //RelationshipGraphEditorViewController
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if let vc = storyboard.instantiateViewController(withIdentifier: "RelationshipGraphEditorViewController") as? RelationshipGraphEditorViewController {
            
            vc.view.backgroundColor = .clear
            
            vc.documentHandler = documentHandler
                        
            vc.graphIdentifier = documentHandler.project.relationshipGraph.identifier
           
            //set delegate
            vc.delegate = context.coordinator

            
            return vc
        }
        
        let vc = RelationshipGraphEditorViewController()
        vc.documentHandler = documentHandler
        
        return vc   
    }
    
    func updateUIViewController(_ uiViewController: RelationshipGraphEditorViewController, context: Context) {
        
        uiViewController.refresh()

    }
    
    func makeCoordinator() -> MainEditorViewControllerCoordinator {
        return MainEditorViewControllerCoordinator(self)
    }
    
    
}
