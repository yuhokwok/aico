//
//  DropViewDelegate.swift
//  Aico
//
//  Created by Yu Ho Kwok on 5/1/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices
//
struct DropStageGraphCellDelegate: DropDelegate {
    
    let destinationItem: StageGraph
    @Binding var nodes: [StageGraph]
    @Binding var draggedItem: StageGraph?
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Swap Items
        if let draggedItem {
            //print("\(draggedItem.identifier)")
            let fromIndex = nodes.firstIndex(where: { $0.id == draggedItem.id}) //nodes.firstIndex(of: draggedItem)
            //print("\(fromIndex)")
            if let fromIndex {
                let toIndex = nodes.firstIndex(where: { $0.id == destinationItem.id}) //nodes.firstIndex(of: destinationItem)
                if let toIndex, fromIndex != toIndex {
                    withAnimation {
                        self.nodes.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                    }
                }
            }
        }
    }
}
