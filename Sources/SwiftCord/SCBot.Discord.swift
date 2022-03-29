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
    /// - Parameter commands: the commands to add
    public func addCommands(_ commands: Command...) {
        commands.forEach { command in  // register commands first
            self.registerCommand(command)
        }

        self.commands.forEach { c in
            if !commands.contains(c) {
                self.deleteCommand(c)
                botStatus(.command, message: "Deleted unused command: \(c.name)")
            }
        }

    }

    /// Internal function to add commands, use addCommands() instead!
    private func registerCommand(_ c: Command) {
        guard !self.commands.contains(c) else {
            botStatus(.command, message: "Skipping registering existing command: \(c.name)")
            return
        }

        
        Task {
            // register's command to discord
            let data = try await self.request(.createCommand(self.appID),
                    headers: ["Content-Type": "application/json"],
                    body: JSONSerialization.data(withJSONObject: c.arrayRepresentation, options: .fragmentsAllowed))
            botStatus(.command, message: "Registered command: \(c.name)")
            let id = data["id"] as? String ?? ""  // this contains the actual snowflake, rather than the randomly generated client one
            
            
            if c.handlerReturnsMessage {
                let newCommand = Command(id: Snowflake(string: id),
                                         name: c.name,
                                         description: c.description,
                                         type: Command.CommandType(rawValue: c.type)!,
                                         handler: c.handlerWithMessage!) // duplicates the command with the new id
                self.commands.append(newCommand)
            } else {
                let newCommand = Command(id: Snowflake(string: id),
                                         name: c.name,
                                         description: c.description,
                                         type: Command.CommandType(rawValue: c.type)!,
                                         handler: c.handler!)
                self.commands.append(newCommand)
            }
            
            self.writeCommandsFile()
        }
        
    }

    internal func deleteCommand(_ command: Command) {
        Task {
            try await self.request(.deleteCommand(self.appID),
                    headers: ["Content-Type": "application/json"],
                    body: JSONSerialization.data(withJSONObject: command.arrayRepresentation, options: .fragmentsAllowed))
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
