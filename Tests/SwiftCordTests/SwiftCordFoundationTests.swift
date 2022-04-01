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
        let cmdOpts = CommandOption(.string,
                                    name: "why",
                                    description: "bruh",
                                    choices: (name: "WHY", value: "BRUHHH"), (name: "are you serious", value: "hm"))
        
        let cmd = Command(name: "test", description: "desc", options: [cmdOpts]) { info in
            return info.user.atUser
        }
        
        print(String(data: try! JSONSerialization.data(withJSONObject: cmd.arrayRepresentation), encoding: .utf8)!)
        
    }
}
