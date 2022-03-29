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
        print(error.localizedDescription)
        return "oops"
    }
}

final class SCBotTests: XCTestCase {
    func testBot() async {
        let bot = SCBot(token: getToken(), appId: 715096508801875990, intents: 1 << 16)
        bot.presence = SCPresence(status: .online, activity: "And Waiting.", activityType: .watching)

        let ping = Command(name: "ping", description: "what do you think", type: .slashCommand) { _ in
            return "pong"
        }

        let ping2 = Command(name: "ping2", description: "please", type: .slashCommand) { _ in
            return "HAH"
        }

        bot.addCommands(ping, ping2)
        
        bot.connect()
//        bot.replyToMessage(Snowflake(uint64: 715391148096618571), message: Snowflake(uint64: 939483073488236554), message: "You Think Commands Will Work On Me.")

//        bot.sendMessage(Snowflake(uint64: 715391148096618571), message: "Alive.")

        try? await Task.sleep(nanoseconds: 999 * 1_000_000_000) // 999 min
    }
}
