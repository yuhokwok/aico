//
//  Project.swift
//  CoAI
//
//  Created by itst on 8/10/2023.
//

import Foundation
import UIKit

/// The project object
struct Project : Codable {
    
    var identifier : String = UUID().uuidString
    var name : String
    
    //other attributes
    var attribute : Attribute
    
    //graph that describe relationship
    var relationshipGraph : RelationshipGraph
    //graph that describe the stage
    var projectGraph : ProjectGraph
    
    //editor state
    var editorState : EditorState

    func graph(with id : String) -> (any Graph)? {
        if relationshipGraph.identifier == id {
            return relationshipGraph
        }
        
        if projectGraph.identifier == id {
            return projectGraph
        }
        
        for stageGraph in projectGraph.nodes {
            if stageGraph.identifier == id {
                return stageGraph
            }
        }
        
        return nil
    }
    
    static func new() -> Project {
        let projectGraph =  ProjectGraph.new(for: .zero)
        let editorState = EditorState(selectedId: projectGraph.identifier)
        let project = Project(name: "Unnamed",
                              attribute: Attribute.new,
                              relationshipGraph: RelationshipGraph.new(for: .zero),
                              projectGraph: projectGraph, editorState: editorState)
        
        return project
    }
}
