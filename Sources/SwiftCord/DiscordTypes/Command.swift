//
//  Command.swift
//  
//
//  Created by Pradyun Setti on 3/02/22.
//

import Foundation

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
    let description: String
    
    /// Whether the parameter is required or not (default true)
    let defaultPermission: Bool
    
    /// The function to execute when the command is called
    /// Return the message the bot should reply with
    var handler: (CommandInfo) -> String
    
    internal var arrayRepresentation: JSONObject {
        var cmd: JSONObject =
        ["name": self.name,
         "type": self.type,
         "description": self.description,
         "options": []]
        
        if !options.isEmpty {
            var opts = [JSONObject]()
            for option in options {
                opts.append(option.arrayRepresentation)
            }
            cmd["options"] = opts
        }
        
        return cmd
    }
    
    /// Create a command object, that replies with a message immediately
    public init(id: Snowflake = Snowflake(),
                  name: String,
                  description: String,
                  type: CommandType = .slashCommand,
                  guildID: Snowflake? = nil,
                  enabledByDefault: Bool = true,
                  options: [CommandOption] = [],
                  handler: @escaping (CommandInfo) -> String)
    {
        self.commandID = id
        self.name = name.lowercased()
        self.description = description
        self.type = type.rawValue
        self.options = options
        self.guildID = guildID
        self.defaultPermission = enabledByDefault
        self.handler = handler
    }

    // MARK: Methods
    public static func == (lhs: Command, rhs: Command) -> Bool {
        return (lhs.name == rhs.name && lhs.options == rhs.options)
    }
    
    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.commandID)
    }
}

// MARK: - Helper Types
public typealias CommandOption = Command.CommandOption
extension Command {
    public struct CommandOption: Equatable { // TODO: Write custom initialiser and docs for this
        /// The datatype of choices to use
        let type: Int
        
        /// The name of the Option
        let name: String
        
        /// Description of the Option
        let description: String
        
        /// If the option is required
        let req: Bool
        
        /// The command option's choices
        let choices: [(name: String, value: String)]

        public init(_ type: CommandOptionType,
                    name: String,
                    description: String,
                    required: Bool = false,
                    choices: (name: String, value: String)...) {
            self.type = type.rawValue
            self.name = name.lowercased()
            self.description = description
            self.req = required
            self.choices = choices
            
        }
        
        internal var arrayRepresentation: JSONObject {
            var data: JSONObject = ["name": name, "description": description, "type": type, "required": req, "choices": ""]
            var choice = [JSONObject]()
            for c in choices {
                choice.append(["name": c.name, "value": c.value])
            }
            data["choices"] = choice
            return data
        }
        
        public static func == (lhs: CommandOption, rhs: CommandOption) -> Bool {
            return lhs.name == rhs.name && lhs.description == rhs.description
        }
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
public struct CommandInfo: Hashable {
    private let id = UUID()

    public var channelID: Snowflake
    public var guildID: Snowflake
    public var user: User
    public var options: [(name: String, value: String)]
    
    public static func == (lhs: CommandInfo, rhs: CommandInfo) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        let _ = hasher.finalize()
    }
}
