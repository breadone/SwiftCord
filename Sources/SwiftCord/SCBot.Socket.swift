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
                botStatus(.genericError, message: "Session invalidated, trying to reconnect...")
                self.socket = nil
                self.connect()
            } else {
                botStatus(.genericError, message: "Session invalidated, Socket indicated that reconnection is not possible")
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
                botStatus(.genericStatus, message: "Ready!")
            }
            
        case "INTERACTION_CREATE": // command was used
            let commandName: String
            let interactionToken: String, interactionID: Snowflake
            let channelID: Snowflake, guildID: Snowflake
            
            guard let commandData = data["data"] as? JSONObject else {
                botStatus(.genericError, message: "Could not parse command")
                return
            }
            
            // parses the data from the interaction
            commandName = commandData["name"] as? String ?? "Unknown name"
            
            interactionToken = data["token"] as? String ?? ""
            interactionID = Snowflake(string: data["id"] as! String)
            
            channelID = Snowflake(string: data["channel_id"] as! String)
            guildID = Snowflake(string: data["guild_id"] as! String)
            
            let memberData = data["member"] as! JSONObject
            let user = User(json: memberData["user"] as! JSONObject)
            
            let optionData = commandData["options"] as? [JSONObject] ?? [[:]]
            
            var opts = [(String, String)]()
            
            for opt in optionData {
                opts.append((opt["name"] as? String ?? "<>", "\(opt["value"]!)"))
            }
            
            let info = CommandInfo(channelID: channelID, guildID: guildID, user: user, options: opts)
            
            // search command array for matching command and execute
            for command in self.commands {
                if command.name == commandName {
                    let message = command.handler(info)  // execute command handler
                    
                    // filter response between embed and string
                    let response: JSONObject
                    if let text = message as? String {
                        response = ["content": text, "tts": false]
                    } else {
                        response = ["embeds": [(message as! Embed).arrayRepresentation], "tts": false]
                    }
                    
                    let content: JSONObject = ["type": 4, "data": response]
                    
                    Task {
                        try await self.request(.replyToInteraction(interactionID, interactionToken),
                                               headers: ["Content-Type": "application/json"],
                                               body: content.data())
                    }
                    
                    if self.options.displayCommandMessages {
                        botStatus(.command, message: "Command `\(command.name)` run, with info `\(opts), replied `\(message)`")
                    }
                    return
                }
            }
            
            botStatus(.warning, message: "Unhandled Command! '\(commandName)'")
            Task {
                let content: JSONObject = ["type": 4, "data": ["content": "Command not found", "tts": false]]
                
                try await self.request(.replyToInteraction(interactionID, interactionToken),
                                       headers: ["Content-Type": "application/json"],
                                       body: content.data())
            }
            
        default:
            if self.options.displayEvents {
                botStatus(.event, message: "\(payload.t ?? "UNKNOWN_EVENT")")
            }
        }
    }
}
