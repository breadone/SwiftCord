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
        bot.presence = SCPresence(status: .idle, activity: "And Waiting.", activityType: .watching)
        
        let ping = Command(name: "ping", description: "what do you think", type: .slashCommand) { _ in
            return "pong"
        }
        
        //        let cryaboutit = Command(name: "cry", description: "Hurt The Bot.", type: .slashCommand) { _ in
        //            return "https://tenor.com/view/neco-arc-gif-22980190"
        //        }
        
        let viewSource = Command(name: "source", description: "View SwiftCord source code", type: .slashCommand) { _ in
            return "https://github.com/breadone/SwiftCord"
        }
        
        let opts = CommandOption(.string, name: "user",
                                 description: "idk",
                                 required: true,
                                 choices: (name: "breadone", value: "<@439618772337295361>"),
                                          (name: "dfk", value: "<@295795976265007105>"),
                                          (name: "breauxmoment", value: "<@707016264429731870>"))
        
        let pingThem = Command(name: "hello", description: "Ping the user", options: [opts]) { info in
            switch info.options[0].name {
            case "dfk":
                return "Buy Star Citizen \(info.options[0].value)"
            case "breadone":
                return "Hello \(info.options[0].value)"
            case "breauxmoment":
                return "Who the frick are you, \(info.options[0].value)"
            default:
                return "no literally who are you"
            }
        }
        
        bot.addCommands(to: 715391148096618568, pingThem, ping, viewSource)
        
        bot.connect()
        
        //        bot.sendMessage(Snowflake(string: "715391148096618571"), message: "bot swana")
        try? await Task.sleep(nanoseconds: 999 * 1_000_000_000) // 999 sec
    }
}


