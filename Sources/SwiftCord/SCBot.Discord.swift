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
            if self.commands.contains(where: { $0.name == command.name }) {
                let index = self.commands.firstIndex(where: { $0.name == command.name })!

                self.commands[index].handler = command.handler // replaces default command with actual command
                botStatus(.command, message: "Skipping registering existing command: \(command.name)")
                continue
            }
            
            Task {
                let body = try command.arrayRepresentation.data()
                
                // register's command to discord
                let response: JSONObject
                if let guild = guild { // if its a guild command then use that endpoint instead
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
                        handler: command.handler) // replaces the empty handler from file with the actual handler

                self.commands.append(newCommand)
                
                self.writeCommandsFile()
            }
        }

//      delete unused commands by searching thru them and comparing if they exist in the new array
        for command in self.commands {
            if !newCommands.contains(where: { $0.name == command.name }) {
                Task {
                    self.commands.removeAll(where: { $0.name == command.name })
                    self.writeCommandsFile()
                    botStatus(.command, message: "Deleting unused command: \(command.name)")
                    try await self.request(.deleteCommand(self.appID, command.commandID))
                }
            }
        }

    }

    public func sendMessage(to channelID: Snowflake, message: String) {
        let content: JSONObject = ["content": message, "tts": false]

        Task {
            try await self.request(.createMessage(channelID),
                                   headers: ["Content-Type": "application/json"],
                                   body: content.data())
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
