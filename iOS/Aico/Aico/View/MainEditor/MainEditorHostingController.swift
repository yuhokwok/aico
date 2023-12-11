//
//  MainEditorHostingController.swift
//  Aico
//
//  Created by Yu Ho Kwok on 8/10/2023.
//

import UIKit
import SwiftUI

@MainActor
class MainEditorHostingController: UIHostingController<MainEditorView>, MainEditorHostingDelegate {
    
    var documentHandler : DocumentHandler?
    
    func mainEditorDidRequestClosingDocument() {
        self.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.rootView.hostCoordinator.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.rootView.hostCoordinator.delegate = nil
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
