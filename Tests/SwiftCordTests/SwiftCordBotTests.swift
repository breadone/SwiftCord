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
        
        let viewSource = Command(name: "source", description: "View SwiftCord source code", type: .slashCommand) { _ in
            return "https://github.com/breadone/SwiftCord"
        }
        
        let opts = CommandOption(.string, name: "user",
                                 description: "idk",
                                 required: true,
                                 choices: [(label: "breadone", value: "<@439618772337295361>"),
                                          (label: "dfk", value: "<@295795976265007105>"),
                                          (label: "breauxmoment", value: "<@707016264429731870>"),
                                          (label: "aquaduct", value: "<@500453737677193226>")])
        
        let pingThem = Command(name: "hello", description: "Ping the user", options: [opts]) { info in
            switch info.options[0].value {
            case "<@295795976265007105>":
                return "Buy Star Citizen \(info.options[0].value)"
                
            case "<@439618772337295361>":
                return "Hello \(info.options[0].value)"
                
            case "<@707016264429731870>":
                return "Who the frick are you, \(info.options[0].value)"
                
            case "<@500453737677193226>":
                return "aqua duck"
                
            default:
                return "no literally who are you"
            }
        }
        
        bot.addCommands(to: 715391148096618568, pingThem, viewSource)
        
        bot.connect()
        
        let e = Embed(title: "eName", text: "aaaaa")
        bot.sendMessage(to: 715391148096618571, message: e)
        
        //        bot.sendMessage(Snowflake(string: "715391148096618571"), message: "bot swana")
        try? await Task.sleep(nanoseconds: 999 * 1_000_000_000) // 999 sec
    }
}


