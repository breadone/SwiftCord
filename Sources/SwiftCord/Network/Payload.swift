//
//  Payload.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
//

import Foundation

internal struct Payload: Codable {
    let op: Int // Opcode
    let d: [String: PacketData]? // Event data
    let s: Int? // Sequence number, used for resuming sessions and heartbeats
    let t: String? // Event name
    
    init(op: Int, d: [String: PacketData]? = nil, s: Int? = nil, t: String? = nil) {
        self.op = op
        self.d = d
        self.s = s
        self.t = t
    }
}

// https://stackoverflow.com/questions/48297263/how-to-use-any-in-codable-type
internal enum PacketData: Codable {
    case int(Int), string(String)
    
    init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }
        
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        
        throw PacketDataError.missingValue
    }
    
    enum PacketDataError: Error {
        case missingValue
    }
}
