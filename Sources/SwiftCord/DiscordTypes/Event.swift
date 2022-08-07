//
//  Event.swift
//  
//
//  Created by Pradyun Setti on 7/08/22.
//

import Foundation

public enum Event: Equatable, Hashable {
    case identify
    case presenceUpdate
    case ready
    case voiceStateUpdate
    case requestGuildMembers
    case invalidSession
    case hello
    case heartbeatAck
    
    // interaction events
    case slash_command_recieved
    case message_component
    case modal_submit
}
