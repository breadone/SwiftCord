import XCTest
@testable import SwiftCord

final class SwiftCordTests: XCTestCase {

    func testWebsocketConnection() {
        let url = URL(string: "wss://echo.websocket.org")!
        
        let _ = Websocket(url: url)
        
    }
    
    func testEncoding() {
        let packet = Payload(op: Opcode.dispatch.rawValue, d: ["test": .int(3)])
        let c = JSONEncoder()
        print(String(data: try! c.encode(packet), encoding: .utf8)!)
    }
}
