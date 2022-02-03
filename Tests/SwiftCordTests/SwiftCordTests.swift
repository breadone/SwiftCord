import XCTest
@testable import SwiftCord

fileprivate func getToken() -> String {
    do {
        return try String(contentsOfFile: "\(NSHomeDirectory())/Code/SwiftCord/Tests/SwiftCordTests/token.txt")
    } catch {
        print(error.localizedDescription)
        return "oops"
    }
}

final class SCBotTests: XCTestCase {
    func testBotConnection() async {
        let bot = SCBot(token: getToken(), intents: 1 << 16)
        bot.presence = SCPresence(status: .online, activity: "Star Citizen", activityType: .watching)
        bot.connect()
        try? await Task.sleep(nanoseconds: 120 * 1_000_000_000)
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
    
    func testPresenceCoding() {
        let data: JSONObject = [
            "token": "aaaaaa",
            "properties": [
                "$os": "macOS",
                "$browser": "SwiftCord",
                "$device": "SwiftCord"
            ],
            "presence": SCPresence(status: .online, activity: "Star Citizen").arrayRepresentation,
            "compress": false,
            "intents": 8
        ]
        
        let p = Payload(opcode: .identify, data: data).encode()
//        let x = Payload(json: p)
        print(p)
    }
    
}
