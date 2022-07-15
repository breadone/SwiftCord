import XCTest
@testable import SwiftCord
import SwiftyJSON


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
        let opts = CommandOption(.user, name: "user",
                                 description: "idk",
                                 required: true,
                                 choices: [(label: "breadone", value: "breadone"), (label: "dfk", value: "dfk")])

        let pingThem = Command(name: "hello", description: "Ping the user", options: [opts]) { info in
            return info.user.atUser
        }
        
        print(String(data: try! JSONSerialization.data(withJSONObject: pingThem.arrayRepresentation, options: .fragmentsAllowed), encoding: .utf8)!)
        
    }
    
    func testEmbedEncoding() {
        var e = Embed(title: "funny moment", text: "aaaaaaa")
        e.addField(title: "field1", text: "field2")
        
        print(["embeds": [e.arrayRepresentation], "tts": false].encode())
    }
}
