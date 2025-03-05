//
//  RouterView.swift
//  LangChainApp
//
//  Created by Yu Ho Kwok on 6/3/2025.
//

import SwiftUI
import LangChain

struct RouterView: View {
    @State var query : String = "What is black body radiation?"
    @State var reply : String = ""
    @State var isLoading : Bool = false
    
    var body: some View {
        VStack {
            HStack {
                TextField("Your Query", text: $query)
                    .disabled(isLoading)
                    .textFieldStyle(.roundedBorder)
                if isLoading {
                    ProgressView().progressViewStyle(.circular)
                }
                Button(action: {
                    prompt(query)
                }, label: {
                    Text("Send")
                })
                .disabled(isLoading)
                Spacer()
            }.padding()

            ScrollView {
                Text(reply)
            }.padding()
            Spacer()
        }
    }
    
    func prompt(_ msg : String) {
        isLoading = true
        let physics_template = """
        You are a very smart physics professor. \
        You are great at answering questions about physics in a concise and easy to understand manner. \
        When you don't know the answer to a question you admit that you don't know.

        Here is a question:
        {input}
        """


        let math_template = """
        You are a very good mathematician. You are great at answering math questions. \
        You are so good because you are able to break down hard problems into their component parts, \
        answer the component parts, and then put them together to answer the broader question.

        Here is a question:
        {input}
        """
           
        let prompt_infos = [
           [
               "name": "physics",
               "description": "Good for answering questions about physics",
               "prompt_template": physics_template,
           ],
           [
               "name": "math",
               "description": "Good for answering math questions",
               "prompt_template": math_template,
           ]
        ]

        let llm = LMStudio()

        var destination_chains: [String: DefaultChain] = [:]
        for p_info in prompt_infos {
           let name = p_info["name"]!
           let prompt_template = p_info["prompt_template"]!
           let prompt = PromptTemplate(input_variables: ["input"], partial_variable: [:], template: prompt_template)
           let chain = LLMChain(llm: llm, prompt: prompt, parser: StrOutputParser())
           destination_chains[name] = chain
        }
        let default_prompt = PromptTemplate(input_variables: [], partial_variable: [:], template: "")
        let default_chain = LLMChain(llm: llm, prompt: default_prompt, parser: StrOutputParser())

        let destinations = prompt_infos.map{
           "\($0["name"]!): \($0["description"]!)"
        }
        let destinations_str = destinations.joined(separator: "\n")

        let router_template = MultiPromptRouter.formatDestinations(destinations: destinations_str)
        let router_prompt = PromptTemplate(input_variables: ["input"], partial_variable: [:], template: router_template)

        let llmChain = LLMChain(llm: llm, prompt: router_prompt, parser: RouterOutputParser())

        let router_chain = LLMRouterChain(llmChain: llmChain)

        let chain = MultiRouteChain(router_chain: router_chain, destination_chains: destination_chains, default_chain: default_chain)
        Task(priority: .background)  {
            let reply = await chain.run(args: "\(msg)")
           //print("💁🏻‍♂️", )
            DispatchQueue.main.async {
                self.reply = "\(reply)"
                isLoading = false
            }
        }
    }
}

#Preview {
    RouterView()
}
