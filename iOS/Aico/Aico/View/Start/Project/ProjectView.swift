//
//  ProjectView.swift
//  Aico
//
//  Created by itst on 8/10/2023.
//

import SwiftUI

protocol ProjectHostingDelegate {
    func projectHostingDidRequestPresentDocument(with url: URL, precreate : GeneratedProject?)
}

class ProjectHostingCoorindator {
    var delegate : ProjectHostingDelegate?
}

struct ProjectView: View {
    
    @State var fileURLs : [URL] = []
    var coordinator = ProjectHostingCoorindator()
    
    var body: some View {
        VStack {
            Spacer().frame(height: 24)
            HStack {
                Text("Aico (Technical Preview)")
                Spacer()
                Button(action: {
                    
                    createNewBlankProject()

                }, label: {
                    Text("New Project")
                })
            }
            .padding([.top], 20)
            .padding()
            
            Text("開發者訊息： 呢本版本創作出嚟嘅檔案喺之後開唔返，請注意。")
            
            List {
                ForEach(0..<fileURLs.count, id:\.self) {
                    i in
                    
                    Button(action: {
                        print("\(i) selected")
                        coordinator.delegate?.projectHostingDidRequestPresentDocument(with: fileURLs[i], precreate : nil)
                        
                    }, label: {
                        HStack {
                            Text("\(projectName(url: fileURLs[i]))")
                            Spacer()
                        }
                    })
                    
                    
                }
                .onDelete(perform: { indexSet in
                    delete(at: indexSet)
                })
                
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
    ProjectView()
}
