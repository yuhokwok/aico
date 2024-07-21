//
//  Runtime.swift
//  Aico
//
//  Created by itst on 5/5/24.
//

import Foundation
import SwiftUI

struct Record : Identifiable, Codable {
    var id : String = UUID().uuidString
    var speaker : String //todo
    var date : Date
    var content : String
    var type : String = "system"
}

struct Converation : Codable {
    var speaker : String
    var content : String
}

class Runtime : ObservableObject {
    
    var project : Project
    var genClient = GenerativeClient()
    
    var keepRunning = true
    
    @Published var records : [Record] = []
    @Published var isExecuting = false
    
    init(project : Project){
        self.project = project
    }
    
    
    func cancel() {
        keepRunning = false
    }
    func execute()  {
        keepRunning = true
        let stageGraphs = project.projectGraph.nodes
        isExecuting = true
        Task {
            for stageGraph in stageGraphs {
                print("execute: \(stageGraph.name)")
                DispatchQueue.main.async {
                    self.records.append(Record(speaker: "System Process",
                                               date: Date(),
                                               content: "Start Working on \(stageGraph.name)"))
                }
                
                var result = ""
                //sleep(5)
                let randomCount = Int.random(in: 10...18)
                for _ in 0..<randomCount {
                    let new_result = await genClient.execute(for: stageGraph, last: result)
                    
                    
                    
                    if let data = new_result.data(using: .utf8), let conversation = try? JSONDecoder().decode(Converation.self, from: data) {
                        DispatchQueue.main.async {
                            print("result: \(new_result)")
                            self.records.append(Record(speaker: conversation.speaker,
                                                       date: Date(),
                                                       content: conversation.content, type: "conversation"))
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            print("result: \(new_result)")
                            self.records.append(Record(speaker: "Converstion",
                                                       date: Date(),
                                                       content: "\(new_result)"))
                        }
                    }
                    

                    result = new_result
                    
                    if keepRunning == false {
                        break
                    }

                }
                
                
                DispatchQueue.main.async {
                    self.records.append(Record(speaker: "System Process",
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
