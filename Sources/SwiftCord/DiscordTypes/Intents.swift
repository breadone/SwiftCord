//
//  Intents.swift
//  
//
//  Created by Pradyun Setti on 10/08/22.
//

import Foundation


public enum DiscordIntents: Int {
    /// - GUILD_CREATE
    /// - GUILD_UPDATE
    /// - GUILD_DELETE
    /// - GUILD_ROLE_CREATE
    /// - GUILD_ROLE_UPDATE
    /// - GUILD_ROLE_DELETE
    /// - CHANNEL_CREATE
    /// - CHANNEL_UPDATE
    /// - CHANNEL_DELETE
    /// - CHANNEL_PINS_UPDATE
    /// - THREAD_CREATE
    /// - THREAD_UPDATE
    /// - THREAD_DELETE
    /// - THREAD_LIST_SYNC
    /// - THREAD_MEMBER_UPDATE
    /// - THREAD_MEMBERS_UPDATE
    /// - STAGE_INSTANCE_CREATE
    /// - STAGE_INSTANCE_UPDATE
    /// - STAGE_INSTANCE_DELETE
    case guilds = 1
    
    /// - GUILD_MEMBER_ADD
    /// - GUILD_MEMBER_UPDATE
    /// - GUILD_MEMBER_REMOVE
    /// - THREAD_MEMBERS_UPDATE
    case guildMembers = 2
    
    /// - GUILD_BAN_ADD
    /// - GUILD_BAN_REMOVE
    case guildBans = 4
    case guildEmojisAndStickers = 8
    case guildIntegrations = 16
    case guildWebhooks = 32
    case guildInvites = 64
    case guildVoiceStates = 128
    case guildPresences = 256
    case guildMessages = 512
    case guildMessageReactions = 1024
    case guildMessageTyping = 2048
    case directMessages = 4096
    case dmReactions = 8192
    case dmTyping = 16384
    case messageContent = 32768
    
    case guildScheduledEvents = 65536
    case automodConfiguration = 1048576
    case automodExectution = 2097152
    
    /// FOR TESTING, YOU SHOULD NOT USE THIS
    case all = 3276799
}

extension Array where Element == DiscordIntents {
    func sum() -> Int {
        var c = 0
        self.forEach { c += $0.rawValue }
        return c
    }
}
