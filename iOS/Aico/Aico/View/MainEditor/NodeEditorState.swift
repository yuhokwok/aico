//
//  EditorState.swift
//  Aico
//
//  Created by itst on 12/10/2023.
//

import Foundation



/// A data structure that stores the state of the editor
struct NodeEditorState {
    
    static var minScale = 0.5
    static var maxScale = 1.2
    
    var selectedNodeId : String? {
        didSet {
            if selectedNodeId != nil {
                self.selectedChannelId = nil
            }
        }
    }
    
    var selectedChannelId : String? {
        didSet {
            if selectedChannelId != nil {
                self.selectedNodeId = nil
            }
        }
    }
    

    //For dragging a line
    var draggedPort : Port?
    var initialDraggedPoint : CGPoint = .zero
}
