//
//  coaiproject.swift
//  CoAI
//
//  Created by CoAI Team on 18/10/2023.
//

import UIKit

@Observable
class CoAIProject : UIDocument {
    
    var encoder = JSONEncoder()
    var decoder = JSONDecoder()
    
    var fileWrapper = FileWrapper(directoryWithFileWrappers:[:])
    
    var project : Project {
        didSet {
            print("set to another project")
        }
    }
    
    override init(fileURL url: URL) {
        print("\(#function)")
        print("\(url.absoluteString)")
        self.project = Project.new()
        super.init(fileURL: url)
    }
    
    //MARK: - function required by UIDocument for load and save
    //this function will be invoked if you call "save" function
    var testObject : DummyObject?
    override func contents(forType typeName: String) throws -> Any {
        print("\(#function)")
        
        //load information here, if no, create new information
        print("type:\(typeName)")
        let testObjectWrapper = encodeToWrapper(object: testObject!)
        let wrappers : [String : FileWrapper] = ["testObject.data" : testObjectWrapper!]
        
        return FileWrapper(directoryWithFileWrappers: wrappers)
    }
    
    
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
        print("\(#function)")
        if let fileWrapper = contents as? FileWrapper {
            print("file wrapper: \(fileWrapper)")
            self.fileWrapper = fileWrapper
            if let item = fileWrapper.fileWrappers?["contents.plist"] {
                if let fileContents = item.regularFileContents {
                    if let dictionary = try? PropertyListSerialization.propertyList(from: fileContents, options: [], format: nil) as? NSDictionary {
                        print(dictionary)
                    }
                }
            }
            
            //load keynote
            self.project = self.load()
        }
        
    }
    
    override var savingFileType: String? {
        return "com.417tech.app.CoAI.project"
    }
    
    override func close(completionHandler: ((Bool) -> Void)? = nil) {
        self.save()
        super.close(completionHandler: completionHandler)
    }
    
    func save() {
        guard let data = try? encoder.encode(self.project) else {
            fatalError("can't save keynote")
        }
        
        let url = self.fileURL
        let fileURL = url.appendingPathComponent("project.coaiproject.coaijson")
        
        do {
            print("save at :\(url.absoluteString)")
            try data.write(to: fileURL, options: .atomic)
        } catch _ {
            fatalError("can't save keynote")
        }
    }
    
    func saveThumbnail(image : UIImage?, for identifier : String) -> URL? {
        guard let image = image else {
            return nil
        }
        let url = self.fileURL
        let fileURL = url.appendingPathComponent("thumbnail-\(identifier).png")
        guard let data = image.pngData() else {
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
    
    func thumbnail(for identifier : String ) -> UIImage? {
        let url = self.fileURL
        let fileURL = url.appendingPathComponent("thumbnail-\(identifier).png")
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        return UIImage(data: data)
    }
    
    func saveThumbnail(image : UIImage?) {
        guard let image = image else {
            return
        }
        let url = self.fileURL
        let fileURL = url.appendingPathComponent("thumbnail.png")
        guard let data = image.pngData() else {
            return
        }
        try? data.write(to: fileURL)
    }
    

    
    func load() -> Project {
        let project : Project
        let url = self.fileURL
        let fileURL = url.appendingPathComponent("project.coaiproject.coaijson")
        guard let data = try? Data(contentsOf: fileURL) else {
            project = self.new()
            return project
        }
        guard let pj = try? decoder.decode(Project.self, from: data) else {
            project = self.new()
            return project
        }
        project = pj
        return project
    }
    
    func new() -> Project {
        let project = Project.new()
        return project
    }
    
    func encodeToWrapper<T: Encodable>(object : T) -> FileWrapper? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(object) else {
            return nil
        }
        return FileWrapper(regularFileWithContents: data)
    }
    
    //MARK: - Error handling
    override func handleError(_ error: Error, userInteractionPermitted: Bool) {
        print("\(#function)")
        print(error)
        super.handleError(error, userInteractionPermitted: userInteractionPermitted)
    }
    
    override func finishedHandlingError(_ error: Error, recovered: Bool) {
        print("\(#function)")
        print(error)
        super.finishedHandlingError(error, recovered: recovered)
    }
    
    override func userInteractionNoLongerPermitted(forError error: Error) {
        print("\(#function)")
        print(error)
        super.userInteractionNoLongerPermitted(forError: error)
    }
    
    var projectName : String {
        return self.fileURL.lastPathComponent.replacingOccurrences(of: ".coaiproj", with: "")
    }
}

class DummyObject : Codable {
    var data : String
    init(data : String){
        self.data = data
    }
}
