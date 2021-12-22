//
//  Websocket.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
//

import Foundation

class Websocket: NSObject, URLSessionWebSocketDelegate {
    let url: URL
    
    internal init(url: String) {
        self.url = URL(string: url) ?? URL(string: "discord.com/api")!
    }
    
    
}
