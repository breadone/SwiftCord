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
    let botToken: String
    var options: SCOptions
    private var socket: WebSocket! = nil
    
    public init(token: String, options: SCOptions = .default) {
        self.botToken = token
        self.options = options
    }
    
    public func connect() async {
        var data: JSONObject?
        do {
            data = try await self.request(.gateway)
            let url = URL(string: data!["url"] as! String)!
            self.socket = WebSocket(request: URLRequest(url: url))
            self.socket.delegate = self
            socket.connect()
        } catch {
            print("[SCERROR]: \(error.localizedDescription)")
        }
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
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! JSONObject
        } catch {
            throw error
        }
        
    }
}

extension SCBot: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected:
            print("CONNECTED")
        default:
            print("rip")
        }
    }
    
    
}
