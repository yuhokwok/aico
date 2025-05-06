//
//  DailyConciergeAPI.swift
//  DeepSeekAIApp
//
//  Created by stit on 20/2/2025.
//

import Foundation

// MARK: - Deepseek API Client for Daily Concierge





class DeepSeekAPI : ObservableObject {
    private let apiKey = "sk-ca7d074b92e94da58b7a0090f8b2309b" // Replace with your API key.
    private let baseURL = "https://api.deepseek.com" // Replace with the actual API base URL.
    
    @Published var loading = false
    
    func genProject(prompt:  String, completion : ((String) -> (Void))?) {
        loading = true
        Task {
            let finalPrompt = "我想進行 \(prompt). 請建議到發佈前需要做的步驟，請以 json 格式介紹 { \"projectName\", \"steps\":[{\"stepName\", \"description\"}]，只需傳回 JSON，不要傳回 JSON 以外的文字"
            
            
            let result = await self.chat(with: finalPrompt)
            
            
            print("\(result)")
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    completion?("error")
                    self.loading = false
                }
            case .success(let response):
                DispatchQueue.main.async {
                    var  content = response.choices?.first?.message?.content ?? ""
                    if content.count <= 0  {
                        completion?("error")
                    } else {
                        content = content.replacingOccurrences(of: "```json", with: "")
                        content = content.replacingOccurrences(of: "```", with: "")
                    }
                    completion?(content)
                    self.loading = false
                }
            }
            
//            var prediction = try await ReplicateClient.Llama2.predict(with: ReplicateClient.shared,
//                input: .init(prompt: finalPrompt))
//            
//            self.prediction = prediction
//            
//            try await prediction.wait(with: ReplicateClient.shared)
//            
//            if let output = prediction.output {
//                let json = output.reduce("", { return "\($0)\($1)"})
//                DispatchQueue.main.async {
//                    completion?(json)
//                    self.loading = false
//                }
//            } else{
//                DispatchQueue.main.async {
////                    completion?("error")
//                    
//                    self.loading = false
//                }
//            }
            
        }
    }

    // Chat API Call: Provide a conversational response to user input.
    func chat(with message: String, completion: @escaping (Result<DSChatResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }
        
        let question = """
        \(message)
        """
//    "你是碟仙，你可以隨機幾種回應風格：「簡潔、簡謹、譁眾取寵、輕鬆、平實或愛出風頭。」而你只需回覆相關答案，不作其他回應。你的回答不能用任何標點，並用以下格式回答，嚴格使用換行符號 「\n」 分隔中英文的一句：「你的中文回答\nYour English Answer」。你的中文回答嚴格僅利用，不可用其他字餘字，可以考慮粵音同音字，可用的字庫如下：「\(WordBank.words2)」，字數不可多於30字。中文回答和Your English Answer的詞彙次序和意思必須一致，合乎文法。提問是：「\(message)」。"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonBody: [String : Any] = ["model": "deepseek-chat",
                                        "messages": [
//                                            ["role" : "assistant",
//                                             "content" : ""],
                                            ["role" : "user",
                                            "content" : question]
                                        ],
                                        "stream": false]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: nil)))
                return
            }
            do {
                //print("data: \(String(data: data, encoding: .utf8))")
                let chatResponse = try JSONDecoder().decode(DSChatResponse.self, from: data)
                completion(.success(chatResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Chat API Call: Provide a conversational response to user input.
    func chat(with message: String) async -> Result<DSChatResponse, Error>  {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            return .failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil))
        }
        
        let question = """
        \(message)
        """

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonBody: [String : Any] = ["model": "deepseek-chat",
                                        "messages": [
                                            ["role" : "user",
                                            "content" : question]
                                        ],
                                        "stream": false]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch {
            return .failure(error)
            
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let chatResponse = try JSONDecoder().decode(DSChatResponse.self, from: data)
            return .success(chatResponse)
        } catch {
            return .failure(error)
        }
    }
    
    
    func execute(for stage : StageGraph, name : String, role: String, last : String) async -> String {
        
        //let allrole = stage.nodes.count > 0 ? stage.nodes.reduce("", { "\($0), \($1.name) the \($1.role)"}) : "作者, 編輯"

        
        let finalPrompt = last.isEmpty ? "你要完成工作: \(stage.name), 因為你是第一個發言人，你亦要負責開啟對話， 內容如下: \(stage.description)，，請模擬角色\(name)的對話，角色的崗位是\(role)，如果你覺得討論夠充份，請輸出\"[完成]\"。請每個回應都限制於 10至300 字內，請專業地以中文發言，每次只能有一段發言，其餘留給後續對話。請只以 {\"speaker:\" : \"角色名\",  \"content\" : \"對話內容\" } 格式 json 輸出，不要其他內容" : "你要完成工作: \(stage.name)，內容如下: \(stage.description)，請模擬角色\(name)的對話，角色的崗位是\(role)，請專業地以中文發言，每次只能有一段發言，其餘留給後續對話。如果你覺得討論夠充份，請輸出\"[完成]\"。請每個回應都限制於 10至300 字內。上一句對白是: \(last)，請只以 {\"speaker:\" : \"角色名\",  \"content\" : \"對話內容\" } 格式 json 輸出，不要其他內容"
        
        print("\(finalPrompt)")
        
        DispatchQueue.main.async {
            //completion?(json)
            self.loading = true
        }
        do {
            let result = await self.chat(with: finalPrompt)
            
            
            print("\(result)")
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.loading = false
                }
                return ""
            case .success(let response):
                var  content = response.choices?.first?.message?.content ?? ""
                DispatchQueue.main.async {
                    self.loading = false
                }
                if content.count <= 0 {
                    content = ""
                } else {
                    content = content.replacingOccurrences(of: "```json", with: "")
                    content = content.replacingOccurrences(of: "```", with: "")
                }
                print(content)
                return content
            }
        } catch {
            self.loading = false
            return ""
        }
    }
    
}
