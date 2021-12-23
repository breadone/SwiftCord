//
//  Endpoint.swift
//  
//
//  Created by Pradyun Setti on 23/12/21.
//

import Foundation

internal struct Endpoint {
    private init() {}
    
    static let base = "https://discord.com/api"
    
    static var gateway: String {
        "\(base)/gateway"
    }
    static var botGateway: String {
        "\(base)/gateway/bot"
    }
    
}
