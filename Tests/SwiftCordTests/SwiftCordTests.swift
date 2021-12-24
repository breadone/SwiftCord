import XCTest
@testable import SwiftCord

final class SwiftCordTests: XCTestCase {

    func testWebsocketConnection() {
        let url = URL(string: "wss://echo.websocket.org")!
        
        let _ = Websocket(url: url)
        
    }
    
    func testEncoding() {
        let packet = Payload(opcode: .dispatch, data: ["Hello": 4])
        let data = packet.encode()
        print(data)
//        print(String(data: try! JSONSerialization.data(withJSONObject: packet, options: []), encoding: .utf8)!)
    }
}
