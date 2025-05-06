//
//  ChatResponse.swift
//  DeepSeekAIApp
//
//  Created by stit on 20/2/2025.
//

import Foundation

struct DSChatResponse: Decodable {
    let choices : [ChatChoice]?
}

struct ChatChoice : Decodable {
    let message : ChatMessage?
}

struct ChatMessage : Decodable {
    let content : String?
}
