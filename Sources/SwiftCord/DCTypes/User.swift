//
//  User.swift
//  
//
//  Created by Pradyun Setti on 29/12/21.
//

import Foundation

public struct User: Codable {
    
    /// the user's id
    public let id: Snowflake
    
    /// the user's username
    public let username: String
    
    /// the user's discord tag
    public let discriminator: String
    
    /// the user's avatar hash
    public let avatar: String?
    
    /// whether the user is a bot
    public let bot: Bool?
    
    /// whether the user has verified their email addess
    public let verified: Bool
    
    /// the user's banner hash
    public let banner: String
    
    /// the user's banner accent colour, endoded as an integer representation of a hex colour code
    public let accentColor: Int?
    
    /// the type of nitro subscription on the user's account
    public let premiumType: Int

//    enum CodingKeys: String, CodingKey {
//        case id, username, discriminator, avatar, verified, email, flags, banner
//        case accentColor = "accent_color"
//        case premiumType = "premium_type"
//        case publicFlags = "public_flags"
//    }
}
