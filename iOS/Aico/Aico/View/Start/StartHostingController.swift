//
//  ProjectViewController.swift
//  Aico
//
//  Created by Yu Ho Kwok on 8/10/2023.
//

import UIKit
import SwiftUI

class StartHostingController: UIHostingController<StartView>, ProjectHostingDelegate {


    @MainActor required override init?(coder aDecoder: NSCoder, rootView: StartView) {
        super.init(coder: aDecoder, rootView: StartView())
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder, rootView: StartView())
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
                
                //load pre-filled project
                if let precreate {
                    handler.project.name = precreate.projectName
                    handler.project.projectGraph.nodes = []
                    for step in precreate.steps {
                        let stage = StageGraph(identifier: UUID().uuidString,
                                               name: step.stepName,
                                               center: .zero,
                                               size: .zero,
                                               attribute: Attribute(id: UUID().uuidString, contents: []),
                                               description: step.description,
                                               inChannels: [], outChannels: [], comChannels: [], nodes: [], channels: [])
                        handler.project.projectGraph.nodes.append(stage)
                    }
                }
                
                let hostVC = MainEditorHostingController(rootView: MainEditorView(documentHandler: handler))
                
                hostVC.documentHandler = handler
                
                hostVC.modalPresentationStyle = .fullScreen
                hostVC.modalTransitionStyle = .crossDissolve
                
                self.present(hostVC, animated: true)

            } else {
                //prompt error
            }
        })
        
        //self.present(nvc, animated: true)
    }

}
