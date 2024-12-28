//
//  ContentView.swift
//  CoAI
//
//  Created by Yu Ho Kwok on 10/8/24.
//

import SwiftUI
import Speech
import Combine

struct SpeechMessage {
    var message : String
    var isFinal : Bool
}

struct ContentView: View {
    
    @Namespace private var viewAnimation
    
    @State var isExpanded : Bool = false
    
    @State var fileURL : URL? = nil
    @State var generatedProject : GeneratedProject?  = nil
    
    @StateObject private var speechManager = SpeechManager()
    @State private var isPressing = false
    
    @State private var speechText = ""

    var body: some View {
        ZStack {
            
            ZStack {
                
                AnimatedMeshView()
                    .scaleEffect(x: 1.2, y: 1.2)
                
                VStack {
                    if let fileURL = fileURL {
                        MainEditorView(namespace: viewAnimation, handler: getDocumentHandler(from: fileURL), backAction: {
                            withAnimation {
                                self.fileURL = nil
                                self.generatedProject = nil
                            }
                            //withAnimation(.easeInOut, { self.fileURL = nil })
                        })
                        .padding(20)
                    } else {
                        StartupView(namespace: viewAnimation, isExpanded: $isExpanded, fileSelectedHandler: {
                            url, generatedProject in
                            withAnimation {
                                self.fileURL = url
                                self.generatedProject = generatedProject
                            }
                            //withAnimation(.bouncy(duration: 0.4, extraBounce: 0.3), { self.fileURL = url })
                        })
                    }
                }

            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack (alignment: .bottomTrailing) {
                        
                        VStack {
                            
                            ScrollView {
                                
                                HStack {
                                    Text(speechText)
                                        .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .multilineTextAlignment(.leading)
                                        .font(.system(size: 22).weight(.semibold))
                                        .padding(25)
                                    Spacer()
                                }
                                    
                            }
                            .frame(width: 400)
                                
                        }
                        .frame(width: 400, height: 250)
                        .background(
                            ZStack {
                                Rectangle().fill(Material.ultraThinMaterial)
                                Rectangle().fill(LinearGradient(colors: [.white, .white.opacity(0.0)],
                                                             startPoint: UnitPoint(x: -0.2, y: -0.2),
                                                             endPoint: UnitPoint(x: 1, y: 1)))
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .padding(5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 28).strokeBorder(.white.opacity(0.45), lineWidth: 5)
                        }
                        .shadow(color: Color(hex: "#A8CBE7").opacity(0.6), radius: 30)
                        .scaleEffect((isPressing && speechText.count > 0) ? CGSize(width: 1, height: 1) : .zero, anchor: UnitPoint(x: 1, y: 1))
                        .animation(.default, value: speechText.count)
                        .animation(.default, value: isPressing)
                        .offset(x: -50, y: -50)
                        
                        TouchDownView(callback: {
                            state in
                            switch state {
                            case .began:
                                
                                self.speechText = ""
                                
                                if !isPressing {
                                    isPressing = true
                                    startRecording()
                                }
                            case .ended:
                                isPressing = false
                                stopRecording()
                            default:
                                noFunc()
                            }
                        })
                        .frame(width: 60, height: 60)
                        .padding(20)
                        .background(
                            ZStack {
                                Circle().fill(Material.ultraThinMaterial)
                                Circle().fill(LinearGradient(colors: [.white, .white.opacity(0.0)],
                                                             startPoint: UnitPoint(x: -0.2, y: -0.2),
                                                             endPoint: UnitPoint(x: 1, y: 1)))
                            }
                        )
                        .padding(5)
                        .overlay {
                            Circle().strokeBorder(.white.opacity(0.45), lineWidth: 5)
                        }
                        .clipShape(Circle())
                        .shadow(color: Color(hex: "#A8CBE7").opacity(0.6), radius: 30)
                        .scaleEffect(isPressing ? CGSize(width: 1.15, height: 1.15) : CGSize(width: 1, height: 1))
                        .animation(.bouncy(duration: 0.4, extraBounce: 0.4), value: isPressing)
                    }
                    .padding(15)
                }
                
        }
        }
        .ignoresSafeArea()
        .onAppear {
            requestSpeechAuthorization()
        }
    }
    
    func getDocumentHandler(from url :  URL) -> DocumentHandler {
        let doc = CoAIProject(fileURL: url)
        let handler = DocumentHandler(document: doc, generatedProject: generatedProject)
        return handler
    }
    
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Handle authorization status if needed
        }
    }
    
    func startRecording() {
        print("start")
        do {
            try speechManager.startRecording(resultHandler: {
                result, error in
                
                if let result = result {
                    DispatchQueue.main.async {
                        
                        print("\(result.bestTranscription.formattedString)")
                        //self.promptMsg = result.bestTranscription.formattedString
                        
                        //if result.isFinal {
                        //    prompt()
                        //}
                        
                        self.speechText = result.bestTranscription.formattedString
                        
                        let msg = SpeechMessage(message: result.bestTranscription.formattedString, isFinal: result.isFinal)
                        if fileURL == nil {
                            NotificationCenter.default.post(name: .speechForStartup, object: msg)
                        } else {
                            NotificationCenter.default.post(name: .speechForEditor, object: msg)
                        }
                    }
                }
                
            })
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        print("stop")
        speechManager.stopRecording()
    }
    
    func noFunc(){
        
    }
    
}

extension Notification.Name {
    static let speechForStartup = Notification.Name("speechForStartup")
    static let speechForEditor = Notification.Name("speechForEditor")
}

#Preview {
    ContentView()
}
