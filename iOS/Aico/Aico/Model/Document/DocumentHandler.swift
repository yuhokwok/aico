//
//  DocumentHandler.swift
//  Aico
//
//  Created by itst on 19/10/2023.
//

import Foundation
import SwiftUI
import Observation

class DocumentHandler : ObservableObject {
    
    var name = "" 
    
    //undo manager
    let undoManager = UndoManager()
    
    //the document
    var document : AicoProject?
    
    //the project
    @Published var project : Project
    

    //var projectManager : ProjectManager
    init(document : AicoProject?) {
        self.document = document
        
        if let project = document?.project {
            self.project = project
        } else {
            self.project = Project.new()
        }
        
    }
    

    /// Get any entity including node and graph from the project
    /// - Parameter id: the identifiy of the entity
    /// - Returns: the entity which comfronts to HasAttribute and HasIdentifier protocol
    func entity(for id : String) -> (any (HasAttribute & HasIdentifier))? {
        //relationship graph
        if project.relationshipGraph.identifier == id {
            return project.relationshipGraph
        }
        
        for node in project.relationshipGraph.nodes {
            if node.identifier == id {
                return node
            }
        }
        
        for channel in project.relationshipGraph.channels {
            if channel.identifier == id {
                return channel
            }
        }
        
        
        //project graph
        if project.projectGraph.identifier == id {
            return project.projectGraph
        }
        
        for channel in project.projectGraph.channels {
            if channel.identifier == id {
                return channel
            }
        }
        
        //stage graph & nodes
        for stage in project.projectGraph.nodes {
            if stage.identifier == id {
                return stage
            }
            
            for node in stage.nodes {
                if node.identifier == id {
                    return node
                }
            }
            
            for channel in stage.channels {
                if channel.identifier == id {
                    return channel
                }
            }
            
        }
        
        return nil

    }
    
    
    /// Get any graph (not node) using given identifier
    /// - Parameter id: the id of the graph
    /// - Returns: the graph or nil if there is not value
    func graph(for id : String) -> (any Graph)? {
        return project.graph(with: id)
    }
 
    /// Get any graph (not node) contains the entity with given identifier
    /// - Parameter id: the id of the entity
    /// - Returns: the graph or nil if there is not value
    func graph(contains id : String) -> (any Graph)? {
        for node in project.projectGraph.nodes {
            if node.identifier == id {
                return project.projectGraph
            }
        }
        
        for channel in project.projectGraph.channels {
            if channel.identifier == id {
                return project.projectGraph
            }
        }
        
        for node in project.relationshipGraph.nodes {
            if node.identifier == id {
                return project.relationshipGraph
            }
        }
        
        for channel in project.relationshipGraph.channels {
            if channel.identifier == id {
                return project.relationshipGraph
            }
        }
        
        for graph in project.projectGraph.nodes {
            for node in graph.nodes {
                if node.identifier == id {
                    return graph
                }
            }
            
            for channel in graph.channels {
                if channel.identifier == id {
                    return graph
                }
            }
        }
        
        return nil
    }
    
    @MainActor func addNodeForGraph(with identifier : String, for bounds : CGRect) {

        if var graph = self.graph(for: identifier) as? RelationshipGraph {
            let role = PlayActor.new(for: bounds)
            graph.nodes.append(role)
            
            self.commit(graph, withId: identifier)
            return
        }
        
        if var graph = self.graph(for: identifier) as? ProjectGraph {
            let stage = StageGraph.new(for: bounds)
            graph.nodes.append(stage)
            
            self.commit(graph, withId: identifier)
            return
        }
        
        if var graph = self.graph(for: identifier) as? StageGraph {
            let block = Block.new(for: bounds)
            graph.nodes.append(block)
            
            self.commit(graph, withId: identifier)
            return
        }
    }
    
    @MainActor func deleteEntity(with identifier : String) {
        //delete role
        guard let graph = self.graph(contains: identifier), let entity = self.entity(for: identifier) else {
            print("\(String(describing: type(of: self)))::\(#function)::no target for deletion")
            return
        }
        
        if var graph = graph as? RelationshipGraph {
            print("\(String(describing: type(of: self)))::\(#function)::Delete Entity \(identifier) for Relationship Graph")
            
            if let target = entity as? Channel {
                
                for (index, channel) in graph.channels.enumerated() {
                    if channel.identifier == target.identifier {
                        var editorState = project.editorState
                        editorState.selectedId = project.relationshipGraph.identifier
                        graph.channels.remove(at: index)
                        self.commit(graph, withId: graph.identifier, and: editorState)
                        break
                    }
                }
                
            } else if let target = entity as? PlayActor {
                
                //TODO: update the related node in StageGraphs
                var editorState = project.editorState
                let ports = target.portIdentifiers
                for (index, node) in graph.nodes.enumerated() {
                    if entity.identifier == node.identifier {
                        editorState.selectedId = graph.identifier
                        graph.nodes.remove(at: index)
                        break
                    }
                }
                graph.removeDependedChannels(ports)
                self.commit(graph, withId: graph.identifier, and: editorState)
                
            }
            
        } else if var graph = graph as? ProjectGraph {
            print("\(String(describing: type(of: self)))::\(#function)::Delete Entity \(identifier) for Project Graph")
            
            if let target = entity as? Channel {
                
                for (index, channel) in graph.channels.enumerated() {
                    if channel.identifier == target.identifier {
                        var editorState = project.editorState
                        editorState.selectedId = project.projectGraph.identifier
                        graph.channels.remove(at: index)
                        self.commit(graph, withId: graph.identifier, and: editorState)
                        break
                    }
                }
                
            } else if let target = entity as? StageGraph {
                var editorState = project.editorState
                let ports = target.portIdentifiers
                for (index, node) in graph.nodes.enumerated() {
                    if entity.identifier == node.identifier {
                        editorState.selectedId = graph.identifier
                        graph.nodes.remove(at: index)
                        break
                    }
                }
                graph.removeDependedChannels(ports)
                self.commit(graph, withId: graph.identifier, and: editorState)
            }
            
        } else if var graph = graph as? StageGraph {
            print("\(String(describing: type(of: self)))::\(#function)::Delete Entity \(identifier) for Stage Graph")
            
            if let target = entity as? Channel {
                
                for (index, channel) in graph.channels.enumerated() {
                    if channel.identifier == target.identifier {
                        var editorState = project.editorState
                        editorState.selectedId = graph.identifier
                        graph.channels.remove(at: index)
                        self.commit(graph, withId: graph.identifier, and: editorState)
                        break
                    }
                }
                
            } else if let target = entity as? Block {
                var editorState = project.editorState
                let ports = target.portIdentifiers
                for (index, block) in graph.nodes.enumerated() {
                    if entity.identifier == block.identifier {
                        editorState.selectedId = graph.identifier
                        graph.nodes.remove(at: index)
                        break
                    }
                }
                graph.removeDependedChannels(ports)
                self.commit(graph, withId: graph.identifier, and: editorState)
            }
        }
    }
    
    @MainActor func duplicateNode(with identifier : String) {
        
    }
        
    //TODO: - save project
    func commit() {
        
    }
}

extension DocumentHandler {
    
    /// Commit the change of a project
    /// - Parameters:
    ///   - project: a staged project
    ///   - undAction: undo Action name
    ///   - redoAction: redo Action name
    @MainActor func commit(from prevProject : Project,
                           to nextProject : Project,
                           undoAction : String = "",
                           redoAction: String = "") {

        self.undoManager.registerUndo(withTarget: self, handler: {
            target in
            
            target.commit(from: nextProject,
                          to: prevProject,
                          undoAction: redoAction,
                          redoAction: undoAction)
            
        })
        
        self.update(nextProject)
        
    }
    
    private func update(_ project : Project,
                        undoAction : String = "",
                        redoAction: String = "") {
        
        print("register undo action")
        undoManager.setActionName(undoAction)
        self.project = project
        //self.stagedProject = project
    }
    
    
    
    @MainActor func commit(_ graph : any Graph,
                           withId id : String,
                           and state : EditorState? = nil,
                           undoAction: String = "",
                           redoAction: String = "") {
        
        
        
        var project : Project = self.project
        let prevProject : Project = self.project
        
        var graphRestored = false
        
        //TODO: - relationship graph
        if project.relationshipGraph.identifier == id, let graph = graph as? RelationshipGraph {
            project.relationshipGraph = graph
            graphRestored = true
        }
        
        if project.projectGraph.identifier == id, let graph = graph as? ProjectGraph {
            project.projectGraph = graph
            graphRestored = true
        }
        
        
        if graphRestored == false, let graph = graph as? StageGraph {
            for (index, element) in project.projectGraph.nodes.enumerated() {
                if element.identifier == id {
                    project.projectGraph.nodes[index] = graph
                    graphRestored = true
                    break
                }
            }
        }
        
        if let state = state {
            project.editorState = state
        } else {
            project.editorState.lastCommit = Date()
        }
        
        self.commit(from: prevProject, to: project ,undoAction: undoAction, redoAction: redoAction)
        

//        let oldEditorState = self.project.editorState
//        guard let oldGraph = self.graph(for: id) else {
//            return
//        }
//        
//        print("register undo action")
//        self.undoManager.registerUndo(withTarget: self, handler: {
//            target in
//
//            target.commit(oldGraph,
//                          withId: id,
//                          and: oldEditorState,
//                          undoAction: undoAction,
//                          redoAction: redoAction)
//        })
//        
//        undoManager.setActionName(undoAction)
//        self.updateGraph(graph, withId: id, and: state)
    }
    
    
    private func updateGraph(_ graph : any Graph, withId id : String, and state : EditorState? = nil) {

        var project = self.project
        
        var graphRestored = false
        
        //TODO: - relationship graph
        if project.relationshipGraph.identifier == id, let graph = graph as? RelationshipGraph {
            project.relationshipGraph = graph
            graphRestored = true
        }
        
        if project.projectGraph.identifier == id, let graph = graph as? ProjectGraph {
            project.projectGraph = graph
            graphRestored = true
        }
        
        
        if graphRestored == false, let graph = graph as? StageGraph {
            for (index, element) in project.projectGraph.nodes.enumerated() {
                if element.identifier == id {
                    project.projectGraph.nodes[index] = graph
                    graphRestored = true
                    break
                }
            }
            project.editorState.selectedStageId = graph.identifier
        }
        
        if let state = state {
            project.editorState = state
        } else {
            project.editorState.lastCommit = Date()
        }
        
        //update in batch
        self.project = project
    }
    
    //TODO: - undo
    func undo() {
        undoManager.undo()
    }
    
    //TODO: - redo
    func redo() {
        undoManager.redo()
    }
}
