//
//  BaseInspector.swift
//  Aico
//
//  Created by Yu Ho Kwok on 12/8/23.
//

import Foundation

protocol BaseInspector {
    var isUndoEnabled : Bool { get set }
    
    var editorState : EditorState { get set }
    var handler : DocumentHandler { get set }
    
    
}
