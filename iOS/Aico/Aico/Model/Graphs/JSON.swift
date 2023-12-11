//
//  Serialize.swift
//  Aico
//
//  Created by Yu Ho Kwok on 15/10/2023.
//

import Foundation

struct JSON {
    static var jsonEncoder = JSONEncoder()
    static var jsonDecoder = JSONDecoder()
    static func serialize(_ input : Encodable) -> String? {
        do {
            let data = try jsonEncoder.encode(input)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    static func deserialize<T : Decodable>(_ type: T, from jsonString : String) -> T? {
        do {
            guard let data = jsonString.data(using: .utf8) else {
                return nil
            }
            return try jsonDecoder.decode(T.self, from: data)
        } catch _ {
            return nil
        }
    }
}
