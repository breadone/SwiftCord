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
            
            return Embed(title: "ANSWER",
                         text: "\(hypot(x, y))",
                         image: Image("https://c.tenor.com/DAmqckZoTGwAAAAC/duongcam1621-cat.gif"))
        }
        
        
        let optX2 = CommandOption(.number, name: "a", description: "the x^2 value")
        let optX1 = CommandOption(.number, name: "b", description: "the x value")
        let optN = CommandOption(.number, name: "c", description: "the constant value")
        
        let quadratic = Command(name: "quadratic",
                                description: "calculates the root of a quadratic",
                                options: [optX2, optX1, optN]) { info in
            let a = Double(info.getOptionValue(for: "a")!) ?? 0
            let b = Double(info.getOptionValue(for: "b")!) ?? 0
            let c = Double(info.getOptionValue(for: "c")!) ?? 0
            
            let num1 = (-1 * b) + sqrt(pow(b, 2) - -4*a*c)
            let num2 = (-1 * b) - sqrt(pow(b, 2) - -4*a*c)
            
            let dom = 2*a
            
            var ans = Embed(title: "\(a)x² + \(b)x + \(c) = 0")
            ans.addField(title: "x1", text: "\(num1/dom)")
            ans.addField(title: "x2", text: "\(num2/dom)")
            
            return ans
        }
        
        bot.addCommands(to: 715391148096618568, pythag)
        
//        bot.connect()
        
        try? await Task.sleep(nanoseconds: 999 * 1_000_000_000) // 999 sec
    }
}


