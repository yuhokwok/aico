//
//  ContentView.swift
//  LangChainApp
//
//  Created by Yu Ho Kwok on 5/3/2025.
//

import SwiftUI
import LangChain

struct ContentView: View {
    
    var body: some View {
        
        TabView {
            AskWikiView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Ask Wiki")
                }
            
            LinuxSimView()
                .tabItem {
                    Image(systemName: "apple.terminal")
                    Text("Linux Sim")
                }
            
            RouterView()
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Router")
                }
            
            AgentView()
                .tabItem{
                    Image(systemName: "hat.widebrim.fill")
                    Text("Agent")
                }
        }
        .onAppear {
            //set the lmstudio path
            LC.initSet([
                "OLLAMA_URL" : "localhost:11434",
                "OLLAMA_MODEL" : "deepseek-r1:8b",
                "LMSTUDIO_URL" : "localhost:1234",
                "OPENWEATHER_API_KEY" : "31538fe27dd36887159b09eb67838b37"
            ])
            
            

        }
    }
}

#Preview {
    ContentView()
}
