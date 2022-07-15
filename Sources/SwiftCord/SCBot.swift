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
        var cmds = [JSONObject]()
        self.commands.forEach { command in
            var tmp = command.arrayRepresentation
            // add the guild id to file so we can handle auto-deleting guild commands
            if let g = command.guildID {
                tmp["guild_id"] = g.idString
            }
            
            cmds.append(tmp)
        }
        
        let content = cmds.encode()
        
        if let dcDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathWithFilename = dcDirectory.appendingPathComponent("SCCommands.json")
                do {
                    try content.write(to: pathWithFilename,
                                         atomically: true,
                                         encoding: .utf8)
                    botStatus(.saveFile, message: "Commands file written")
                } catch {
                    botStatus(.saveFile, message: error.localizedDescription)
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
                let id: String = cmd["id"].stringValue
                let guildID: String = cmd["guild_id"].stringValue

                cmds.append(Command(id: Snowflake(string: id),
                                    name: name,
                                    description: desc,
                                    type: .slashCommand,
                                    guildID: Snowflake(string: guildID),
                                    handler: { _ in "" })) // temporary handler, will get replaced on command re-addition
            }
        }

        return cmds
    }
}
