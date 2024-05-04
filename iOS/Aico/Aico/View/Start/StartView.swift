//
//  StartView.swift
//  Aico
//
//  Created by Yu Ho Kwok on 5/1/24.
//

import SwiftUI

struct StartView: View {
    
    @State var showMyPlots = false
    
    @State var fileURLs : [URL] = []
    var coordinator = ProjectHostingCoorindator()
    
    
    @State var prompt : String = ""
    
    var body: some View {
        ZStack {
            
            Image("Bitmap", bundle: .main)
                .resizable()
            //.scaledToFill()
            
            VStack {
                
                
                HStack {
                    Image("logo")
                    Text("Aico")
                        .bold()
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                }
                
                HStack {
                    TextField(text: $prompt, label: {
                        Text("Enter Your Idea")
                    })
                    .padding()
                    .padding(.horizontal, 20)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .stroke(.gray.opacity(0.4), lineWidth: 1)
                            .frame(width: 290, height: 56)
                    }
                    .padding(.leading, 20)
                    
                    Button(action: {}, label: {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 40))
                    })
                    .tint(.white)
                    .frame(width: 72, height: 72)
                    .background(.blue)
                    .clipShape(Circle())
                    .shadow(color: .blue, radius: 10)
                    .overlay {
                        Circle().fill(.clear).stroke(.white, lineWidth: 2)
                    }
                    .padding()
                }
                .frame(width: 436, height: 106)
                .background {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.white)
                        .stroke(.white.opacity(0.3), lineWidth: 5)
                        .shadow(radius: 10)
                        .opacity(0.8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.clear)
                                .stroke(.purple, lineWidth: 1)
                                .frame(width: 430, height: 100)
                        }
                }
                
                
                HStack (spacing: 48) {
                    
                    Button(action: {
                        withAnimation {
                            showMyPlots.toggle()
                        }
                    }, label : {
                        Text("My plots")
                    })
                    
                    
                    
                    Text("I' am feeling lucky")
                    
                    Button(action: {
                        createNewBlankProject()
                    }, label: {
                        Text("Blank plot")
                    })
                    .tint(.white)
                    
                }
                .bold()
                .foregroundStyle(.white)
                .padding(.vertical, 50)
                .shadow(radius: 5)
                
                if showMyPlots {
                    ScrollView {
                        VStack(alignment: .center, spacing: 20) {
                            Spacer().frame(height: 10)
                            ForEach(0..<fileURLs.count, id:\.self) {
                                i in
                                
                                HStack {
                                    Button(action: {
                                        print("\(i) selected")
                                        coordinator.delegate?.projectHostingDidRequestPresentDocument(with: fileURLs[i])
                                        
                                    }, label: {
                                        HStack {
                                            Spacer()
                                            Text("\(projectName(url: fileURLs[i]))")
                                                .font(.system(size: 24))
                                                .bold()
                                            Spacer()
                                        }
                                    })
                                }
                                .transition(.scale)
                                .frame(width: 436, height: 106)
                                .background {
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(.white)
                                        .stroke(.white.opacity(0.3), lineWidth: 5)
                                        .shadow(radius: 10)
                                        .opacity(0.8)
                                }
                                
                                
                            }
                            .onDelete(perform: { indexSet in
                                delete(at: indexSet)
                            })
                            .transition(.scale)
                            Spacer().frame(height: 50)
                        }
                        .frame(width: 550)
                    }
                    .scrollIndicators(.hidden)
                    .transition(.move(edge: .bottom))
                }
            }

        }
        .ignoresSafeArea()
        .onAppear(perform: {
            
            AppFolderManager.requestProjectsFolderListing(completion: {
                urls in
                self.fileURLs = urls
            })
        })
        .onDisappear(perform: {
            
        })
    }
    
    func generate() {
        
    }
    
    func randomGenerate() {
        
    }
    
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let url = fileURLs[index]
            let isDelete = deleteFile(at: url)
            if isDelete {
                let _ = fileURLs.remove(at: index)
            }
        }
        
    }
    
    func projectName(url : URL) -> String{
        return url.lastPathComponent.replacingOccurrences(of: ".aicoproj", with: "")
    }
    
    func createNewBlankProject() {
        let url  = Bundle.main.url(forResource: "Blank", withExtension: "aicoproj")
        let docFolder = AppFolderManager.projectsFolder()
        
        guard let url = url, let docFolder = docFolder else {
            return
        }
        
        
        var templateFileName = url.lastPathComponent
        if templateFileName == "Blank.aicoproj" {
            templateFileName = "My Project.aicoproj"
        }
        
        var docUrl = docFolder.appendingPathComponent(templateFileName, isDirectory: false)
        var startIndex = 0
        
    
        print(docUrl.path)
        while FileManager.default.fileExists(atPath: docUrl.path) {
            startIndex += 1
            
            let lastPathComponent = templateFileName
            let fileName : String
            if startIndex == 1 {
                fileName = lastPathComponent.replacingOccurrences(of: ".aicoproj", with: " copy.aicoproj")
            } else {
                fileName = lastPathComponent.replacingOccurrences(of: ".aicoproj", with: " copy \(startIndex).aicoproj")
            }
            docUrl = docFolder.appendingPathComponent(fileName, isDirectory: false)
        }
        
        do {
            try FileManager.default.copyItem(at: url, to: docUrl)
            
            withAnimation {
                self.fileURLs.insert(docUrl, at: 0)
            }
            
            if showMyPlots == false {
                coordinator.delegate?.projectHostingDidRequestPresentDocument(with: docUrl)
            }
            
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    
    func deleteFile(at url: URL) -> Bool {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            print("Error deleting file: \(error)")
            return false
        }
    }
    
}

#Preview {
    StartView()
}
