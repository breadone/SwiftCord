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
        
        let cryaboutit = Command(name: "cry", description: "Hurt The Bot.", type: .slashCommand) { _ in
            return "https://tenor.com/view/neco-arc-gif-22980190"
        }

        let viewSource = Command(name: "source", description: "View SwiftCord source code", type: .slashCommand) { _ in
            return "https://github.com/breadone/SwiftCord"
        }

        let _ = Command(name: "test", description: "test", type: .slashCommand, handlerMessage: { info in
            let x = info.user.atUser
            return x
        })

        bot.addCommands(ping, cryaboutit, viewSource)
        bot.connect()

        try? await Task.sleep(nanoseconds: 999 * 1_000_000_000) // 999 min
    }
}
