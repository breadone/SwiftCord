//
//  SCBot+Socket.swift
//  
//
//  Created by Pradyun Setti on 3/03/22.
//

import Foundation
import Starscream
import SwiftyJSON

extension SCBot: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected:
            botStatus(.genericStatus, message: "Connected...")
            sema.signal()
            
        case .text(let string):
//            print(string)
            let payload = Payload(json: string)
//            print("[PLD] \(payload.op)")
            gatewayResponse(of: payload)
            
        case .disconnected(let reason, let code):
            botStatus(.genericStatus, message: "Disconnected \(reason), \(code)")
        default:
            break
        }
    }
    
    
    func gatewayResponse(of payload: Payload) {
        var data = JSON()
        
        if payload.d as? NSNull == nil { // checks Payload.d is not null
            if let d = payload.d as? JSONObject {
                data = JSON(d)
            } else {
                data["d"] = JSON(payload.d!)
            }
        }
        
        switch payload.op {
        case 0: // Dispatch
            self.handleEvent(of: payload)
            
        case 1: // Request heartbeat
            socket.write(string: Payload(opcode: .heartbeat).encode())
            
        case 9: // Invalid session
            fireEventHandler(for: .invalidSession, with: data)
            if (data["d"].boolValue) {
                botStatus(.genericError, message: "Session invalidated, trying to reconnect...")
                self.socket = nil
                self.connect()
            } else {
                botStatus(.genericError, message: "Session invalidated, Socket indicated that reconnection is not possible")
            }
            
        case 10: // Hello
            fireEventHandler(for: .hello, with: data)
            heartbeatInterval = data["heartbeat_interval"].doubleValue
            let intervalWithJitter = (heartbeatInterval * Double.random(in: 0...1)) * 1_000_000
            
            Task {
                try? await Task.sleep(nanoseconds: UInt64(intervalWithJitter))
                socket.write(string: Payload(opcode: .heartbeat).encode()) // writes inital heartbeat with jitter
                sema.signal()
            }
            sema.wait()
            
        case 11: // Heartbeat ack
            fireEventHandler(for: .heartbeatAck, with: data)
            Task(priority: .utility) {
                await self.heartbeat()
            }
            
        default:
            break
        }
    }
    
    func handleEvent(of payload: Payload) {
        var data = JSON()
        
        if payload.d as? NSNull == nil { // checks Payload.d is not null
            if payload.d as? [String: Any] != nil {
                data = JSON(payload.d as! [String: Any])
            } else {
                data["d"] = JSON(payload.d!)
            }
        } else {
            botStatus(.genericError, message: "Unable to parse payload")
        }
        
        switch payload.t {
        case "READY": // Ready, can decode user (among other things but dont caare)
            fireEventHandler(for: .ready, with: data)
            if let userData = data["user"].dictionaryObject {
                self.user = User(json: userData)
                botStatus(.genericStatus, message: "Ready!")
            }
            
        case "INTERACTION_CREATE": // command was used
            switch data["type"].intValue {
            case 2: // slash command
                fireEventHandler(for: .slash_command_recieved, with: data)
                commandResponse(data, self)
            case 3: // message component
                fireEventHandler(for: .message_component, with: data)
                messageComponentResponse(data, self)
            default:
                print("Interaction:", data["type"].intValue)
            }
        default:
            if self.options.displayEvents {
                botStatus(.event, message: "\(payload.t ?? "UNKNOWN_EVENT")")
            }
        }
    }
}


fileprivate func commandResponse(_ data: JSON, _ bot: SCBot) {
    let commandName: String
    let interactionToken: String, interactionID: Snowflake
    let channelID: Snowflake, guildID: Snowflake

    // parses the data from the interaction
    commandName = data["data"]["name"].stringValue

    interactionToken = data["token"].stringValue
    interactionID = Snowflake(string: data["id"].stringValue)

    channelID = Snowflake(string: data["channel_id"].stringValue)
    guildID = Snowflake(string: data["guild_id"].stringValue)

    let user = User(json: data["member"]["user"].dictionaryObject ?? [:])

    let optionData = data["data"]["options"].arrayValue
    
    var opts = [(String, String)]()

    for opt in optionData {
        opts.append((opt["name"].stringValue, "\(opt["value"])"))
    }

    var info = CommandInfo(channelID: channelID, guildID: guildID, sender: user, options: opts)
    
    // if the command was a User command, this extracts the target user
    if data["data"]["resolved"]["users"].dictionary != nil{
        let userid = data["data"]["target_id"].stringValue
        
        info.targetUser = User(json: data["data"]["resolved"]["users"][userid].dictionaryObject!)
    }
    
    // search command array for matching command and execute
    for command in bot.commands {
        if command.name == commandName {
            let message = command.handler(info)  // execute command handler

            // filter response between embed and string
            let response: [String: Any]
            if let text = message as? String {
                response = ["content": text, "tts": false]
            } else {
                response = ["embeds": [(message as! Embed).arrayRepresentation], "tts": false]
            }

            let content = JSON(["type": 4, "data": response])

            Task {
                try await bot.request(.replyToInteraction(interactionID, interactionToken),
                                       headers: ["Content-Type": "application/json"],
                                       body: content.rawData())
            }

            if bot.options.displayCommandMessages {
                bot.botStatus(.command, message: "Command `\(command.name)` run, with info `\(opts)`, replied `\(message)`")
            }
            return
        }
    }

    bot.botStatus(.warning, message: "Unhandled Command! '\(commandName)'")
    Task {
        let content = JSON(["type": 4, "data": ["content": "Command not found", "tts": false]])

        try await bot.request(.replyToInteraction(interactionID, interactionToken),
                               headers: ["Content-Type": "application/json"],
                               body: content.rawData())
    }
}

fileprivate func messageComponentResponse(_ data: JSON, _ bot: SCBot) {
    let interactionID = data["id"].stringValue
    let interactionToken = data["token"].stringValue
    
    // just pong for now, more to come later probably
    Task {
        try? await bot.request(.replyToInteraction(Snowflake(string: interactionID), interactionToken),
                               headers: ["Content-Type": "application/json"],
                               body: JSON(["type": 6]).rawData())
    }
}
