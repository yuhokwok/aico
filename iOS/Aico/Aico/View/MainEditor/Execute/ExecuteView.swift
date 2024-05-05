//
//  ExecuteView.swift
//  Aico
//
//  Created by Yu Ho Kwok on 1/30/24.
//

import SwiftUI

struct ExecuteView: View {
    
    @StateObject var runtime : Runtime
    
    @State var isLoading : Bool = false
    @State var topic : String = "討論今日去邊玩"
    @State var allString = "Roy: 我哋今日去邊度玩好？好悶啊。"
    @State var queryString : String = "我哋今日去邊度玩好？好悶啊。"
    var body: some View {
        
        TextField(text: $queryString, label: { Text("yoyoyo") })
            .textFieldStyle(.roundedBorder)
            .padding()
        
        
        if runtime.isExecuting {
            ProgressView()
                .progressViewStyle(.circular)
        }
        
        ScrollView {
            
            VStack (alignment: .leading) {
                ForEach(runtime.records) {
                    record in
                    
                    ExecuteRecordCell(record: record)
                }
            }
            
        }
        .onAppear {
            print("yoyoyo")
            //runtime.records.append(Record(speaker: "yo", date: Date(), content: "yoyoyo"))
            
            runtime.execute()
            
        }
    }
    
    func talkToKen(_ msg : String) {
        isLoading = true
        Task {
            if let string = try? await APIService.sharedInstance1.fetch(queryString, to: "Ken") {
                print("\(string)")
                queryString = string.choices[0].message.content
                allString += "\n\nKen: \(string.choices[0].message.content)"
                
                
                
                DispatchQueue.main.async {
                    isLoading = false
                    print("===== wite for timer ========")
                    Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {
                        timer in
                        
                        print("===== talk to roy ========")
                        talkToRoy("\(queryString)。\n按你的對手上述的發言，請繼續談天。")
                        
                    })
                }
            }
        }
    }
    
    func talkToRoy(_ msg:  String) {
        isLoading = true
        Task {
            if let string = try? await APIService.sharedInstance2.fetch(queryString, to: "Ken") {
                print("\(string)")
                queryString = string.choices[0].message.content
                allString += "\n\nRoy: \(string.choices[0].message.content)"
                
                DispatchQueue.main.async {
                    isLoading = false
                    Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: {
                        timer in
                        print("===== wite for timer ========")
                        print("===== talk to ken ========")
                        talkToKen("\(queryString)。\n按你的對手上述的發言，請繼續談天。")
                        
                    })
                }
            }
        }
    }
}

#Preview {
    ExecuteView(runtime: Runtime(project: Project.new()))
}
