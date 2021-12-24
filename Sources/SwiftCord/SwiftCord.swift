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
    let socket = Websocket(url: URL(string: Endpoint.gateway.url)!)
    
    public init(token: String, options: SCOptions = .default) {
        self.botToken = token
        self.options = options
    }
}

// MARK: Network Functions
extension SCBot {
    func request(
        _ endpoint: Endpoint,
        params: [String: Any]? = nil
    ) {
        
        // Step one: get url string and add all the params
        var url = "https://discord.com/api/v\(options.discordApiVersion)\(endpoint.url)"
        
        if let params = params {
            url.append("?")
            url += params.map { "\($0)=\($1)" }.joined(separator: "&")
        }
        
    }
}
