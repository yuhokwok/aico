// APIService.swift

import UIKit
import CoreML

struct ChatResponse : Codable {
    var id : String
    var object : String
    var model : String
    var created : Int
    var choices : [Choice]
    var usage : Usage
   
    struct Usage : Codable {
        var prompt_tokens : Int
        var completion_tokens : Int
        var total_tokens : Int
    }

    struct Choice : Codable {
        var index : Int
        var message : Message
        var finish_reason : String
    }

    struct Message : Codable {
        let role : String
        let content : String
    }

}


struct Response: Decodable {
    let data: [ImageURL]
}

struct ImageURL: Decodable {
    let url: String
}

enum APIError: Error {
    case unableToCreateText
    case unableToCreateImageURL
    case unableToConvertDataIntoImage
    case unableToCreateURLForURLRequest
}

enum APIRequestGenerationType  {
    case text
    case image
}

class APIService {
    
    let apiKey = "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"
    
    static let sharedInstance1 = APIService()
    static let sharedInstance2 = APIService()
    

    func fetch(_ prompt: String, to target : String) async throws -> ChatResponse {
        let urlRequest = try createURLRequest(for: .text, with: ["prompt" : prompt, "target" : target], using: "POST")
        let (data, _ ) = try await URLSession.shared.data(for: urlRequest)
        
        print("data: \(String(data: data, encoding: .utf8))")
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(ChatResponse.self, from: data)
       
        return result
    }
    
    func fetchImage(_ prompt : String) async throws -> UIImage {
        
        let urlRequest = try createURLRequest(for: .image, with: ["prompt" : prompt], using: "POST")
        let (data, _ ) = try await URLSession.shared.data(for: urlRequest)
        
        let decoder = JSONDecoder()
        let results = try decoder.decode(Response.self, from: data)
        
        let imageURL = results.data[0].url
        guard let imageURL = URL(string: imageURL) else {
            throw APIError.unableToCreateImageURL
        }
        
        let (imageData, _ ) = try await URLSession.shared.data(from: imageURL)
        
        guard let image = UIImage(data: imageData) else {
            throw APIError.unableToConvertDataIntoImage
        }
        return image
    }
    
    private func createURLRequestCity(for generationType : APIRequestGenerationType, with input: [String: String], using httpMethod: String) throws -> URLRequest {
        
        var endPoint = ""
        
        switch generationType {
        case .image:
            endPoint = "https://cityucsopenai.azurewebsites.net/api/openai/deployments/gpt-4-1106-preview/chat/completions?api-version=2023-05-15"
        case .text:
            endPoint = "https://cityucsopenai.azurewebsites.net/api/openai/deployments/gpt-4-1106-preview/chat/completions?api-version=2023-05-15"
        }
        
        guard let url = URL(string: endPoint) else {
            throw APIError.unableToCreateURLForURLRequest
        }
        
        var urlRequest = URLRequest(url: url)
        
        // Method
        urlRequest.httpMethod = httpMethod
        
        
        // Headers
        urlRequest.addValue("8f9da407da5f7161f15c028dc3540df9cc70990b57f014b1a14faa99f6acabb140820116eeb22deb9d717f2e2f230fec3873bdb86412213be212c40c1d2b5316e5ad600adc2cb6f1db441787f0a5136179c09e280b3d35eb78463b6c9ae03ded", forHTTPHeaderField: "api-key")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
       
        
        var jsonBody : [String : Any] = [:]
        
        switch generationType {
        case .image:
            jsonBody = [
                "prompt": "\(input["prompt"]!)",
                "n": 1,
                "size": "1024x1024"
            ]
        case .text:
            jsonBody = [
                //"model" : "gpt-3.5-turbo",
                //"model": "gpt-4-32k",
                //"response_format": [ "type" : "json_object" ],
                //"presence_penalty": 0.3,
                "messages" : [
                    ["role" : "system",
                    "content" : "你是 \(input["target"]!)，請以這個身份回應，並以 80-150 字內，好像好朋友談天一樣"] ,
                    ["role" : "user",
                    "content" : "\(input["prompt"]!)"] ,
                    ["role" : "assistant",
                    "content" : ""]
                ]
            ]
        }
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
        
        return urlRequest
    }
    
    
    private func createURLRequest(for generationType : APIRequestGenerationType, with input: [String: String], using httpMethod: String) throws -> URLRequest {
        
        var endPoint = ""
        
        switch generationType {
        case .image:
            endPoint = "https://api.openai.com/v1/images/generations"
        case .text:
            endPoint = "https://api.openai.com/v1/chat/completions"
        }
        
        guard let url = URL(string: endPoint) else {
            throw APIError.unableToCreateURLForURLRequest
        }
        
        var urlRequest = URLRequest(url: url)
        
        print("hihihi")
        
        // Method
        urlRequest.httpMethod = httpMethod
        
        
        // Headers
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
       
        
        var jsonBody : [String : Any] = [:]
        
        switch generationType {
        case .image:
            jsonBody = [
                "prompt": "\(input["prompt"]!)",
                "n": 1,
                "size": "1024x1024"
            ]
        case .text:
            jsonBody = [
                //"model" : "gpt-3.5-turbo-16k",
                "model": "gpt-4-0125-preview",
                //"response_format": [ "type" : "json_object" ],
//                "presence_penalty": 0.3,
                "messages" : [
//                    ["role" : "system",
//                    "content" : "你是 \(input["target"]!)，請以這個身份回應，並以 80-150 字內，好像好朋友談天一樣"] ,
                    ["role" : "user",
                    "content" : "\(input["prompt"]!)"] ,
//                    ["role" : "assistant",
//                    "content" : ""]
                ]
            ]
        }
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
        
        return urlRequest
    }
}
