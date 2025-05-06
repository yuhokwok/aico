//
//  StartView.swift
//  Aico
//
//  Created by itst on 5/1/24.
//

import SwiftUI

struct StartView: View {
    
    @State var showMyPlots = false
    @State var fileURLs : [URL] = []
    
    
    var coordinator = ProjectHostingCoorindator()
        
    @State var prompt : String = ""
    @StateObject var client = DeepSeekAPI()
    @State var uid : String = ""

    var body: some View {
        ZStack {
            
            Image("Bitmap", bundle: .main)
                .resizable()
            //.scaledToFill()
            
            AnimatedMeshView()
                .scaleEffect(x: 1.2, y: 1.2)
            
            VStack {
                
                
                HStack {
                    Image("logo")
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
                    .overlay {
                        if client.loading {
                            HStack {
                                Spacer()
                                ProgressView().progressViewStyle(.circular)
                                    .padding(.trailing, 25)
                            }
                        }
                    }
                    .padding(.leading, 20)
                    .onSubmit {
                        generate(prompt: prompt)
                    }
                    
                    Button(action: {
                        generate(prompt: prompt)
                    }, label: {
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
                                .frame(width: 430, height: 100 )
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
                    
                    
                    Button(action: {
                        self.prompt = ""
                        randomGenerate()
                    }, label : {
                        
                        Text("I' am feeling lucky")
                    })
                    
                    
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
                                        coordinator.delegate?.projectHostingDidRequestPresentDocument(with: fileURLs[i], precreate: nil)
                                        
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
            self.loadFolder(uid: "")
        })
        .onDisappear(perform: {
            
        })
    }
        

    func generate(prompt : String) {

        guard client.loading == false else {
            return
        }
        
        print("start generation")
        if prompt.isEmpty == false {
            client.genProject(prompt: prompt, completion: {
                result in
                
                print("\(result)")
                //prompt = result
                
                guard let data = result.data(using: .utf8) else {
                    return
                }
                
                guard let generatedProject = try? JSONDecoder().decode(GeneratedProject.self,
                                                                       from: data ) else {
                    return
                }
                
                self.prompt = ""
                self.createNewBlankProject(generatedProject)
                print("generatedProject: \(generatedProject)")
                
            })
        }
    }
    
    func randomGenerate() {
        self.generate(prompt: "隨便教我做點甚麼")
    }

    
    func loadFolder(uid : String) {
        print("load folder for \(uid)")
        AppFolderManager.requestProjectsFolderListing(uid: uid, completion: {
            urls in
            self.fileURLs = urls
        })
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
    
    func createNewBlankProject( _ gp : GeneratedProject? = nil) {
        let url  = Bundle.main.url(forResource: "Blank", withExtension: "aicoproj")
        let docFolder = AppFolderManager.projectsFolder(uid: uid)
        
        guard var url = url, let docFolder = docFolder,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false)else {
            return
        }
        
        if components.path.hasSuffix("/") {
            // Remove the trailing slash
            components.path = String(components.path.dropLast())
            
            if let newURL = components.url {
                url = newURL
            }
        }

        var templateFileName = url.lastPathComponent
        if templateFileName == "Blank.aicoproj" {
            let name = gp?.projectName ?? "My Project"
            templateFileName = "\(name).aicoproj"
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
                coordinator.delegate?.projectHostingDidRequestPresentDocument(with: docUrl, precreate: gp)
                return
            }
            
            if gp != nil {
                coordinator.delegate?.projectHostingDidRequestPresentDocument(with: docUrl, precreate: gp)
                return
            }
//            
//            if showMyPlots == false && gp == nil  {
//                coordinator.delegate?.projectHostingDidRequestPresentDocument(with: docUrl, precreate: gp)
//            }
            
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
