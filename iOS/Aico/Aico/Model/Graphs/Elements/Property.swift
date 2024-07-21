//
//  Property.swift
//  Aico
//
//  Created by itst on 12/10/23.
//

import Foundation


/// A small storage that can store primative types
struct Property : Codable, Identifiable {
    var id : String
    private var dictionary : [String : String] = [:]
    
    mutating func set(value : Any, for key : String) -> Bool {
        guard value is String || value is Bool || value is Date || value is Int || value is Double else {
            return false
        }
        self.dictionary[key] = "\(value)"
        return true
    }
    
    func string(for key : String, defaultValue : String = "") -> String {
        if let string = dictionary[key] {
            return string
        }
        return defaultValue
    }
    
    func bool(for key : String, defaultValue : Bool = false) -> Bool {
        if let string = dictionary[key], let boolValue = Bool(string) {
            return boolValue
        }
        return defaultValue
    }
    
    func integer(for key : String, defaultValue : Int = 0) -> Int {
        if let string = dictionary[key], let intValue = Int(string) {
            return intValue
        }
        return defaultValue
    }
    
    func double(for key : String, defaultValue : Double = 0.0) -> Double {
        if let string = dictionary[key], let doubleValue = Double(string) {
            return doubleValue
        }
        return defaultValue
    }
    
    //TODO: Date
    func date(for key : String) -> Date? {
        return nil
    }
    
    static var new : Property {
        let property = Property(id: UUID().uuidString)
        return property
    }
}
