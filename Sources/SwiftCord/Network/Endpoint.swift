//
//  Endpoint.swift
//  
//
//  Created by Pradyun Setti on 23/12/21.
//

import Foundation

public enum Endpoint {
    case gateway
    
    case custom(HTTPMethod, String)
    
    // MARK: Channel
    case getChannel(Snowflake)
    case modifyChannel(Snowflake)
    case deleteChannel(Snowflake)
    case getChannelMessages(Snowflake)
    case createMessage(Snowflake)
    
    // MARK: User
    case getCurrentUser
    case getUser(Snowflake)
    
    // MARK: Interaction
    case createCommand(Int)
    case deleteCommand(Int)
    case replyToInteraction(Snowflake, String)
}

extension Endpoint {
    var info: (method: HTTPMethod, url: String) {
        switch self {
        case let .custom(method, url):
            return (method, url)
            
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
            
        case let .createMessage(id):
            return (.post, "/channels/\(id.idString)/messages")
            
        case .getCurrentUser:
            return (.get, "/users/@me")
            
        case let .getUser(id):
            return (.get, "/users/\(id.idString)")
            
        case let .createCommand(appID):
            return (.post, "/applications/\(appID)/commands")
            
        case let .deleteCommand(appID):
            return (.delete, "/applications/\(appID)/commands")
            
        case let .replyToInteraction(interactionID, interactionToken):
            return (.post, "/interactions/\(interactionID.idString)/\(interactionToken)/callback")
            
        }
    }
}
