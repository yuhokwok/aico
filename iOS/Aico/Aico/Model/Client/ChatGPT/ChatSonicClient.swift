//
//  ChatSonicClient.swift
//  Aico
//
//  Created by itst on 5/5/24.
//

//import Foundation
//
//struct ChatSonicClient {
//    
//    func chat(prompt: String) async -> String? {
//        
//        do {
//            let parameters = [
//                "enable_google_results": "true",
//                "enable_memory": false,
//                "input_text": "\(prompt)"
//                //,"history_data": [["newKey": "New Value"]]
//            ] as [String : Any?]
//            
//            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
//            
//            let url = URL(string: "https://api.writesonic.com/v2/business/content/chatsonic")!
//            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
//            let queryItems: [URLQueryItem] = [
//                URLQueryItem(name: "engine", value: "superior"),
//                URLQueryItem(name: "language", value: "en"),
//            ]
//            components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
//            
//            var request = URLRequest(url: components.url!)
//            request.httpMethod = "POST"
//            request.timeoutInterval = 10
//            request.allHTTPHeaderFields = [
//                "accept": "application/json",
//                "content-type": "application/json",
//                "X-API-KEY": "173a24f1-1b08-4849-92c4-1cfbcbbbfb56"
//            ]
//            request.httpBody = postData
//            
//            
//            
//            let (data, _) = try await URLSession.shared.data(for: request)
//            return String(decoding: data, as: UTF8.self)
//        } catch {
//            return nil
//        }
//        
//    }
//    
//}
