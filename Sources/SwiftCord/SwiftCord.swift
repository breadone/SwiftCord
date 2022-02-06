//
//  SwiftCord.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
//

import Foundation
import Starscream

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
    private let sema = DispatchSemaphore(value: 0)
    
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
    
    public func registerCommand(
        name: String,
        description: String,
        type: Command.CommandType,
        guildID: Snowflake? = nil,
        enabledByDefault: Bool = true,
        options: [Command.CommandOption] = [],
        handler: @escaping (CommandInfo) -> String)
    {
        // creates command and adds it to bot's command list, breaks if already in command list
        let command = Command(name: name,
                              description: description,
                              type: type,
                              guildID: guildID,
                              enabledByDefault: enabledByDefault,
                              options: options,
                              handler: handler)
        
        self.commands.append(command)
        
        // register's command to discord
        Task {
            let response = try await self.request(.createCommand(self.appID),
                                   headers: ["Content-Type": "application/json"],
                                   body: JSONSerialization.data(withJSONObject: command.arrayRepresentation, options: .fragmentsAllowed))
//            print("\n\nRESPONSE", response)
            sema.signal()
        }
        sema.wait()
        
        print("[CMD] Registered command: \(command.name)")
    }
    
    public func sendMessage(_ channelID: Snowflake, message: String) {
        let content: JSONObject = ["content": message, "tts": false]
        
        Task {
            try await self.request(.createMessage(channelID),
                                   headers: ["Content-Type": "application/json"],
                                   body: JSONSerialization.data(withJSONObject: content, options: .fragmentsAllowed))
            sema.signal()
        }
        sema.wait()
    }
    
    public func replyToMessage(_ channelID: Snowflake, message messageID: Snowflake, message: String) {
        let content: JSONObject = ["content": message,
                                   "tts": false,
                                   "message_reference": ["message_id": messageID.id]]
        
        Task {
            try await self.request(.createMessage(channelID),
                                   headers: ["Content-Type": "application/json"],
                                   body: JSONSerialization.data(withJSONObject: content, options: .fragmentsAllowed))
            sema.signal()
        }
        sema.wait()
    }
}

// MARK: - Network Functions
extension SCBot {
    /// Makes the network requests to Discord's API
    /// - Parameters:
    ///   - endpoint: Which API Endpoint to request
    ///   - params: Any HTTP Parameters to add to the request
    ///   - auth: Whether authorisation is enabled (Recommended true)
    /// - Returns: API Response as a dictionary
    @discardableResult
    public func request(
        _ endpoint: Endpoint,
        urlParams: [String: Any]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        auth: Bool = true
    ) async throws -> JSONObject {
        // Step one: get url string and add all the params
        var urlString = "https://discord.com/api/v\(options.discordApiVersion)\(endpoint.info.url)"
        
        if let params = urlParams {
            urlString.append("?")
            urlString += params.map { "\($0)=\($1)" }.joined(separator: "&")
        }
        
        // Step two: make url
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.info.method.rawValue
        
        if auth {
            request.addValue("Bot \(self.botToken)", forHTTPHeaderField: "Authorization")
        }
        
        if let headers = headers {
            for (header, value) in headers {
                request.addValue(value, forHTTPHeaderField: header)
            }
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, urlresponse) = try await URLSession.shared.data(for: request)
            let response = urlresponse as? HTTPURLResponse
            
            switch response?.statusCode { // probably more to come idk
            case 400:
                throw SCError.badToken // temporary
            case 401: // unauthorised
                throw SCError.badToken
            case 404:
                throw URLError(.badURL)
            default:
                break
            }
            
            return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! JSONObject
        } catch {
            throw error
        }
        
    }
    
    private func heartbeat() async {
        try? await Task.sleep(nanoseconds: UInt64(heartbeatInterval * 1_000_000))
        
        self.socket.write(string: Payload(opcode: .heartbeat).encode())
        print("[SCi] HB Sent")
    }
    
}

// MARK: - WebSocket shenans
extension SCBot: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected:
            print("[BOT] Connected!")
            sema.signal()
            
        case .text(let string):
//            print(string)
            let payload = Payload(json: string)
            print("[PLD] \(payload.op)")
            gatewayResponse(of: payload)
            
        case .disconnected(let reason, let code):
            print("[BOT] Disconnected \(reason), \(code)")
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
                print("[ERR] Session invalidated, trying to reconnect...")
                self.socket = nil
                self.connect()
            } else {
                print("[ERR] Session invalidated, Socket indicated that reconnection is not possible")
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
                print("[BOT] Ready!")
            }
            
        case "INTERACTION_CREATE": // command was used
            let commandName: String, commandID: Snowflake
            let interactionToken: String, interactionID: Snowflake
            let channelID: Snowflake, messageID: Snowflake
            
            guard let commandData = data["data"] as? JSONObject else { print("[ERR] Could not parse command"); return }
            
            // parses the data from the command
            commandName = commandData["name"] as? String ?? "Unknown name"
            commandID = Snowflake(string: commandData["id"] as! String)
            
            interactionToken = data["token"] as? String ?? ""
            interactionID = Snowflake(string: data["id"] as! String)
            
            channelID = Snowflake(string: data["channel_id"] as! String)
//            messageID = Snowflake(string: data["id"] as! String)
            
            let memberData = data["member"] as! JSONObject
            let user = User(json: memberData["user"] as! JSONObject)
            
            let info = CommandInfo(channelID: channelID, messageID: Snowflake(), User: user, bot: self)
            
            // search command array for matching command and execute
            for command in self.commands {
                if command.name == commandName {
                    let reply = command.handler(info)
                    
                    // reply to interaction
                    let data: JSONObject = ["type": 4, "data": ["content": reply, "tts": false]]
                    Task {
                        try await self.request(.replyToInteraction(interactionID, interactionToken),
                                               headers: ["Content-Type": "application/json"],
                                               body: JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed))
                    }
                }
            }
            
        default:
            print(payload.t ?? "how")
        }
    }
}
