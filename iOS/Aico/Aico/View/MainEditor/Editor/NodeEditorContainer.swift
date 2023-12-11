//
//  NoteEditorContainer.swift
//  Aico
//
//  Created by Yu Ho Kwok on 8/10/2023.
//

import SwiftUI

@MainActor
struct NodeEditorContainer : UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> StageGraphEditorViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "NodeEditorViewController") as? StageGraphEditorViewController {
            return vc
        }
        return StageGraphEditorViewController()
    }
    
    func updateUIViewController(_ uiViewController: StageGraphEditorViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = StageGraphEditorViewController
    
}
