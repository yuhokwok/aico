//
//  ViewModel.swift
//  CoAI
//
//  Created by Yu Ho Kwok on 2/13/25.
//


import Foundation
import OllamaKit
import Combine

@Observable
@MainActor
final class OllamaClient {
    var ollamaKit = OllamaKit(baseURL: URL(string: "http://192.168.128.73:11434")!)
    
    var isReachable = false
    var models = [String]()
    
    func reachable() async {
        self.isReachable = await ollamaKit.reachable()
    }
    
    func fetchModels() async {
        let response = try? await ollamaKit.models()
        guard let models = response?.models.map({ $0.name }) else { return }
        
        self.models = models
    }
    
    var model: String? = nil
    var temperature: Double = 0.5
    var prompt = ""
    var response = ""
    var cancellables = Set<AnyCancellable>()
    func  actionAsync() {
        self.response = ""
        guard let model = model else { return }
        let messages = [OKChatRequestData.Message(role: .user, content: prompt)]
        var data = OKChatRequestData(model: model, messages: messages)
        Task {
            for try await chunk in ollamaKit.chat(data: data) {
                self.response += chunk.message?.content ?? ""
            }
        }
    }
    
}
