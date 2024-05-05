//
//  Runtime.swift
//  Aico
//
//  Created by Yu Ho Kwok on 5/5/24.
//

import Foundation
import SwiftUI

struct Record : Identifiable {
    var id : String = UUID().uuidString
    var speaker : String //todo
    var date : Date
    var content : String
}


class Runtime : ObservableObject {
    
    var project : Project
    
    @Published var records : [Record] = []
    @Published var isExecuting = false
    
    init(project : Project){
        self.project = project
    }
    
    func execute()  {
        let stageGraphs = project.projectGraph.nodes
        isExecuting = true
        Task {
            for stageGraph in stageGraphs {
                print("execute: \(stageGraph.name)")
                sleep(5)
                
                DispatchQueue.main.async {
                    self.records.append(Record(speaker: "yo",
                                          date: Date(), 
                                               content: "\(stageGraph.name) complete"))
                }
            }
            
            DispatchQueue.main.async {
                self.records.append(Record(speaker: "yo", date: Date(), content: "All Process completed"))
                self.isExecuting = false
            }
        }
    }
    
}
