//
//  StartupView.swift
//  CoAI
//
//  Created by Yu Ho Kwok on 10/8/24.
//

import SwiftUI
import Combine

struct StartupView: View {
    var namespace : Namespace.ID
    
    @State var showMyPlots = false
    @State var fileURLs : [(URL, Date)] = []
    
    @State var prompt : String = ""
    //@StateObject var client = GenerativeClient()
    @StateObject var client = DeepSeekAPI()
    @State var uid : String = ""
    
    @Binding var isExpanded : Bool
    var fileSelectedHandler : ((URL, GeneratedProject?) -> ())
    
    var gridItemLayout = [GridItem(.adaptive(minimum: 270, maximum: 280),spacing: 25, alignment: .center)]
    
    var body: some View {
        VStack {
            
            if showMyPlots {
                Spacer().frame(height: 30)
                    .transition(.scale)
            }
            
            HStack {
                Image("logo")
            }
            .transition(.scale)
            
            ZStack {
                
                
                ZStack {
                    
                    PlaceHolderView()
                    
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
                        .onReceive(NotificationCenter.default.publisher(for: .speechForStartup), perform: {
                            output in
                            
                            if let speechMessage = output.object as? SpeechMessage {
                                self.prompt = speechMessage.message
                            }
                        })
                        
                        Button(action: {
                            generate(prompt: prompt)
                        }, label: {
                            
                            Image("magic.arrow")
                                .offset(y: 2)
                        })
                        .frame(width: 72, height: 72)
                        .background(LinearGradient(colors: [Color(hex: "#4CCDFF"), Color(hex: "#259EFF")], startPoint: UnitPoint(x: 0.5, y: 0), endPoint: UnitPoint(x: 0.5, y: 1.0)))
                        .clipShape(Circle())
                        .shadow(color: Color(hex: "#259EFF").opacity(0.4 ), radius: 24)
                        .shadow(color: Color(hex: "#25C3FF").opacity(0.66 ), radius: 5)
                        .overlay {
                            
                            Circle().fill(.clear).stroke(.white, lineWidth: 2)
                            
                        }
                        .opacity(prompt.count == 0 || client.loading ? 0.5 : 1.0)
                        .grayscale( (prompt.count == 0 || client.loading) ? 0.5 : 0.0)
                        .animation(.default, value: prompt.count)
                        .animation(.default, value: client.loading)
                        .disabled(prompt.count == 0 || client.loading)
                        .padding()
                        .matchedGeometryEffect(id: "theButton", in: namespace)
                        
                    }
                }
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .contentShape(Rectangle())
                .shadow(color: Color(hex: "#A8CBE7").opacity(0.33), radius: 10, y: 4)
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(.clear)
                        .strokeBorder(LinearGradient(colors: [Color(hex: "#8EB6FF"), Color(hex: "#787EFF"),
                                                              Color(hex: "#FF89D7"), Color(hex: "#FFD589")],
                                                     startPoint: UnitPoint(x: -0.2, y: -0.2),
                                                     endPoint: UnitPoint(x: 1.2, y: 1.2)), lineWidth: 1)
                }
                .padding(5)
                
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(.white.opacity(0.7), lineWidth: 5)
                
            }
            .matchedGeometryEffect(id: "TheBox", in: namespace)
            .frame(width: 436, height: 106)
            
            
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
            .padding(.top, 30)
            .padding(.bottom, 20)
            .shadow(radius: 5)
            
            if showMyPlots {
                ScrollView {
                    Spacer().frame(height: 20)
                    LazyVGrid (columns: gridItemLayout)  {
                        ForEach(0..<fileURLs.count, id:\.self) {
                            i in
                            
                            HStack {

                                Button(action: {
                                    print("\(i) selected")
                                    fileSelectedHandler(fileURLs[i].0, nil)
                                }, label: {
                                    HStack {
                                        Spacer().frame(width: 5)
                                        Image("logo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80)
                                        
                                        Spacer().frame(width: 5)
                                        VStack (alignment: .leading) {
                                            Text("\(projectName(url: fileURLs[i].0))")
                                                .font(.system(size: 16).weight(.semibold))
                                                .foregroundStyle(Color(hex: "#00296B"))
                                            
                                            
                                            Text("\(formattedDateString(date: fileURLs[i].1))")
                                                .font(.system(size: 12))
                                                .foregroundStyle(.gray)
                                        }
                                        Spacer()
                                    }
                                })
                            }
                            .transition(.scale)
                            .frame(width: 280, height: 100)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .padding(5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 28)
                                    .strokeBorder(.white.opacity(0.5), lineWidth: 5)
                            }
                            .shadow(color: Color(hex: "#A8CBE7").opacity(0.33), radius: 10, y: 4)
                            .padding(.vertical, 10)
                            
                        }
                        .onDelete(perform: { indexSet in
                            delete(at: indexSet)
                        })
                        .transition(.scale)
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 30)
                }
                .scrollIndicators(.hidden)
                .transition(.move(edge: .bottom))
            }
            
        }
        .onAppear(perform: {
            self.loadFolder(uid: "")
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
            let url = fileURLs[index].0
            let isDelete = deleteFile(at: url)
            if isDelete {
                let _ = fileURLs.remove(at: index)
            }
        }
        
    }
    
    func projectName(url : URL) -> String{
        return url.lastPathComponent.replacingOccurrences(of: ".coaiproj", with: "")
    }
    
    func createNewBlankProject( _ gp : GeneratedProject? = nil) {
        let url  = Bundle.main.url(forResource: "Blank", withExtension: "coaiproj")
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
        if templateFileName == "Blank.coaiproj" {
            let name = gp?.projectName ?? "My Project"
            templateFileName = "\(name).coaiproj"
        }
        
        var docUrl = docFolder.appendingPathComponent(templateFileName, isDirectory: false)
        var startIndex = 0
        
        
        print(docUrl.path)
        while FileManager.default.fileExists(atPath: docUrl.path) {
            startIndex += 1
            
            let lastPathComponent = templateFileName
            let fileName : String
            if startIndex == 1 {
                fileName = lastPathComponent.replacingOccurrences(of: ".coaiproj", with: " copy.coaiproj")
            } else {
                fileName = lastPathComponent.replacingOccurrences(of: ".coaiproj", with: " copy \(startIndex).coaiproj")
            }
            docUrl = docFolder.appendingPathComponent(fileName, isDirectory: false)
        }
        
        do {
            try FileManager.default.copyItem(at: url, to: docUrl)
            
            if showMyPlots == false {
                self.fileURLs.insert((docUrl, Date()), at: 0)
                self.fileSelectedHandler(docUrl, gp)
            } else {
                withAnimation {
                    self.fileURLs.insert((docUrl, Date()), at: 0)
                }
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
    
    func formattedDateString(date : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    @Previewable @Namespace var namespace
    StartupView(namespace: namespace, isExpanded: .constant(false), fileSelectedHandler: { _, _  in })
}
