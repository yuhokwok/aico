//
//  ExecuteView.swift
//  Aico
//
//  Created by itst on 1/30/24.
//

import SwiftUI

struct ExecuteView: View {
    
    @State private var showShareSheet = false
    @State private var jsonData: String = ""
    
    @StateObject var runtime : Runtime
    
    @State var isLoading : Bool = false
    @State var topic : String = "討論今日去邊玩"
    @State var allString = "Roy: 我哋今日去邊度玩好？好悶啊。"
    @State var queryString : String = "我哋今日去邊度玩好？好悶啊。"
    @State var saveMessage : String = ""

    var body: some View {
        
        HStack {
            Text("Execute")
                .font(.system(size: 24))
                .bold()
            Spacer()
        }
        .padding()
        
        Text("Press Play to execute the Application")
            .font(.system(size: 12))
        
        HStack {
            Button(action: {
                if runtime.isExecuting  {
                    saveMessage = ""
                    runtime.cancel()
                } else {
                    saveMessage = ""
                    runtime.execute()
                }
            }, label: {
                HStack {
                    Spacer()
                    Image(systemName: runtime.isExecuting ? "stop.fill" : "play.fill")
                    Spacer()
                }
                
            })
            .buttonStyle(.bordered)
            
            Button(action: {
                save()
                saveMessage = "Message Saved"
            }, label: {
                HStack {
                    Image(systemName: "square.and.arrow.down.fill")
                }
                
            })
            .buttonStyle(.bordered)
            
            Button(action: {
                export()
            }, label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                }
                
            })
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 20)
        
        if runtime.isExecuting {
            ProgressView()
                .progressViewStyle(.circular)
        }
        
        ScrollViewReader { scrollProxy in
            ScrollView {
                
                VStack (alignment: .leading) {
                    ForEach(runtime.records) {
                        record in
                        
                        ExecuteRecordCell(record: record, thumbnail: runtime.image(for: record.speakerId))
                            .id(record.id)
                    }
                }
            }
            .onChange(of: runtime.records) { _, _ in
                
                if let lastIndex = runtime.records.last {
                    withAnimation {
                        scrollProxy.scrollTo(lastIndex.id, anchor: .bottom)
                        //DispatchQueue.main.async {
                        //    position = ScrollPosition(id: lastIndex, anchor: .bottom)
                        //}
                        //                    print("callcallcall")
                        //                    withAnimation {
                        //                        scrollProxy.scrollTo(lastIndex, anchor: .bottom)
                        //                        //scrollProxy.scrollTo(lastIndex, anchor: .bottom)
                        //                    }
                    }
                }
            }
        }
        .onAppear {
            let pjData = UserDefaults.standard.string(forKey: runtime.project.identifier)
            if let data = pjData?.data(using: .utf8) {
                if let records = try? JSONDecoder().decode([Record].self, from: data) {
                    runtime.records = records
                }
            }
        }
        .onDisappear {
            print("cancel runtime")
            runtime.cancel()
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [jsonData])
        }
    }
    
    func export() {
        guard let data = try? JSONEncoder().encode(runtime.records) else { return }
        guard let string = String(data: data, encoding: .utf8) else { return }
        self.jsonData = string
        showShareSheet = true
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(runtime.records) else { return }
        guard let string = String(data: data, encoding: .utf8) else { return }
        UserDefaults.standard.set(string, forKey: runtime.project.identifier)
        UserDefaults.standard.synchronize()
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
        .frame(width: 450)
}
