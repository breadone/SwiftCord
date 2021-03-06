//
//  Payload.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
//

import Foundation

internal struct Payload {
    /// Payload's Opcode
    let op: Int
    
    /// Any event data
    let d: Any?
    
    /// Sequence number, used for resuming sessions and heartbeats
    let s: Int?
    
    /// Event name
    let t: String?
    
    /// Creates a payload with a JSON String
    init(json: String) {
        let data = json.decode() as? [String: Any] ?? [:]
        self.op = data["op"] as? Int ?? -1
        self.d = data["d"] ?? []
        self.s = data["s"] as? Int
        self.t = data["t"] as? String
    }
    
    
    /// Creates a Payload object with a dictionary or array
    /// - Parameters:
    ///   - op: opcode to dispatch
    ///   - d: data to dispatch, either a dictionary or array
    init(opcode op: Opcode, data d: Any = []) {
        self.op = op.rawValue
        self.d = d
        self.s = nil
        self.t = nil
    }
}

extension Payload: JSONEncodable {
    /// Encodes the Payload object to a JSON String
    func encode() -> String {
        var p = ["op": self.op, "d": self.d]
        
        if self.op == 0 {
            p["t"] = self.t
            p["s"] = self.s
        }
        
        return p.encode()
    }
}
