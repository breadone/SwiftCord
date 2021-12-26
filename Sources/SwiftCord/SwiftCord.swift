//
//  SwiftCord.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
//

import Foundation

/// The main SwiftCord Bot class
public class SCBot {
    let botToken: String
    var options: SCOptions
    private let socket: Websocket! = nil
    
    public init(token: String, options: SCOptions = .default) {
        self.botToken = token
        self.options = options
    }
    
    public func connect() {
        Task {
            var data: Data?
            do {
                data = try await self.request(.gateway)
            } catch {
                print("[SCERROR]: \(error.localizedDescription)")
            }
        }
        
    }
}

// MARK: Network Functions
extension SCBot {
    func request(
        _ endpoint: Endpoint,
        params: [String: Any]? = nil,
        auth: Bool = true
    ) async throws -> Data {
        // Step one: get url string and add all the params
        var urlString = "https://discord.com/api/v\(options.discordApiVersion)\(endpoint.info.url)"
        
        if let params = params {
            urlString.append("?")
            urlString += params.map { "\($0)=\($1)" }.joined(separator: "&")
        }
        
        // Step two: make url
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        
        if auth {
            request.addValue("Bot \(self.botToken)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return data
        } catch {
            throw error
        }
        
    }
}
