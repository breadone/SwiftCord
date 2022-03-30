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
                self.socket = WebSocket(request: URLRequest(url: URL(string: urlString)!))
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
    /// - Parameter newCommands: the commands to add
    public func addCommands(_ newCommands: Command...) {
        for command in newCommands {
            // check command isnt already in bot array
            if self.commands.contains(where: { $0.name == command.name }) {
                let index = self.commands.firstIndex(where: { $0.name == command.name })!
                
                if let returnMessage = command.handlerWithMessage { // replaces default command with actual command
                    self.commands[index].handlerWithMessage = returnMessage
                    self.commands[index].handlerReturnsMessage = true
                } else {
                    self.commands[index].handler = command.handler!
                }
                botStatus(.command, message: "Skipping registering existing command: \(command.name)")
                continue
            }
            
            Task {
                let body = try JSONSerialization.data(withJSONObject: command.arrayRepresentation, options: .fragmentsAllowed)
                // register's command to discord
                let response = try await self.request(.createCommand(self.appID),
                        headers: ["Content-Type": "application/json"],
                        body: body)
                botStatus(.command, message: "Registered command: \(command.name)")
                
                let id = response["id"] as? String ?? ""  // this contains the actual snowflake, rather than the randomly generated client one
                if command.handlerReturnsMessage {  // replaces rng id with discord id
                    let newCommand = Command(id: Snowflake(string: id),
                                             name: command.name,
                                             description: command.description,
                                             type: Command.CommandType(rawValue: command.type)!,
                                             handlerMessage: command.handlerWithMessage!) // duplicates the command with the new id
                    self.commands.append(newCommand)
                } else {
                    let newCommand = Command(id: Snowflake(string: id),
                                             name: command.name,
                                             description: command.description,
                                             type: Command.CommandType(rawValue: command.type)!,
                                             handler: command.handler!)
                    self.commands.append(newCommand)
                }
                
                self.writeCommandsFile()
            }
        }

//      delete unused commands by searching thru them and comparing if they exist in the new array
        for command in self.commands {
            if !newCommands.contains(where: { $0.name == command.name }) {
                Task {
                    self.commands.removeAll(where: { $0.name == command.name })
                    self.writeCommandsFile()
                    botStatus(.command, message: "Deleted unused command: \(command.name)")
                    try await self.request(.deleteCommand(self.appID, command.commandID))
                }
            }
        }

    }

    public func sendMessage(_ channelID: Snowflake, message: String) {
        let content: JSONObject = ["content": message, "tts": false]

        Task {
            try await self.request(.createMessage(channelID),
                    headers: ["Content-Type": "application/json"],
                    body: JSONSerialization.data(withJSONObject: content, options: .fragmentsAllowed))
        }
    }

    public func replyToMessage(_ channelID: Snowflake, message messageID: Snowflake, message: String) {
        let content: JSONObject = ["content": message,
                                   "tts": false,
                                   "message_reference": ["message_id": messageID.id]]

        Task {
            try await self.request(.createMessage(channelID),
                    headers: ["Content-Type": "application/json"],
                    body: JSONSerialization.data(withJSONObject: content, options: .fragmentsAllowed))
        }
    }
}
