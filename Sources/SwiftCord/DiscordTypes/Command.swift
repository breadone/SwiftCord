//
//  Command.swift
//  
//
//  Created by Pradyun Setti on 3/02/22.
//

import Foundation

// MARK: - Main Command Struct
public struct Command: JSONEncodable, Equatable {
    
    /// Command ID
    let id: Snowflake
    
    /// The type of Application Command
    let type: Int
    
    /// The name of the command
    let name: String
    
    /// The Guild ID, if the command is Guild-specific
    let guildID: Snowflake?
    
    /// 1-100 character description of the command
    let description: String
    
    /// Whether the parameter is required or not (default true)
    let required: Bool
    
    /// The command to execute when the command is called
    let handler: (String) -> Void
    
    internal init(name: String,
                  description: String,
                  type: CommandType,
                  guildID: Snowflake? = nil,
                  req: Bool = true,
                  handler: @escaping (String) -> Void)
    {
        self.id = Snowflake()
        self.name = name
        self.description = description
        self.type = type.rawValue
        self.guildID = guildID
        self.required = req
        self.handler = handler
    }
    
    // MARK: Methods
    public static func == (lhs: Command, rhs: Command) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func encode() -> String {
        return ["name": self.name,
                "type": self.type,
                "description": self.description].encode()
    }
}

// MARK: - Helper Types
extension Command {
    public enum CommandType: Int {
        case slashCommand = 1
        case user = 2
        case message = 3
    }
}

