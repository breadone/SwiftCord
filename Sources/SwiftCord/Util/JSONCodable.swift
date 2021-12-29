//
//  JSONCodable.swift
//  
//
//  Created by Pradyun Setti on 24/12/21.
//

import Foundation

public typealias JSONObject = [String: Any]

extension String {
    
    /// Decodes a JSON String to an dictionary or array
    func decode() -> Any {
        let data = try? JSONSerialization.jsonObject(with: self.data(using: .utf8)!, options: .fragmentsAllowed)
        
        if let dict = data as? [String: Any] {
            return dict
        }
        
        if let array = data as? [Any] {
            return array
        }
        
        return data!
    }
}

extension Dictionary: JSONEncodable {}
extension Array: JSONEncodable {}

public protocol JSONEncodable {
    func encode() -> String
}

extension JSONEncodable {
    public func encode() -> String {
        let data = try? JSONSerialization.data(withJSONObject: self, options: [])
        return String(data: data!, encoding: .utf8)!
    }
}

