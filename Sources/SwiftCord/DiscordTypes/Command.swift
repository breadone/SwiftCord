//
//  Command.swift
//  
//
//  Created by Pradyun Setti on 3/02/22.
//

import Foundation

// MARK: - Command
public struct Command: Equatable {
    
    /// Command ID
    let id: Snowflake
    
    /// The type of Application Command
    let type: Int
    
    /// The name of the command
    let name: String
    
    /// The Guild ID, if the command is Guild-specific
    let guildID: Snowflake?
    
    /// Any Command Options
    let options: [CommandOption]
    
    /// 1-100 character description of the command
    let description: String
    
    /// Whether the parameter is required or not (default true)
    let defaultPermission: Bool
    
    /// The command to execute when the command is called, returns the message to reply with
    let handler: (CommandInfo) -> String
    
    internal var arrayRepresentation: JSONObject {
        ["name": self.name,
         "type": self.type,
         "description": self.description,
         "default_permission": self.defaultPermission,
         "options": options]
    }
    
    internal init(name: String,
                  description: String,
                  type: CommandType,
                  guildID: Snowflake? = nil,
                  enabledByDefault: Bool = true,
                  options: [CommandOption] = [],
                  handler: @escaping (CommandInfo) -> String)
    {
        self.id = Snowflake()
        self.name = name
        self.description = description
        self.type = type.rawValue
        self.options = options
        self.guildID = guildID
        self.defaultPermission = enabledByDefault
        self.handler = handler
    }
    
    // MARK: Methods
    public static func == (lhs: Command, rhs: Command) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Helper Types
extension Command {
    public struct CommandOption { // TODO: Write custom initialiser and docs for this
        let type: Int
        
        let name: String
        
        let description: String
        
        let req: Bool
        
        let choices: Int
    }
    
    public enum CommandType: Int {
        case slashCommand = 1
        case user = 2
        case message = 3
    }
    
    public enum CommandOptionType: Int { // not confusing at all discord
        case subCommand = 1
        case subCommandGroup = 2
        case string = 3
        case int = 4
        case bool = 5
        case user = 6
        case channel = 7
        case role = 8
        case mentionable = 9
        case number = 10
    }
}

// MARK: - CommandInfo
public struct CommandInfo {
    public let channelID: Snowflake
    public let messageID: Snowflake
    public let User: User
    public let bot: SCBot
    
    public func reply(with message: String) {
        self.bot.replyToMessage(self.channelID, message: self.messageID, message: message)
    }
    
}
