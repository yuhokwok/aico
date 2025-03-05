//
//  RagView.swift
//  LangChainApp
//
//  Created by Yu Ho Kwok on 6/3/2025.
//

import SwiftUI
import LangChain

struct AgentView: View {
    @State var prompt : String = "The Weather in Hong Kong"
    @State var isLoading = false
    
    @State var result : String? = nil
    
    var body: some View {
        VStack {
            TextField("Any question related to weather", text: $prompt)
                .textFieldStyle(.roundedBorder)
            Button(action: {
                agent(prompt)
            }, label: {
                Text("Show me the weather")
                    .buttonStyle(.bordered)
            })
            .disabled(isLoading)
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            }
        }
        .padding()
        .sheet(isPresented: Binding(get: { return self.result != nil },
                                             set: {
            _ in
            self.result = nil
        }), content: {
            ScrollView {
                VStack {
                    if let result = result {
                        Text (result)
                    }
                }
            }.padding()
        })
    }
    
    func agent(_ prompt : String) {
        isLoading  = true
        let agent = initialize_agent(llm: LMStudio(), tools: [WeatherTool()])
        Task(priority: .background)  {
            let res = await agent.run(args: "\(prompt)")
            switch res {
            case Parsed.str(let str):
                print("🌈:" + str)
                self.result = "🌈:" + str
            default: break
            }
            isLoading = false
        }
    }
}

#Preview {
    AgentView()
}
