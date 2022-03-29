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
    ///   - id: Your application ID, gotten from bot dashboard
    ///   - intents: The bot's intent integer, gotten from the bot dashboard
    ///   - options: An optional SwiftCord options object
    public init(token: String, appId id: Int, intents: Int, options: SCOptions = .default) {
        self.botToken = token
        self.appID = id
        self.botIntents = intents
        self.options = options
        self.presence = SCPresence(status: .online)
        
        self.commands = readCommandsFile()  // inits saved commands from file
    }
    
}


// MARK: - Helper file operator
extension SCBot {
    func writeCommandsFile() {
        let content = self.commands.encode()

        if let dcDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathWithFilename = dcDirectory.appendingPathComponent("SCCommands.json")
                do {
                    try content.write(to: pathWithFilename,
                                         atomically: true,
                                         encoding: .utf8)
                    printBotStatus(.saveFile, message: "Commands file written")
                } catch {
                    printBotStatus(.saveFile, message: error.localizedDescription)
                }
        }
    }
    
    func readCommandsFile() -> [Command] {
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
