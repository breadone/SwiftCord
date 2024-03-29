//
//  SCOptions.swift
//  
//
//  Created by Pradyun Setti on 24/12/21.
//

import Foundation

public struct SCOptions {
    public static let `default` = SCOptions()
    
    /// The verison of Discord api to use. Should be kept default *most* of the time
    public var discordApiVersion: Int = 10
    
    /// Whether the commands being used should be printed to the console
    public var displayCommandMessages: Bool = true
    
    /// Whether to show [WRN] messages
    public var displayWarningMessages: Bool = true
    
    /// Whether to show currently unsupported events that are recieved through the websocket
    public var displayEvents: Bool = false
    
    /// Whether to show responses from network requests, can help debugging SC Source, not very useful otherwise
    public var displayNetworkResponses: Bool = false
}
