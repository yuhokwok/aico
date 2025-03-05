//
//  LinuxSimView.swift
//  LangChainApp
//
//  Created by Yu Ho Kwok on 6/3/2025.
//

import SwiftUI
import LangChain

struct LinuxSimView : View {
    
    @FocusState private var isFocused: Bool
    
    @State var records : [String] = []

    
    @State var isLoading : Bool = false
    @State var commandStr : String = ""
    var body : some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { records.removeAll() }, label: { Text("Clear") }).tint(.gray).buttonStyle(.bordered)
            }
            ScrollView {
                VStack (alignment: .leading){
                    Text("Welcome to this Linux Simulator")
                    
                    ForEach (0..<records.count, id:\.self) {
                        i in
                        Text("\(records[i])")
                    }
                    
                    if !isLoading {
                        HStack {
                            Text("user@iPhone ~ %")
                            
                            
                            TextField("_", text: $commandStr)
                                .autocorrectionDisabled(true)
                                .autocapitalization(.none)
                                .onSubmit {
                                    self.records.append("user@iPhone ~ %" + commandStr)
                                    sim(commandStr)
                                    commandStr = ""
                                }
                                .tint(.green)
                                .disabled(isLoading)
                                .focused($isFocused)
                        }
                    }
                    
                    if isLoading {
                        ProgressView().progressViewStyle(.circular)
                            .brightness(1.2)
                    }
                    
                    Spacer()
                    HStack{
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .foregroundStyle(.green)
        .background(Color.black)
        .onAppear {
            isFocused = true
        }
    }
    
    func sim(_ command : String) {
        isLoading = true
        isFocused = false
        
        let template = """
        Assistant is a large language model trained by OpenAI.

        Assistant is designed to be able to assist with a wide range of tasks, from answering simple questions to providing in-depth explanations and discussions on a wide range of topics. As a language model, Assistant is able to generate human-like text based on the input it receives, allowing it to engage in natural-sounding conversations and provide responses that are coherent and relevant to the topic at hand.

        Assistant is constantly learning and improving, and its capabilities are constantly evolving. It is able to process and understand large amounts of text, and can use this knowledge to provide accurate and informative responses to a wide range of questions. Additionally, Assistant is able to generate its own text based on the input it receives, allowing it to engage in discussions and provide explanations and descriptions on a wide range of topics.

        Overall, Assistant is a powerful tool that can help with a wide range of tasks and provide valuable insights and information on a wide range of topics. Whether you need help with a specific question or just want to have a conversation about a particular topic, Assistant is here to assist.

        {history}
        Human: {human_input}
        Assistant:
        """

        let prompt = PromptTemplate(input_variables: ["history", "human_input"], partial_variable: [:], template: template)


        let chatgpt_chain = LLMChain(
            llm: LMStudio(),
            prompt: prompt,
            memory: ConversationBufferWindowMemory()
        )
        
        Task(priority: .background)  {
            let input = "I want you to act as a Linux terminal. I will type commands and you will reply with what the terminal should show. I want you to only reply with the terminal output inside one unique code block, and nothing else. Do not write explanations. Do not type commands unless I instruct you to do so. When I need to tell you something in English I will do so by putting text inside curly brackets {like this}. My command is \"\(command)\"."
            
            let res = await chatgpt_chain.predict(args: ["human_input": input])
            print(input)

            guard let res = res else { return }
            self.records.append(res.replacingOccurrences(of: "```", with: "").trim())
            DispatchQueue.main.async {
                self.isLoading = false
                self.isFocused = true
            }
        }
    }
}

#Preview {
    LinuxSimView()
}
