//
//  AIExpView.swift
//  Aico
//
//  Created by Yu Ho Kwok on 12/12/23.
//

import SwiftUI
import GoogleGenerativeAI
import UIKit

struct AIExpView: View {
    @State var oneTurn = false
//    let palmClientOne = GenerativeLanguage(apiKey: "AIzaSyBg13A-5M8EtIKQljvpYuDdpICPp_6xWfs")
//    let palmClientTwo = GenerativeLanguage(apiKey: "AIzaSyBg13A-5M8EtIKQljvpYuDdpICPp_6xWfs")
    @State var text : String = "Hello"
    @State var question : String = ""
    
    @State var totalMessage = ""
    var body: some View {
        
        Text(oneTurn ? "one" : "two" )
        
        Text(text)
            .lineLimit(0)
            .frame(height: 100)
        TextField("Hi", text: $question)
            .textFieldStyle(.roundedBorder)
            .padding(5)
        
         
        Text(totalMessage)
            .lineLimit(0)
        
        Button(action: {
            

            Task {

                await chat()
            }
        }, label: {
            Text("Ask")
        })
    }
    
    let model = GenerativeModel(name: "gemini-pro-vision", apiKey: "AIzaSyATopmo0ohIrwSF-dpp0ay2H5LJ82hC5Jo")
    func chat() async {
        do {
//            let prompt = "Do these look store-bought or homemade?"
//            let chat = model.startChat()
//            let response = try await chat.sendMessage(prompt)
//            
//            text = "\(String(describing: response.text))"
            
            let cookieImage = UIImage(named: "cookie")!
            let prompt = "Hello Hong Kong. Are you Gemini?"

            let response = try await model.generateContent(prompt)
            text = "\(String(describing: response.text))"
        } catch {
            text = "\(error.localizedDescription)"
        }
    }
    
//    @State private var history = [Message]()
//    func chat(with client : GenerativeLanguage ) async {
//        
//        do {
//            var response: GenerateMessageResponse?
//            if history.isEmpty {
//                response = try await client.chat(message: "hello")
//            } else {
//                response = try await client.chat(message: "hello", history: history)
//            }
//            
//            
//            //let response = try? await palmClient.generateText(with: question)
//            if let candidate = response?.candidates?.first, let text = candidate.content {
//                
//                print("\(text)")
//                
//                if let historicMessages = response?.messages {
//                    history.append(candidate)
//                }
//                
//                self.totalMessage = "\(totalMessage)\n\(text)"
//                self.question = text
//                if oneTurn {
//                    oneTurn.toggle()
//                    try await self.chat(with: palmClientTwo)
//                } else {
//                    try await self.chat(with: palmClientOne)
//                }
//                
//            } else {
//                self.text = "nothing "
//            }
//        } catch {
//            print("\(error.localizedDescription)")
//            text = "\(error.localizedDescription)"
//        }
//        
//    }
}

#Preview {
    AIExpView()
}
