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
        let opt = Command.CommandOption(type: 0, name: "opt", description: "optd", req: true, choices: 0)
        let cmd = Command(name: "test", description: "desc", type: .slashCommand ) { _ in }
        
        print(String(data: try! JSONSerialization.data(withJSONObject: cmd.arrayRepresentation), encoding: .utf8)!)
        
    }
}
