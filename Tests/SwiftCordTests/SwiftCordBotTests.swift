//
// Created by Pradyun Setti on 29/03/22.
//

import XCTest
@testable import SwiftCord
import SwiftyJSON

fileprivate func getToken() -> String {
    do {
        return try String(contentsOfFile: "\(NSHomeDirectory())/Code/Swift/SwiftCord/Tests/SwiftCordTests/token.txt")
    } catch {
        fatalError(error.localizedDescription)
    }
}


final class SCBotTests: XCTestCase {
    func testBot() async {
        let bot = SCBot(token: getToken(), appId: 715096508801875990, intents: 1 << 16)
        bot.presence = SCPresence(status: .idle, activity: "And Waiting.", activityType: .watching)
//        bot.options = SCOptions(displayCommandMessages: false)
        
        
        bot.addCommand("source", desc: "view swiftcord source code", guild: 715391148096618568) { _ in
            return "https://github.com/breadone/SwiftCord"
        }
        
        bot.addCommand("bot", desc: "swana", guild: 715391148096618568) { info in
            return "bot swana"
        }
        
        
        
//        bot.connect()
        
        try? await Task.sleep(nanoseconds: 999 * 1_000_000_000) // 999 sec
    }
}


