//
//  File.swift
//  
//
//  Created by Pradyun Setti on 28/12/21.
//

import Foundation

/// Presence object for Discord Bot
public struct SCPresence {
    var activities: [String: Any] = [:]
    var status: String
    var afk: Bool
    var since: Int
    
    public var arrayRepresentation: JSONObject {
        return ["status": status, "afk": afk, "since": since, "activities": activities]
    }
    
    /// Creates a new Presense object
    /// - Parameters:
    ///   - status: What the bot's online/offline etc status is
    ///   - activity: What the bot is doing
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
}

public enum DiscordStatus: String {
    case online = "online"
    case dnd = "dnd"
    case idle = "idle"
    case invisible = "invisible"
    case offline = "offline"
}
