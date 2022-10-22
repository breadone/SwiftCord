//
// Created by Pradyun Setti on 29/03/22.
//

import XCTest
@testable import SwiftCord
import SwiftyJSON

fileprivate func getToken() -> String {
    do {
        return try String(contentsOfFile: "\(NSHomeDirectory())/Documents/token.txt")
    } catch {
        fatalError(error.localizedDescription)
    }
}


final class SCBotTests: XCTestCase {
    func testBot() async {
        let bot = SCBot(token: getToken(), appId: 715096508801875990, intents: [.all])
        bot.presence = SCPresence(status: .idle, activity: "And Waiting.", activityType: .watching)
//        bot.options = SCOptions(displayNetworkResponses: true)
        
        
        bot.addCommand("source", desc: "view swiftcord source code") { _ in
            return "https://github.com/breadone/SwiftCord"
        }
        
        bot.addCommand("bot", desc: "swana", guild: 715391148096618568) { info in
            return "swana"
        }
        
        bot.addCommand(type: .user, "pingthem", guild: 588992965007900672) { info in
            return "\(info.targetUser?.atUser ?? "nop") was pinged by \(info.sender.atUser)"
        }
        
        bot.onEvent(.message_component) { info in
            bot.sendMessage(to: 715391148096618571, message: "please i am suffering")
        }
        
        bot.connect()
        
        try? await Task.sleep(nanoseconds: 999 * 1_000_000_000) // 999 sec
    }
}


