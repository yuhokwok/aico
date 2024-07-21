//
//  ProjectViewController.swift
//  Aico
//
//  Created by itst on 8/10/2023.
//

import UIKit
import SwiftUI

class ProjectHostingController: UIHostingController<ProjectView>, ProjectHostingDelegate {


    @MainActor required override init?(coder aDecoder: NSCoder, rootView: ProjectView) {
        super.init(coder: aDecoder, rootView: ProjectView())
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder, rootView: ProjectView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.rootView.coordinator.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.rootView.coordinator.delegate = nil
        super.viewWillDisappear(animated)
    }
    

    func projectHostingDidRequestPresentDocument(with url: URL, precreate : GeneratedProject?) {
        
        let doc = AicoProject(fileURL: url)
        //open the document
        doc.open(completionHandler: {
            isReady in
            
            if isReady {
                let handler = DocumentHandler(document: doc)
                
                
                let hostVC = MainEditorHostingController(rootView: MainEditorView(documentHandler: handler))
                
                hostVC.documentHandler = handler
                
                hostVC.modalPresentationStyle = .fullScreen
                self.present(hostVC, animated: true)

            } else {
                //prompt error
            }
        })
        
        //self.present(nvc, animated: true)
    }

}
