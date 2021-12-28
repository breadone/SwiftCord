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
    public var options: SCOptions
    public var presence: SCPresence
    private var socket: WebSocket! = nil
    
    public init(token: String, options: SCOptions = .default) {
        self.botToken = token
        self.options = options
        self.presence = SCPresence(status: .online)
    }
    
    public func connect() async {
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
        
        // send Identify Payload
        try! await Task.sleep(nanoseconds: 5 * 1_000_000_000) // delay to account for connection time THIS WILL CHANGE DW
        let data: JSONObject = [
            "token": botToken,
            "properties": [
                "$os": "linux",
                "$browser": "SwiftCord",
                "$device": "SwiftCord"
            ],
            "presence": presence.encode(),
            "compress": false,
            "intents": 7
        ]
        
        socket.write(string: Payload(opcode: .identify, data: data).encode())
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
    func request(
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
    
    func heartbeat(at interval: Double) {
        let intervalWithJitter = (interval * Double.random(in: 0...1)) / 1000
        
        DispatchQueue.main.asyncAfter(deadline: .now() + intervalWithJitter) {
            self.socket.write(string: Payload(opcode: .heartbeat).encode())
            print("heartbeat sent")
            self.heartbeat(at: interval)
        }
    }
    
}

// MARK: WebSocket shenans
extension SCBot: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected:
            print("[SCBot] Connected!")
        case .text(let string):
            let payload = Payload(json: string)
            gatewayResponse(of: payload)
        default:
            break
        }
    }
    
    func gatewayResponse(of payload: Payload) {
        var data: JSONObject = [:]
        
        if payload.d as? NSNull == nil { // checks Payload.d is not null
            data = payload.d as! JSONObject
        }
        
        switch payload.op {
        case 10: // Hello
            self.heartbeat(at: data["heartbeat_interval"] as! Double)
        case 11: // HB Ack
            print("Heartbeat acknowleged")
        default:
            print(payload.op)
        }
    }
}
