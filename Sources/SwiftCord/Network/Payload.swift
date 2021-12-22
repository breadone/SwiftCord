//
//  Payload.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
//

import Foundation

struct Payload: Codable {
    let op: Int // Opcode
    let d: [String: Any]? // Event data
    let s: Int? // Sequence number, used for resuming sessions and heartbeats
    let t: String? // Event name
}
