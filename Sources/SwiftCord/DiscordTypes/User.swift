//
//  User.swift
//  
//
//  Created by Pradyun Setti on 29/12/21.
//

import Foundation

public struct User: Codable, Hashable {
    
    /// the user's id
    public let id: Snowflake

    /// Equivalent to at-mentioning the user on discord
    public var atUser: String {
        "<@\(self.id.idString)>"
    }
    
    /// the user's username
    public let username: String
    
    /// the user's discord tag
    public let discriminator: String
    
    /// the user's avatar hash
    public let avatar: String?
    
    /// the user's email address
    public let email: String?
    
    /// whether the user is a bot
    public let bot: Bool
    
    /// whether the user has verified their email addess
    public let verified: Bool
    
    /// the user's banner hash
    public let banner: String?
    
    /// whether the user has enabled MFA
    public let mfaEnabled: Bool
    
    /// any flags the user has
    public let flags: Int
    
    /// the user's banner accent colour, endoded as an integer representation of a hex colour code
    public let accentColor: Int?
    
    /// the type of nitro subscription on the user's account
    public let premiumType: Int?
    
    public init(id: Snowflake,
                username: String,
                discriminator: String,
                avatar: String?,
                email: String?,
                bot: Bool,
                verified: Bool,
                banner: String?,
                mfaEnabled: Bool,
                flags: Int,
                accentColor: Int?,
                premiumType: Int?) {
        self.id = id
        self.username = username
        self.discriminator = discriminator
        self.avatar = avatar
        self.email = email
        self.bot = bot
        self.verified = verified
        self.banner = banner
        self.mfaEnabled = mfaEnabled
        self.flags = flags
        self.accentColor = accentColor
        self.premiumType = premiumType
        
    }

    public init(json userData: JSONObject) {
        self.init(id: Snowflake(uint64: UInt64(userData["id"] as! String)!),
                        username: userData["username"] as? String ?? "Unknown Username",
                        discriminator: userData["discriminator"] as? String ?? "Unknown Discriminator",
                        avatar: userData["avatar"] as? String,
                        email: nil,
                        bot: userData["bot"] as? Bool ?? true,
                        verified: userData["verified"] as? Bool ?? false,
                        banner: nil,
                        mfaEnabled: userData["mfa_enabled"] as? Bool ?? false,
                        flags: userData["flags"] as? Int ?? 0,
                        accentColor: nil,
                        premiumType: nil
        )
    }
}
