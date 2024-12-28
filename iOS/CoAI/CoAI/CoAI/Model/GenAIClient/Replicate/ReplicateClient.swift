//
//  Replicate.swift
//  CoAI
//
//  Created by itst on 5/5/24.
//

import Foundation
import Replicate

struct GeneratedProject : Codable {
    var projectName : String
    var steps : [GeneratedStep]
}

struct GeneratedStep  :Codable {
    var stepName : String
    var description : String
}

class GenerativeClient : ObservableObject {
    //@Published var preduction :
    
    @Published var loading = false
    var prediction: ReplicateClient.Llama2.Prediction? = nil
    
    
    func execute(for stage : StageGraph, last : String) async -> String {
        
        let allrole = stage.nodes.count > 0 ? stage.nodes.reduce("", { "\($0), \($1.name) the \($1.role)"}) : "作者, 編輯"
        
        let finalPrompt = last.isEmpty ? "你要完成工作: \(stage.name), 內容如下: \(stage.description)，，請模擬以下角色對話:\(allrole)的對話，隨機選一個身份發言，完成時請輸出\"[完成]\"。請每個回應都限制於 100 字內。請只以 {\"speaker:\" : \"角色名\",  \"content\" : \"對話內容\" } 格式 json 輸出，不要其他內容" : "你要完成工作: \(stage.name), 內容如下: \(stage.description)，請模擬以下角色對話:\(allrole)的對話，隨機選一個身份發言，完成時請輸出\"[完成]\"。請每個回應都限制於 100 字內。上一句對白是: \(last)，請只以 {\"speaker:\" : \"角色名\",  \"content\" : \"對話內容\" } 格式 json 輸出，不要其他內容"
        
        print("\(finalPrompt)")
        
        DispatchQueue.main.async {
            //completion?(json)
            self.loading = true
        }
        do {
            var prediction = try await ReplicateClient.Llama2.predict(with: ReplicateClient.shared,
                                                                      input: .init(prompt: finalPrompt))
            
            self.prediction = prediction
            
            try await prediction.wait(with: ReplicateClient.shared)
            
            if let output = prediction.output {
                let json = output.reduce("", { return "\($0)\($1)"})
                DispatchQueue.main.async {
                    //completion?(json)
                    self.loading = false
                }
                return json
            } else{
                DispatchQueue.main.async {
                    //completion?("error")
                    self.loading = false
                }
                return ""
            }
        } catch {
            self.loading = false
            return ""
        }
    }
    
    func genProject(prompt:  String, completion : ((String) -> (Void))?) {
        loading = true
        Task {
            let finalPrompt = "我想進行 \(prompt). 請建議到發佈前需要做的步驟，請以 json 格式介紹 { \"projectName\", \"steps\":[{\"stepName\", \"description\"}]，只需傳回 JSON，不要傳回 JSON 以外的文字"
            
            var prediction = try await ReplicateClient.Llama2.predict(with: ReplicateClient.shared,
                input: .init(prompt: finalPrompt))
            
            self.prediction = prediction
            
            try await prediction.wait(with: ReplicateClient.shared)
            
            if let output = prediction.output {
                let json = output.reduce("", { return "\($0)\($1)"})
                DispatchQueue.main.async {
                    completion?(json)
                    self.loading = false
                }
            } else{
                DispatchQueue.main.async {
                    completion?("error")
                    self.loading = false
                }
            }
            
        }
    }
    
    func genThumbnail(prompt: String, completion : ((String) -> (Void))?) {
        loading = true
        Task {
            let finalPrompt = "a single person, close up, japanese anime style, role: \(prompt)"
            
            var prediction = try await ReplicateClient.StableDiffusion.predict(with: ReplicateClient.shared, input: .init(prompt: finalPrompt))
            
            try await prediction.wait(with: ReplicateClient.shared)
            
            if let output = prediction.output?.first {
                let url = output.absoluteString
                DispatchQueue.main.async {
                    completion?(url)
                    self.loading = false
                }
            } else{
                DispatchQueue.main.async {
                    completion?("error")
                    self.loading = false
                }
            }
        }
    }
}

struct ReplicateClient {
    
    static var shared = Replicate.Client(token: "r8_HiVWXs7UAKLXZFM08ZNu1W20WMfCKio1WcnEp")
    
    
    //var prediction: StableDiffusion.Prediction? = nil
    
    
    // https://replicate.com/stability-ai/stable-diffusion
    enum StableDiffusion: Predictable {
        static var modelID = "stability-ai/stable-diffusion"
        static let versionID = "db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf"
        
        struct Input: Codable {
            let prompt: String
        }
        
        typealias Output = [URL]
    }
    
    enum Llama2 : Predictable {
        static var modelID = "meta/meta-llama-3-70b-instruct"
        static let versionID = "fbfb20b472b2f3bdd101412a9f70a0ed4fc0ced78a77ff00970ee7a2383c575d"
        
        struct Input: Codable {
            let prompt: String
            var min_tokens : Int = 0
            var max_tokens : Int = 1024
            var top_p = 0.9
            var temperature = 0.6
            var presence_penalty = 1.15
            var frequency_penalty = 0.2
        }
        
        typealias Output = [String]
    }
    
    

    
//    我想建立一個 social media 的 instagram post. 請建議到發佈前需要做的步驟，請以 json 格式介紹
//       [{"step", "description"}]
    
        
//    mutating func generate(prompt:  String) async throws {
//        prediction = try await StableDiffusion.predict(with: client,
//                                                       input: .init(prompt: prompt))
//        try await self.prediction?.wait(with: client)
//    }
//    
//    mutating func cancel() async throws {
//        try await self.prediction?.cancel(with: client)
//    }
}
