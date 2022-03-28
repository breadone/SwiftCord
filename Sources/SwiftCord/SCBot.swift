//
//  SwiftCord.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
//

import Foundation
import Starscream
import SwiftyJSON

/// The main SwiftCord Bot class
public class SCBot {
    public let botToken: String
    public var botIntents: Int
    public let appID: Int
    public internal(set) var user: User?
    
    public var options: SCOptions
    public var presence: SCPresence
    public internal(set) var commands: [Command] = []
    
    public internal(set) var socket: WebSocket! = nil
    public internal(set) var heartbeatInterval: Double = 0
    internal let sema = DispatchSemaphore(value: 0)
    
    /// Creates a new Discord Bot using SwiftCord
    /// - Parameters:
    ///   - token: Your bot token
    ///   - appId: Your application ID, gotten from bot dashboard
    ///   - intents: The bot's intent integer, gotten from the bot dashboard
    ///   - options: An optional SwiftCord options object
    public init(token: String, appId id: Int, intents: Int, options: SCOptions = .default) {
        self.botToken = token
        self.appID = id
        self.botIntents = intents
        self.options = options
        self.presence = SCPresence(status: .online)
        
        self.commands = CMDFile.readCommandsFile()  // inits saved commands from file
    }
    
}

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
                print("[ERR] \(error.localizedDescription)")
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
            print("[CMD] Skipping registering existing command: \(command)")
            return
        }
        
        // register's command to discord
        Task {
            try await self.request(.createCommand(self.appID),
                                   headers: ["Content-Type": "application/json"],
                                   body: JSONSerialization.data(withJSONObject: command.arrayRepresentation, options: .fragmentsAllowed))
        }
        
        print("[CMD] Registered command: \(command.name)")
    }
    
    internal func deleteCommand(_ command: Command) {
        Task {
            try await self.request(.deleteCommand(self.appID),
                                   headers: ["Content-Type": "application/json"],
                                   body: JSONSerialization.data(withJSONObject: command.arrayRepresentation, options: .fragmentsAllowed))
        }
        
        printBotStatus(.command, message: "Deleted unused command: \(command)")
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


// MARK: - Helper file operator
struct CMDFile {
    static func writeCommandsFile(_ content: String) {
        if let dcDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathWithFilename = dcDirectory.appendingPathComponent("SCCommands.json")
                do {
                    try content.write(to: pathWithFilename,
                                         atomically: true,
                                         encoding: .utf8)
                } catch {
                    printBotStatus(.saveFile, message: error.localizedDescription)
                }
        }
    }
    
    static func readCommandsFile() -> [Command] {
        var cmds = [Command]()
        
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileContent = try? String(contentsOf: path.appendingPathComponent("SCCommands.json"))
            let json = JSON(parseJSON: fileContent ?? "{}")
            
            for (_, cmd) in json {
                let name: String = cmd["name"].stringValue
                let desc: String = cmd["description"].stringValue
                
                cmds.append(Command(name: name, description: desc, type: .slashCommand, handler: {_ in}))
            }
            
            
            return cmds
        } else {
            return cmds
        }
    }
}
