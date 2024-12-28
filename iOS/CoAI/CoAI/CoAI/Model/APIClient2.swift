//
//  APIClient.swift
//  LidarModel
//
//  Created by itst on 8/5/2024.
//

import Foundation
import Replicate

struct APIClient2 {
    var prediction: ReplicateAPIClient.Llama3.Prediction? = nil
    
    let apiKey = "92da1c8c-42b7-4242-8aca-ae436f2347e9"
    static let shared = APIClient2 ()
    
    func chat(string : String) async -> String {
        do {
            var prediction = try await ReplicateAPIClient.Llama3.predict(with: ReplicateAPIClient.shared,
                                                                      input: .init(prompt: string))
            
            try await prediction.wait(with: ReplicateAPIClient.shared)
            
            if let output = prediction.output {
                let json = output.reduce("", { return "\($0)\($1)"})
                return json
            } else{
                return "Error,please try again"
            }
        } catch {
            return "Error,please try again"
        }
    }
}


struct ReplicateAPIClient {
    
    static var shared = Replicate.Client(token: "r8_HiVWXs7UAKLXZFM08ZNu1W20WMfCKio1WcnEp")
    
    
    enum Llama3 : Predictable {
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
}
