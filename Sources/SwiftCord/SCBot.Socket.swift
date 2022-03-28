//
//  SCBot.Socket.swift
//  
//
//  Created by Pradyun Setti on 3/03/22.
//

import Foundation
import Starscream

extension SCBot: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected:
            printBotStatus(.genericStatus, message: "Connected...")
            sema.signal()
            
        case .text(let string):
//            print(string)
            let payload = Payload(json: string)
//            print("[PLD] \(payload.op)")
            gatewayResponse(of: payload)
            
        case .disconnected(let reason, let code):
            printBotStatus(.genericStatus, message: "Disconnected \(reason), \(code)")
        default:
            break
        }
    }
    
    
    func gatewayResponse(of payload: Payload) {
        var data: JSONObject = [:]
        
        if payload.d as? NSNull == nil { // checks Payload.d is not null
            if let d = payload.d as? JSONObject {
                data = d
            } else {
                data["d"] = payload.d
            }
        }
        
        switch payload.op {
        case 0: // Dispatch
            self.handleEvent(of: payload)
            
        case 1: // Request heartbeat
            socket.write(string: Payload(opcode: .heartbeat).encode())
            
        case 9: // Invalid session
            if (data["d"] as! Bool) {
                printBotStatus(.genericError, message: "Session invalidated, trying to reconnect...")
                self.socket = nil
                self.connect()
            } else {
                printBotStatus(.genericError, message: "Session invalidated, Socket indicated that reconnection is not possible")
            }
            
        case 10: // Hello
            heartbeatInterval = data["heartbeat_interval"] as! Double
            let intervalWithJitter = (heartbeatInterval * Double.random(in: 0...1)) * 1_000_000
            
            Task {
                try? await Task.sleep(nanoseconds: UInt64(intervalWithJitter))
                socket.write(string: Payload(opcode: .heartbeat).encode()) // writes inital heartbeat with jitter
                sema.signal()
            }
            sema.wait()
            
        case 11: // Heartbeat ack
            Task(priority: .utility) {
                await self.heartbeat()
            }
            
        default:
            break
        }
    }
    
    func handleEvent(of payload: Payload) {
        var data: JSONObject = [:]
        
        if payload.d as? NSNull == nil { // checks Payload.d is not null
            if let d = payload.d as? JSONObject {
                data = d
            } else {
                data["d"] = payload.d
            }
        }
        
        switch payload.t {
        case "READY": // Ready, can decode user (among other things but dont caare)
            if let userData = data["user"] as? JSONObject {
                self.user = User(json: userData)
                printBotStatus(.genericStatus, message: "Ready!")
            }
            
        case "INTERACTION_CREATE": // command was used
            let commandName: String //, commandID: Snowflake
            let interactionToken: String, interactionID: Snowflake
            let channelID: Snowflake, guildID: Snowflake
            
            guard let commandData = data["data"] as? JSONObject else {
                printBotStatus(.genericError, message: "Could not parse command")
                return
            }
            
            // parses the data from the interaction
            commandName = commandData["name"] as? String ?? "Unknown name"
//            commandID = Snowflake(string: commandData["id"] as! String)
            
            interactionToken = data["token"] as? String ?? ""
            interactionID = Snowflake(string: data["id"] as! String)
            
            channelID = Snowflake(string: data["channel_id"] as! String)
            guildID = Snowflake(string: data["guild_id"] as! String)
            
            let memberData = data["member"] as! JSONObject
            let user = User(json: memberData["user"] as! JSONObject)
            
            let info = CommandInfo(channelID: channelID, guildID: guildID, user: user)
            
            // search command array for matching command and execute
            for command in self.commands {
                if command.name == commandName {
                    let data: JSONObject
                    
                    if command.handlerReturnsMessage {
                        let message = command.handlerWithMessage!(info)
                        data = ["type": 4, "data": ["content": message, "tts": false]]
                    } else {
                        command.handler!(info)
                        data = ["type": 1]
                    }
                    
                    Task {
                        try await self.request(.replyToInteraction(interactionID, interactionToken),
                                               headers: ["Content-Type": "application/json"],
                                               body: JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed))
                    }
                    return
                }
            }
            
            print("[WRN] Unhandled Command! '\(commandName)'")
            Task {
                try await self.request(.replyToInteraction(interactionID, interactionToken),
                                       headers: ["Content-Type": "application/json"],
                                       body: JSONSerialization.data(withJSONObject: ["type": 4, "data": ["content": "Command not found", "tts": false]],
                                                                    options: .fragmentsAllowed))
            }
            
        default:
            printBotStatus(.event, message: "\(payload.t ?? "UNKNOWN_EVENT")")
        }
    }
}
