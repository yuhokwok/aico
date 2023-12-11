//
//  EditorState.swift
//  Aico
//
//  Created by Yu Ho Kwok on 12/3/23.
//

import SwiftUI
import Foundation


/// Store all the editor setting of this application
struct EditorState : Codable, Equatable {
    
    static func == (lhs: EditorState,
                    rhs: EditorState) -> Bool {
//            return lhs.entity?.identifier == rhs.entity?.identifier && lhs.mode == rhs.mode
        
        return lhs.selectedId == rhs.selectedId && lhs.mode == rhs.mode && lhs.lastCommit == rhs.lastCommit
    }
    
    //any object has attribute
    //var entity : (HasAttribute & HasIdentifier)?
    
    var mode : Mode = .project
    
    var selectedId : String?
    
    var selectedStageId : String?
    
    var lastCommit = Date()
//    
//    enum Mode : String, Codable {
//        case project = "project"
//        case stage = "stage"
//        case relationship = "relationship"
//    }
//    
    struct Mode : OptionSet, Codable {
        let rawValue: Int
        
        static let project      = Mode(rawValue: 1 << 0)
        static let stage        = Mode(rawValue: 1 << 1)
        static let relationship = Mode(rawValue: 1 << 2)
    }
    
}

