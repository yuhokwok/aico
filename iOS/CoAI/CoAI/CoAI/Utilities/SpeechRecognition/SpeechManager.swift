//
//  SpeechManager.swift
//  Geddy
//
//  Created by Yu Ho Kwok on 10/2/24.
//

import Foundation
import Speech
import AVFoundation
import Combine

class SpeechManager: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-HK"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published var recognizedText: String = ""
    @Published var isProcessing: Bool = false

    
    
    func startRecording(resultHandler: @escaping (SFSpeechRecognitionResult?, (any Error)?)->Void) throws {
        // Cancel existing recognition task (if any)
        recognitionTask?.cancel()
        self.recognitionTask = nil
        self.recognizedText = ""
        self.isProcessing = true

        // Prepare audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.unableToCreateRequest
        }
        recognitionRequest.shouldReportPartialResults = true

        // Setup audio input
        let inputNode = audioEngine.inputNode
        recognitionRequest.requiresOnDeviceRecognition = false
        recognitionRequest.addsPunctuation = true

        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            
            resultHandler(result, error)
            
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
            }
        }

        // Configure input node
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
            self.recognitionRequest?.append(buffer)
        }

        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
    }

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isProcessing = false
        
        // Prepare audio session
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playback, options: [.mixWithOthers])
        try? audioSession.setActive(true)
    }

    enum SpeechError: Error {
        case unableToCreateRequest
    }
}
