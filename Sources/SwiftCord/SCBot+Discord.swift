//
//  SCBot+Discord.swift
//
//
// Created by Pradyun Setti on 29/03/22.
//

import Foundation
import Starscream

// MARK: - Discord Functions
extension SCBot {
    /// Connects the bot to Discord's servers
    public func connect() {
        Task(priority: .high) {
            do {
                let data = try await self.request(.gateway)
                var urlString = data["url"] as! String
                urlString += "/?v=\(options.discordApiVersion)&encoding=json"
                
                guard let url = URL(string: urlString) else {
                    botStatus(.genericError, message: "Failed to connect! The URL is not correct (SCBot+Discord.swift)")
                    return
                }
                
                self.socket = WebSocket(request: URLRequest(url: url))
                self.socket.delegate = self
                socket.connect()
            } catch {
                botStatus(.genericError, message: error.localizedDescription)
            }
        }
        sema.wait() // waits for WS Connection

        // send Identify Payload
        let data: JSONObject = [
            "token": botToken,
            "properties": [
                "$os": "linux",
                "$browser": "SwiftCord",
                "$device": "SwiftCord"
            ],
            "presence": presence.arrayRepresentation,
            "compress": false,
            "intents": botIntents
        ]
        let identify = Payload(opcode: .identify, data: data).encode()
        socket.write(string: identify)
    }

    /// Adds your commands to the bot
    /// Supports multiple commands at once, **should only be called once**
    /// Eg. `bot.addCommands(command1, command2, command3)`
    /// - Parameter guild: Optional, the ID of the guild to add if it's a guild command
    /// - Parameter newCommands: the commands to add
    public func addCommands(to guild: Int? = nil, _ newCommands: Command...) {
        for command in newCommands {
            // check command isnt already in bot array
            if self.commands.contains(where: { $0 == command }) {
                let index = self.commands.firstIndex(where: { $0 == command })!

                self.commands[index].handler = command.handler // replaces default command with actual command
                botStatus(.command, message: "Skipping registering existing command: \(command.name)")
                continue
            }
            
            Task {
                let body = try command.arrayRepresentation.data()
                
                // register's command to discord
                let response: JSONObject
                
                // if its a guild command then use that endpoint instead
                if let guild = guild {
                    response = try await self.request(.createGuildCommand(self.appID, guild),
                            headers: ["Content-Type": "application/json"],
                            body: body)
                } else {
                    response = try await self.request(.createCommand(self.appID),
                            headers: ["Content-Type": "application/json"],
                            body: body)
                }
                
                botStatus(.command, message: "Registered command: \(command.name)")
                
                let id = response["id"] as? String ?? ""  // this contains the actual snowflake, rather than the randomly generated client one
                let newCommand = Command(id: Snowflake(string: id),
                                         name: command.name,
                                         description: command.description,
                                         type: Command.CommandType(rawValue: command.type)!,
                                         guildID: Snowflake(int: guild),
                                         handler: command.handler) // replaces the empty handler from file with the actual handler

                self.commands.append(newCommand)
                
                self.writeCommandsFile()
            }
        }

//      delete unused commands by searching thru them and comparing if they exist in the new array
        for command in self.commands {
            if !newCommands.contains(where: { $0 == command }) {
                Task {
                    self.commands.removeAll(where: { $0 == command })
                    
                    if let guildID = command.guildID {
                        try await self.request(.deleteGuildCommand(self.appID, Int(guildID.id), command.commandID))
                        botStatus(.command, message: "Deleting unused Guild command: \(command.name)")
                    } else {
                        try await self.request(.deleteCommand(self.appID, command.commandID))
                        botStatus(.command, message: "Deleting unused command: \(command.name)")
                    }
                    
                    self.writeCommandsFile()
                }
            }
        }

    }
    
    /// Sends a message to a Channel, with optional embed support.
    /// Can have either a message or series of embeds or both, but has to have at least one of the two, otherwise it will fail to send anything.
    /// - Parameters:
    ///   - channelID: The ID of the channel to send messages to. Right click a channel and click 'copy ID' to get it
    ///   - message: The string message to send
    ///   - embeds: Array of embeds to send
    ///   - tts: Whether to enable Text-To-Speech for all supported users on the channel
    public func sendMessage(to channelID: Int, message: String? = nil, embeds: [Embed]? = nil, tts: Bool = false) {
        var content: JSONObject = ["tts": tts]
        
        if let message = message {
            content["content"] = message
        }
        
        if let embeds = embeds {
            var representedArray = [JSONObject]()
            embeds.forEach { representedArray.append($0.arrayRepresentation) }
            
            content["embeds"] = representedArray
        }
        
        let data = try? content.data() // xc cries when i dont have this i dont know why
        
        Task {
            try await self.request(.createMessage(Snowflake(uint64: UInt64(channelID))),
                                   headers: ["Content-Type": "application/json"],
                                   body: data)
        }
    }

    public func replyToMessage(_ channelID: Snowflake, message messageID: Snowflake, message: String) {
        let content: JSONObject = ["content": message,
                                   "tts": false,
                                   "message_reference": ["message_id": messageID.id]]

        Task {
            try await self.request(.createMessage(channelID),
                                   headers: ["Content-Type": "application/json"],
                                   body: content.data())
        }
    }
}
