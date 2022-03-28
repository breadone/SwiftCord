//
//  BotStatus.swift
//  
//
//  Created by Pradyun Setti on 29/03/22.
//

import Foundation

public enum BotMessageStatus: String {
    case genericStatus = "BOT"
    case genericError = "ERR"
    case event = "EVT"
    case websocket = "WEB"
    case command = "CMD"
    case saveFile = "SAV"
}

public func printBotStatus(_ status: BotMessageStatus, message: String) {
    print("[\(status.rawValue)] \(message)")
}
