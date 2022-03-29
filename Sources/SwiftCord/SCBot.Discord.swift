//
// Created by Pradyun Setti on 29/03/22.
//

import Foundation
import Starscream

// MARK: - Discord Functions
extension SCBot {
    /// Connects the bot to Discord's servers
    public func connect() {
        // delete unused commands first
        for cmd in self.commands {

        }


        Task(priority: .high) {
            do {
                let data = try await self.request(.gateway)
                var urlString = data["url"] as! String
                urlString += "/?v=\(options.discordApiVersion)&encoding=json"
                self.socket = WebSocket(request: URLRequest(url: URL(string: urlString)!))
                self.socket.delegate = self
                socket.connect()
            } catch {
                printBotStatus(.genericError, message: error.localizedDescription)
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

    public func registerCommand(_ command: Command) {
        guard !self.commands.contains(command) else {
            printBotStatus(.command, message: "Skipping registering existing command: \(command.name)")
            return
        }

        // register's command to discord
        Task {
            try await self.request(.createCommand(self.appID),
                    headers: ["Content-Type": "application/json"],
                    body: JSONSerialization.data(withJSONObject: command.arrayRepresentation, options: .fragmentsAllowed))
        }

        printBotStatus(.command, message: "Registered command: \(command.name)")
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