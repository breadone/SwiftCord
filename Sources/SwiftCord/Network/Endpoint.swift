//
//  Endpoint.swift
//  
//
//  Created by Pradyun Setti on 23/12/21.
//

import Foundation

public enum Endpoint {
    case gateway
    
    // MARK: Channel
    case getChannel(Snowflake)
    case modifyChannel(Snowflake)
    case deleteChannel(Snowflake)
    case getChannelMessages(Snowflake)
    
    // MARK: User
    case getCurrentUser
    case getUser(Snowflake)
}

extension Endpoint {
    var info: (method: HTTPMethod, url: String) {
        switch self {
        case .gateway:
            return (.get, "/gateway/bot")
            
        case let .getChannel(id):
            return (.get, "/channels/\(id.idString)")
            
        case let .modifyChannel(id):
            return (.patch, "/channels/\(id.idString)")
            
        case let .deleteChannel(id):
            return (.delete, "/channels/\(id.idString)")
            
        case let .getChannelMessages(id):
            return (.get, "/channels/\(id.idString)/messages")
            
        case .getCurrentUser:
            return (.get, "/users/@me")
            
        case let .getUser(id):
            return (.get, "/users/\(id.idString)")
            
        }
    }
}
