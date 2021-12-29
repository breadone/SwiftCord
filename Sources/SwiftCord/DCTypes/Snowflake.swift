//
//  Snowflake.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
//

import Foundation
fileprivate let DISCORD_EPOCH = Date(timeIntervalSince1970: 1420070400000) // defined as the first second of 2015

/// Discord's UUID System
public struct Snowflake: Codable {
    /// The ID of the snowflake
    let id: UInt64
    
    /// A string representation of the ID
    var idString: String {
        "\(self.id)"
    }
    
    /// Makes a new Snowflake from a string representation of its ID
    internal init(string: String) {
        self.id = UInt64(string) ?? 0
    }
    
    /// Makes a new Snowflake from its ID
    internal init(uint64: UInt64) {
        self.id = uint64
    }
    
    /// Makes a snowflake from the date of an event
    internal init(date: Date) {
        self.id = UInt64(DISCORD_EPOCH.distance(to: date)) << 22
    }
    
}