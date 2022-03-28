import XCTest
@testable import SwiftCord
import SwiftyJSON

fileprivate func getToken() -> String {
    do {
        return try String(contentsOfFile: "\(NSHomeDirectory())/Code/SwiftCord/Tests/SwiftCordTests/token.txt")
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
        
        let pingUser = Command(name: "pingUser", description: "ping specified user", type: .slashCommand) { info in
            return "You. <@\(info.user.id)>."
        }
        
        bot.registerCommand(ping)
        bot.registerCommand(pingUser)
        
        bot.connect()
//        bot.replyToMessage(Snowflake(uint64: 715391148096618571), message: Snowflake(uint64: 939483073488236554), message: "You Think Commands Will Work On Me.")
        
//        bot.sendMessage(Snowflake(uint64: 715391148096618571), message: "Alive.")
        
        try? await Task.sleep(nanoseconds: 999 * 1_000_000_000) // 999 min
    }
}

final class SCFoundationTests: XCTestCase {
    func testPayloadEncoding() {
        let packet = Payload(opcode: .dispatch, data: ["Hello": 4, "hmm": ["test": 5]])
        let data = packet.encode()
        print(data)
//        XCTAssertEqual(data, "{\"op\":0,\"d\":{\"Hello\":4}}")
    }
    
    func testPayloadDecoding() {
        let json = "{\"t\":null,\"s\":null,\"op\":10,\"d\":{\"heartbeat_interval\":41250}}"
        let packet = Payload(json: json)
        XCTAssertEqual(packet.op, 10)
    }
    
    func testCommandEncoding() {
        let opt = Command.CommandOption(type: 0, name: "opt", description: "optd", req: true, choices: 0)
        let cmd = Command(name: "test", description: "desc", type: .slashCommand, options: [opt]) { _ in }
        
        print(cmd.arrayRepresentation.encode())
    }
    
    func testFileWrite() {
        CMDFile.writeCommandsFile([
            Command(name: "one", description: "ondesc", type: .message, handler: {_ in}).arrayRepresentation,
            Command(name: "two", description: "twodesc", type: .slashCommand, handler: {_ in}).arrayRepresentation
        ].encode())
    }
    
    func testFileRead() {
        let cs = CMDFile.readCommandsFile()
        for c in cs {
            print(c.name, c.description)
        }
    }
}
