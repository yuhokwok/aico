//
//  StartView.swift
//  Aico
//
//  Created by itst on 5/1/24.
//

import SwiftUI
import FirebaseAuth
struct StartView: View {
    
    @State var showMyPlots = false
    
    @State var fileURLs : [URL] = []
    var coordinator = ProjectHostingCoorindator()
    
    
    @State var isLoggedin = false
    
    @State var prompt : String = ""
    
    @StateObject var client = GenerativeClient()
    
    @State private var email: String = "Test@test.com"
    @State private var password: String = "a123456"
    
    @State private var regEmail: String = ""
    @State private var regPassword: String = ""
    
    @State private var loginError: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isLoggedIn: Bool = false
    
    @State private var isShowRegister : Bool = false
    
    @State private var registerError  : String = ""
    
    @State var uid : String = ""
    
    @State private var showRegisterOK = false
    
    var body: some View {
        ZStack {
            
            Image("Bitmap", bundle: .main)
                .resizable()
            //.scaledToFill()
            
            AnimatedMeshView()
            
            VStack {
                
                
                HStack {
                    Image("logo")
                    Text("Aico")
                        .bold()
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                }
                
                HStack {
                    
                    if isShowRegister {
                        
                        
                        VStack {
                            Text("Register").bold()
                            TextField(text: $regEmail, label: {
                                Text("Email")
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
                            
                            SecureField(text: $regPassword, label: {
                                Text("Password")
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

                            Text("\(registerError)").font(.footnote).bold().padding(5)
                        }
                        
                        Button(action: {
                            register()
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
                        
                    } else if isLoggedin {
                        
                        
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
                    } else {
                        
                        
                        VStack {
                            Text("Sign in").bold()
                            TextField(text: $email, label: {
                                Text("Email")
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
                            
                            SecureField(text: $password, label: {
                                Text("Password")
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
                            Text("\(loginError)").font(.footnote).bold().padding(5)
                        }
                        
                        Button(action: {
                            login()
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

                }
                .frame(width: 436, height: isLoggedin ? 106 : 206)
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
                                .frame(width: 430, height: isLoggedin ? 100 : 200)
                        }
                }
                
                
                HStack (spacing: 48) {
                    
                    if isLoggedin {
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
                    } else {
                        if isShowRegister == false {
                            Button(action: {
                                withAnimation {
                                    isShowRegister.toggle()
                                }
                            }, label : {
                                Text("Register For Account")
                            })
                        } else {
                            Button(action: {
                                withAnimation {
                                    isShowRegister.toggle()
                                }
                            }, label : {
                                Text("Back to SignIn")
                            })
                        }

                    }
                    
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
                else if isLoggedin {
                    Button(action: {
                        regEmail = ""
                        regPassword = ""
                        email = ""
                        password = ""
                        
                        logout()
                    }, label: {
                        Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
                            .font(.system(size: 20))
                            .bold()
                    })
                    .foregroundColor(.white)

                }
            }


        }
        .ignoresSafeArea()
        .onAppear(perform: {
            
            
        })
        .onDisappear(perform: {
            
        })
        .alert(isPresented: $showRegisterOK, content: {
            Alert(title: Text("Register Success"), dismissButton: .default(Text("OK")))
        })
    }
        
    func register() {
        Auth.auth().createUser(withEmail: regEmail, password: regPassword) { (authResult, error) in
            if let error = error {
                registerError = error.localizedDescription
                return
            }
            
            guard let user = authResult?.user else {
                return
            }
            
            withAnimation {
                isShowRegister.toggle()
            }
            showRegisterOK = true
        }
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
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                loginError = error.localizedDescription
            } else {
                password = ""
                uid = authResult?.user.uid ?? ""
                
                loadFolder(uid: uid)
                
                withAnimation {
                    isLoggedin.toggle()
                }
            }
        }
    }
    
    func loadFolder(uid : String) {
        print("load folder for \(uid)")
        AppFolderManager.requestProjectsFolderListing(uid: uid, completion: {
            urls in
            self.fileURLs = urls
        })
    }
    
    func logout() {
        try? Auth.auth().signOut()
        withAnimation {
            isLoggedin.toggle()
        }
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
        
        guard let url = url, let docFolder = docFolder else {
            return
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
