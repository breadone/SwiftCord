import XCTest
@testable import SwiftCord

final class SwiftCordTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(SwiftCord().text, "Hello, World!")
    }
    
    func testWebsocketConnection() throws {
        let url = "wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self"
        let socket = Websocket(url: url)
    }
    
    func testEncoding() {
        let packet = Payload(op: Opcode.dispatch.rawValue, d: ["test": .int(3)])
        let c = JSONEncoder()
        print(String(data: try! c.encode(packet), encoding: .utf8))
    }
}
