//
//  Command.swift
//  
//
//  Created by Pradyun Setti on 3/02/22.
//

import Foundation
import SwiftyJSON

// MARK: - Command
public struct Command: Equatable, Hashable, ArrayRepresentable {
    /// Command ID
    let commandID: Snowflake
    
    /// The type of Application Command
    let type: Int
    
    /// The name of the command
    let name: String
    
    /// The Guild ID, if the command is Guild-specific
    let guildID: Snowflake?
    
    /// Any Command Options
    let options: [CommandOption]
    
    /// 1-100 character description of the command
    let description: String?
    
    /// Whether the parameter is required or not (default true)
    let defaultPermission: Bool
    
    /// The function to execute when the command is called
    /// Return the message the bot should reply with
    var handler: (CommandInfo) -> Messageable
    
    public var arrayRepresentation: JSON {
        var cmd: JSONObject =
        ["name": self.name,
         "type": self.type,
         "description": self.description as Any,
         "options": []]
        
        if !options.isEmpty {
            var opts = [JSONObject]()
            for option in options {
                opts.append(option.arrayRepresentation.dictionaryObject ?? [:])
            }
            cmd["options"] = opts
        }
        
        return JSON(cmd)
    }
    
    /// Create a command object, that replies with a message immediately
    public init(id: Snowflake = Snowflake(),
                  name: String,
                  description: String?,
                  type: CommandType = .slashCommand,
                  guildID: Snowflake? = nil,
                  enabledByDefault: Bool = true,
                  options: [CommandOption] = [],
                  handler: @escaping (CommandInfo) -> Messageable)
    {
        self.commandID = id
        self.name = name.lowercased()
        self.type = type.rawValue
        self.options = options
        self.guildID = guildID
        self.defaultPermission = enabledByDefault
        self.handler = handler
        
        if type != .user {
            self.description = description
        } else { self.description = nil}
        
    }

    // MARK: Methods
    public static func == (lhs: Command, rhs: Command) -> Bool {
        var lhsRep = lhs.arrayRepresentation
        var rhsRep = rhs.arrayRepresentation
        
        // add options to the command representations
        lhsRep["guild_id"].string = lhs.guildID?.idString
        rhsRep["guild_id"].string = rhs.guildID?.idString
        
        return (try? lhsRep.rawData() == rhsRep.rawData()) ?? false
    }
    
    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.commandID)
    }
}

// MARK: - Helper Types
public typealias CommandOption = Command.CommandOption

extension Command {
    public struct CommandOption: Equatable, ArrayRepresentable {
        /// The datatype of choices to use
        let type: Int
        
        /// The name of the Option
        let name: String
        
        /// Description of the Option
        let description: String
        
        /// If the option is required
        let req: Bool
        
        /// The command option's choices
        let choices: [(label: String, value: String)]

        public init(_ type: CommandOptionType,
                    name: String,
                    description: String,
                    required: Bool = true,
                    choices: [(label: String, value: String)] = []) {
            self.type = type.rawValue
            self.name = name.lowercased()
            self.description = description
            self.req = required
            self.choices = choices    
        }
        
        public var arrayRepresentation: JSON {
            var data: JSONObject = ["name": name, "description": description, "type": type, "required": req, "choices": ""]
            var choice = [JSONObject]()
            for c in choices {
                choice.append(["name": c.label, "value": c.value])
            }
            data["choices"] = choice
            
            return JSON(data)
        }
        
        public static func == (lhs: CommandOption, rhs: CommandOption) -> Bool {
            if lhs.choices.count != rhs.choices.count { return false }
            
            // makes sure the choices match 
            for i in 0 ..< lhs.choices.count {
                if lhs.choices[i].label != rhs.choices[i].label || lhs.choices[i].value != rhs.choices[i].value {
                    return false
                }
            }
            
//            return lhs.name == rhs.name && lhs.description == rhs.description
            return ((try? lhs.arrayRepresentation.rawData() == rhs.arrayRepresentation.rawData()) != nil) // xcode autocomplete did this,, huh
        }
    }
    
    public enum CommandType: Int {
        case slashCommand = 1
        case user = 2
        case message = 3
    }
    
    public enum CommandOptionType: Int {
//        case subCommand = 1
//        case subCommandGroup = 2
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
public struct CommandInfo: Hashable {
    private let id = UUID()

    /// The Channel that the command was used in
    public var channelID: Snowflake
    
    /// The Guild that the command was used in
    public var guildID: Snowflake
    
    /// The user that sent/used the command
    public var sender: User
    
    internal var options: [(label: String, value: String)]
    
    /// If the command is a User command, this is the target user
    public var targetUser: User?
    
    /// Get the value for the input option value
    public func getOptionValue(for name: String) -> String? {
        return options.first { $0.label == name }?.value
    }
    
    public static func == (lhs: CommandInfo, rhs: CommandInfo) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        let _ = hasher.finalize()
    }
}
