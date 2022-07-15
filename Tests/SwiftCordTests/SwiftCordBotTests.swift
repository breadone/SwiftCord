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
        
        let optX = CommandOption(.number, name: "x", description: "the x side of the triangle")
        let optY = CommandOption(.number, name: "y", description: "the y side of the triangle")
        
        let pythag = Command(name: "pythagoras",
                             description: "Calculate the hypotenuse of a right-angle triangle",
                             options: [optX, optY]) { info in
            let x = Double(info.getOptionValue(for: "x")!)!
            let y = Double(info.getOptionValue(for: "y")!)!
            
            return Embed(title: "ANSWER", text: "\(hypot(x, y))")
        }
        
        bot.addCommands(to: 715391148096618568, viewSource, pythag)
        
        bot.connect()
        
        try? await Task.sleep(nanoseconds: 999 * 1_000_000_000) // 999 sec
    }
}


