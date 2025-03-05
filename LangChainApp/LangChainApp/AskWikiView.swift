//
//  AskWikiView.swift
//  LangChainApp
//
//  Created by Yu Ho Kwok on 6/3/2025.
//

import SwiftUI
import LangChain

struct AskWikiView : View {
    
    
    @FocusState var isFocused: Bool
    
    @State var enquiryStr = "What is HKIIT?"
    @State var isLoading = false
    
    @State var response = ""

    var body : some View {

        //Retriver Example
        VStack (alignment: .leading) {
            
            HStack {
                TextField("Your Question", text: $enquiryStr)
                    .focused($isFocused)
                    .disabled(isLoading)
                    .textFieldStyle(.roundedBorder)
                
                ProgressView().progressViewStyle(.circular)
                
                Spacer()
                
                Button(action: {
                    
                    if enquiryStr.count > 0 {
                        retrieve(enquiryStr)
                        enquiryStr = ""
                        isFocused = false
                    }
                    
                }, label: {
                    Text("Send")
                }).buttonStyle(.bordered)
                    .disabled(isLoading)
            }.padding()
            
            ScrollView {
                Text("\(response)").lineLimit(nil)
            }
            Spacer()
            
            HStack {
                    Spacer()
            }
        }

    }
    
    func retrieve(_ enquiryStr : String ){
        self.response = ""
        self.isLoading = isLoading
        
        Task(priority: .background)  {
            let retriever = WikipediaRetriever()
            let qa = ConversationalRetrievalChain(retriver: retriever, llm: LMStudio())
            let questions = [
                "\(enquiryStr)"
            ]
            var chat_history:[(String, String)] = []

            for question in questions{
                let result = await qa.predict(args: ["question": question, "chat_history": ConversationalRetrievalChain.get_chat_history(chat_history: chat_history)])
                
                chat_history.append((question, result!.0))
                print("⚠️**Question**: \(question)")
                print("✅**Answer**: \(result!.0)")
                
                print("\(result!.1)")
                
                response += "⚠️**Question**: \(question) \n\n✅**Answer**: \(result!.0)"
            }
            
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
