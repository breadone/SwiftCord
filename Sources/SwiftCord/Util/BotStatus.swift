//
//  BotStatus.swift
//  
//
//  Created by Pradyun Setti on 29/03/22.
//

import Foundation

extension SCBot {
    public enum BotMessageStatus: String {
        case genericStatus = "BOT"
        case warning = "WRN"
        case genericError = "ERR"
        case event = "EVT"
        case websocket = "WEB"
        case command = "CMD"
        case saveFile = "SAV"
    }
    
    public func botStatus(_ status: BotMessageStatus, message: String) {
        if status == .warning && self.options.displayWarningMessages {
            print("[\(status.rawValue)] \(message)")
        } else {
            print("[\(status.rawValue)] \(message)")
        }
        
    }
}
