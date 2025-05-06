//
//  ImagePlaygroundAPI.swift
//  Aico
//
//  Created by Yu Ho Kwok on 5/5/2025.
//

import Foundation
import ImagePlayground
import CoreImage
import SwiftUI

class ImagePlaygroundAPI : ObservableObject {
    //@Published var preduction :
    
    @Published var loading = false
    func genThumbnail(prompt: String, completion : ((UIImage?) -> (Void))?) {
        loading = true
        Task {
            var generatedImage : CGImage? = nil
            let finalPrompt = "a single person, close up, japanese anime style, role: \(prompt)"
            do {
                let creator = try await ImageCreator()
                
                let images = creator.images(for: [
                    ImagePlaygroundConcept.extracted(from: prompt)
                ], style: .animation, limit: 1)
                
                for try await image in images {
                    generatedImage = image.cgImage
                }
                
                var image : UIImage? = nil
                if let theImage = generatedImage {
                    image = UIImage(cgImage: theImage)
                }

                DispatchQueue.main.async {
                    completion?(image)
                    self.loading = false
                }
                
            } catch {
                print("\(error.localizedDescription)")
                
                DispatchQueue.main.async {
                    completion?(nil)
                    self.loading = false
                }
            }
            
        }
    }
}
