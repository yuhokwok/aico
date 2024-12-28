//
//  CaptureFolderManager.swift
//  FBPLand
//
//  Created by Reality Builder Team on 27/4/2022.
//

import Foundation
import UIKit

class AppFolderManager {
    static private let workQueue = DispatchQueue(label: "AppFolderManager.Work", qos: .userInitiated)
    
    
    static func deleteFolder(url : URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    static func requestProjectsFolderListing(uid : String = "", completion : @escaping ([(URL, Date)])->Void){
        workQueue.async {
            guard let docFolder = AppFolderManager.projectsFolder(uid: uid) else {
                completion([])
                return
            }
            
            
            let path = docFolder.absoluteString
            if FileManager.default.fileExists(atPath: path.replacingOccurrences(of: "file:///", with: "/")) == false {
                try? FileManager.default.createDirectory(at: docFolder, withIntermediateDirectories: true)
            }
            
            
            guard let folderListing =
                    try? FileManager.default
                .contentsOfDirectory(at: docFolder,
                                     includingPropertiesForKeys: [.creationDateKey],
                                     options: [ .skipsHiddenFiles ]) else {
                completion([])
                return
            }
            
            // Sort by creation date, newest first.
            let sortedFolderListing = folderListing
                .sorted { lhs, rhs in
                    modifyDate(for: lhs) > modifyDate(for: rhs)
                }
            
            let mappedFolderListing = sortedFolderListing.map( { ($0, modifyDate(for: $0)) })
            
            completion(mappedFolderListing)
        }
        
    }
    

    /// The method returns a URL to the app's documents folder, where it stores all captures.
    static func documentFolder() -> URL? {
        guard let documentsFolder =
                try? FileManager.default.url(for: .documentDirectory,
                                             in: .userDomainMask,
                                             appropriateFor: nil, create: false) else {
            return nil
        }
        return documentsFolder
    }
    
    /// The method returns a URL to the app's documents folder, where it stores all captures.
    static func projectsFolder(uid : String = "") -> URL? {
        guard let documentsFolder =
                try? FileManager.default.url(for: .documentDirectory,
                                             in: .userDomainMask,
                                             appropriateFor: nil, create: true) else {
            return nil
        }
        
        if uid == "" {
            let newURL = documentsFolder.appendingPathComponent("projects/", isDirectory: true)
            try? FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: true)
            
            return documentsFolder.appendingPathComponent("projects/", isDirectory: true)
        } else {
            let newURL = documentsFolder.appendingPathComponent("\(uid)/projects/", isDirectory: true)
            try? FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: true)
            
            return documentsFolder.appendingPathComponent("\(uid)/projects/", isDirectory: true)
        }
        
    }


    
    
    /// Get the modify date of a file
    /// - Parameter url: the url of the file
    /// - Returns: the date of the file modfieid
    private static func modifyDate(for url: URL) -> Date {
        let date = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
        
        if date == nil {
            print("creation data is nil for: \(url.path).")
            return Date.distantPast
        } else {
            return date!
        }
    }
    
    /// Get the creation date of a file
    /// - Parameter url: the url of the file
    /// - Returns: the date of the file created
    private static func creationDate(for url: URL) -> Date {
        let date = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate
        
        if date == nil {
            print("creation data is nil for: \(url.path).")
            return Date.distantPast
        } else {
            return date!
        }
    }
    

    private static func lastModifyDate(for url: URL) -> Date {
        let date = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate
        
        if date == nil {
            print("creation data is nil for: \(url.path).")
            return Date.distantPast
        } else {
            return date!
        }
    }
}
