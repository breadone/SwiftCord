//
//  File.swift
//  
//
//  Created by Pradyun Setti on 28/12/21.
//

import Foundation

/// Presence object for Discord Bot
public struct SCPresence: JSONEncodable {
    var activities: [String: Any] = [:]
    var status: String
    var afk: Bool
    var since: Int
    
    
    /// Creates a new Presense object
    /// - Parameters:
    ///   - status: What the bot's online/offline etc status is
    ///   - activity: What the bot is "playing"
    ///   - activityType: The type of activity the bot is doing: 0 = Playing, 1 = Streaming, 2 = Listening, 3 = Watching
    init(status: DiscordStatus, activity: String? = nil, activityType: Int = 0) {
        self.status = status.rawValue
        self.afk = false
        self.since = Int(Date().timeIntervalSince1970)
        
        if activity != nil {
            self.activities = [
                "name": activity!,
                "type": activityType
            ]
        }
    }
    
    public func encode() -> String {
        let a: JSONObject = ["status": status, "afk": afk, "since": since, "activities": activities]
        return a.encode()
    }
}

public enum DiscordStatus: String {
    case online = "online"
    case dnd = "dnd"
    case idle = "idle"
    case invisible = "invisible"
    case offline = "offline"
}
