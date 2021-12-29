import XCTest
@testable import SwiftCord

final class SwiftCordTests: XCTestCase {
    func testPayloadEncoding() {
        let packet = Payload(opcode: .dispatch, data: ["Hello": 4])
        let data = packet.encode()
        XCTAssertEqual(data, "{\"op\":0,\"d\":{\"Hello\":4}}")
    }
    
    func testPayloadDecoding() {
        let json = "{\"t\":null,\"s\":null,\"op\":10,\"d\":{\"heartbeat_interval\":41250}}"
        let packet = Payload(json: json)
        XCTAssertEqual(packet.op, 10)
    }
    
    func testBotConnection() async {
        let bot = SCBot(token: "NzE1MDk2NTA4ODAxODc1OTkw.Xs4PhQ.LkkU8ocfzzIWOLv9DaCCZDwkdxA", intents: 8)
        bot.connect()
        try? await Task.sleep(nanoseconds: 30 * 1_000_000_000)
    }
}
