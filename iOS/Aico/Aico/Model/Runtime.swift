//
//  Runtime.swift
//  Aico
//
//  Created by itst on 5/5/24.
//

import Foundation
import SwiftUI

struct Record : Identifiable, Codable, Equatable, Hashable {
    var id : String = UUID().uuidString
    var speaker : String //todo
    var speakerId : String?
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
    var genClient = DeepSeekAPI()
    
    var keepRunning = true
    
    @Published var records : [Record] = []
    @Published var isExecuting = false
    
    init(project : Project){
        self.project = project
    }
    
    func image(for uuid : String?) -> UIImage? {
        guard let uuid = uuid else { return nil }
        guard let actor = self.project.relationshipGraph.nodes.first(where: { $0.id == uuid }) else {
            return nil
        }
        return actor.thumbnail
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
                var nameStr = "名字: 主管"
                var roleStr = "職位: 經理"
                //sleep(5)
                let randomCount = Int.random(in: 10...18)
                for _ in 0..<randomCount {
                    
                    var role : PlayActor?
                    if project.relationshipGraph.nodes.count > 0 {
                        if result.count == 0 {
                            role = project.relationshipGraph.nodes.first!
                            nameStr = "名字: \((role!.name))"
                            roleStr = "崗位: \((role!.role))"
                        } else {
                            role = project.relationshipGraph.nodes.randomElement()!
                            nameStr = "名字: \((role!.name))"
                            roleStr = "崗位: \((role!.role))"
                        }
                    }

                    let new_result = await genClient.execute(for: stageGraph, name: nameStr, role: roleStr, last: result)
                    
                    
                    
                    if let data = new_result.data(using: .utf8), let conversation = try? JSONDecoder().decode(Converation.self, from: data) {
                        DispatchQueue.main.async {
                            print("result: \(new_result)")
                            self.records.append(Record(speaker: conversation.speaker,
                                                       speakerId: role?.identifier, 
                                                       date: Date(),
                                                       content: conversation.content, type: "conversation"))
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            print("result: \(new_result)")
                            self.records.append(Record(speaker: "Conversation",
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
                    self.records.append(Record(speaker: "系統訊息",
                                               date: Date(),
                                               content: "\(stageGraph.name) 完成"))
                }
                
                if keepRunning == false {
                    break
                }
            }
            
            DispatchQueue.main.async {
                self.records.append(Record(speaker: "系統訊息", date: Date(), content: "所有工作已完成"))
                self.isExecuting = false
                self.keepRunning = false
            }
        }
    }
    
}
