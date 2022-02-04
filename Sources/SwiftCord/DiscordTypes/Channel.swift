//
//  Channel.swift
//  
//
//  Created by Pradyun Setti on 29/12/21.
//

import Foundation

public struct Channel: Codable {
    /// The ID of the channel
    let id: Snowflake
    
    /// The [type of channel](https://discord.com/developers/docs/resources/channel#channel-object-channel-types)
    let type: Int
    
    /// The ID of the guild
    let guildId: Snowflake?
    
    /// Sorting position of the channel
    let position: Int?
    
    /// Name of the channel
    let name: String?
    
    /// Whether the channel is NSFW
    let nsfw: Bool?
    
    /// The recipients of the channel, if it is a DM (type == 1)
    let recipients: [User]

}
