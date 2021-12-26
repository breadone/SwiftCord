import XCTest
@testable import SwiftCord

final class SwiftCordTests: XCTestCase {
    func testPayloadEncoding() {
        let packet = Payload(opcode: .dispatch, data: ["Hello": 4])
        let data = packet.encode()
        XCTAssertEqual(data, "{\"d\":{\"Hello\":4},\"op\":0}")
    }
    
    func testPayloadDecoding() {
        let json = "{\"t\":null,\"s\":null,\"op\":10,\"d\":{\"heartbeat_interval\":41250}}"
        let packet = Payload(json: json)
        XCTAssertEqual(packet.op, 10)
    }
}
