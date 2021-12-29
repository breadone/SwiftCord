//
//  Endpoint.swift
//  
//
//  Created by Pradyun Setti on 23/12/21.
//

import Foundation

internal enum Endpoint {
    case gateway
    
    // Channel
    case getChannel(Snowflake)
    case modifyChannel(Snowflake)
    case deleteChannel(Snowflake)
    case getChannelMessages(Snowflake)
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
        }
        }
}
