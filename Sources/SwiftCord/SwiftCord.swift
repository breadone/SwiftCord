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
    
    public var options: SCOptions
    public var presence: SCPresence
    
    private var socket: WebSocket! = nil
    private var interval: Double = 0 // heartbeat interval
    private let sema = DispatchSemaphore(value: 0)
    
    /// Creates a new Discord Bot using SwiftCord
    /// - Parameters:
    ///   - token: Your bot token
    ///   - intents: The bot's intent integer, gotten from the bot dashboard
    ///   - options: An optional SwiftCord options object
    public init(token: String, intents: Int, options: SCOptions = .default) {
        self.botToken = token
        self.botIntents = intents
        self.options = options
        self.presence = SCPresence(status: .online)
    }
    
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
                print("[SCERROR]: \(error.localizedDescription)")
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
            "presence": presence.encode(),
            "compress": false,
            "intents": botIntents
        ]
        
        socket.write(string: Payload(opcode: .identify, data: data).encode())
        print("identified")
    }
}

// MARK: Network Functions
extension SCBot {
    /// Makes the network requests to Discord's API
    /// - Parameters:
    ///   - endpoint: Which API Endpoint to request
    ///   - params: Any HTTP Parameters to add to the request
    ///   - auth: Whether authorisation is enabled (Recommended true)
    /// - Returns: API Response as a dictionary
    public func request(
        _ endpoint: Endpoint,
        params: [String: Any]? = nil,
        auth: Bool = true
    ) async throws -> JSONObject {
        // Step one: get url string and add all the params
        var urlString = "https://discord.com/api/v\(options.discordApiVersion)\(endpoint.info.url)"
        
        if let params = params {
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
        
        do {
            let (data, urlresponse) = try await URLSession.shared.data(for: request)
            let response = urlresponse as? HTTPURLResponse
            
            switch response?.statusCode { // probably more to come idk
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
    
    private func heartbeat() {
        Task(priority: .utility) {
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000))
            
            self.socket.write(string: Payload(opcode: .heartbeat).encode())
            print("heartbeat sent")
            sema.signal()
        }
        sema.wait()
    }
    
}

// MARK: WebSocket shenans
extension SCBot: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected:
            print("[SCBot] Connected!")
            sema.signal()
        case .text(let string):
            print(string)
            let payload = Payload(json: string)
            gatewayResponse(of: payload)
        case .disconnected(let reason, let code):
            print("[SCBot] Disconnected \(reason), \(code)")
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
        case 1: // Request Heartbeat
            socket.write(string: Payload(opcode: .heartbeat).encode())
            
        case 9:
            print("[SCBot] Session invalidated, trying to reconnect...")
            self.socket = nil
            self.connect()
            
        case 10: // Hello
            interval = data["heartbeat_interval"] as! Double
            let intervalWithJitter = (interval * Double.random(in: 0...1)) * 1_000_000
            Task {
                try? await Task.sleep(nanoseconds: UInt64(intervalWithJitter))
                socket.write(string: Payload(opcode: .heartbeat).encode()) // writes inital heartbeat with jitter
                sema.signal()
            }
            sema.wait()
            self.heartbeat() // send heatbeats with regular interval after
            
        case 11: // Heartbeat Ack
            print("Heartbeat acknowleged")
            self.heartbeat()
            
        default:
            break
        }
    }
}
