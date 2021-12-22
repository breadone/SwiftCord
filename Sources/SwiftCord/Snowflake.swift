//
//  Snowflake.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
//

import Foundation
fileprivate let DISCORD_EPOCH = Date(timeIntervalSince1970: 1420070400000) // defined as the first second of 2015

struct Snowflake: Codable {
    let id: UInt64
    var idString: String {
        "\(self.id)"
    }
    
    internal init(string: String) {
        self.id = UInt64(string) ?? 0
    }
    
    internal init(uint64: UInt64) {
        self.id = uint64
    }
    
    internal init(date: Date) {
        self.id = UInt64(DISCORD_EPOCH.distance(to: date)) << 22
    }
    
}
