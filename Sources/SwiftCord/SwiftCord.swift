//
//  SwiftCord.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
//

import Foundation

public struct SwiftCord {
    let botToken: String
    let socket = Websocket(url: Endpoint.botGateway)
    
    public init(token: String) {
        self.botToken = token
    }
    
}
