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

        let opts = CommandOption(.string, name: "user",
                                 description: "idk",
                                 required: true,
                                 choices: (name: "Breadone", value: "<@439618772337295361>"), (name: "Dfk", value: "<@295795976265007105>"))

        let pingThem = Command(name: "hello", description: "Ping the user", options: [opts]) { info in
            return "Hello \(info.options[0].value)"
        }

        bot.addCommands(ping, cryaboutit, viewSource, pingThem)
        
        do {
            try await bot.request(.createGuildCommand(bot.appID, 715391148096618568),
                                  headers: ["Content-Type": "application/json"],
                                  body: JSONSerialization.data(withJSONObject: pingThem.arrayRepresentation))
        } catch {
            print(error.localizedDescription)
        }
        
        bot.connect()
        
//        bot.sendMessage(Snowflake(string: "715391148096618571"), message: "bot swana")
        try? await Task.sleep(nanoseconds: 999 * 1_000_000_000) // 999 min
    }
}


