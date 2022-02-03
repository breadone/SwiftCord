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
        return ["status": status, "afk": afk, "since": since, "activities": [activities]]
    }
    
    public enum DiscordStatus: String {
        case online = "online"
        case dnd = "dnd"
        case idle = "idle"
        case invisible = "invisible"
        case offline = "offline"
    }
    
    public enum DiscordActivityType: Int {
        case playing = 0
        case streaming = 1
        case listening = 2
        case watching = 3
    }
    
    /// Creates a new Presense object
    /// - Parameters:
    ///   - status: What the bot's online/offline etc status is
    ///   - activity: What the bot is doing
    ///   - activityType: The type of activity the bot is doing
    init(status: DiscordStatus, activity: String? = nil, activityType: DiscordActivityType = .playing) {
        self.status = status.rawValue
        self.afk = false
//        self.since = Int(Date().timeIntervalSince1970)
        self.since = 0
        
        if activity != nil {
            self.activities = [
                "name": activity!,
                "type": activityType.rawValue
            ]
        }
    }
}


