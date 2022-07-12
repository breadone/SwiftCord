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
                                 choices: (name: "breadone", value: "breadone"), (name: "dfk", value: "dfk"))

        let pingThem = Command(name: "hello", description: "Ping the user", options: [opts]) { info in
            return info.user.atUser
        }
        
        print(String(data: try! JSONSerialization.data(withJSONObject: pingThem.arrayRepresentation, options: .fragmentsAllowed), encoding: .utf8)!)
        
    }
    
    func testTest() {
        let ping = Command(name: "ping", description: "what do you think", type: .slashCommand) { _ in
            return "pong"
        }
        
        let cryaboutit = Command(name: "cry", description: "Hurt The Bot.", type: .slashCommand) { _ in
            return "https://tenor.com/view/neco-arc-gif-22980190"
        }

        let viewSource = Command(name: "source", description: "View SwiftCord source code", type: .slashCommand) { _ in
            return "https://github.com/breadone/SwiftCord"
        }
        
        let opts = CommandOption(.user, name: "User",
                                 description: "idk",
                                 required: true,
                                 choices: (name: "breadone", value: "breadone"), (name: "dfk", value: "dfk"))
        
        let pingThem = Command(name: "you", description: "Ping the user", options: [opts]) { info in
            return info.user.atUser
        }
        
        let commands = [ping, cryaboutit, viewSource, pingThem]
        var cmds = [JSONObject]()
        commands.forEach { command in
            cmds.append(command.arrayRepresentation)
        }

        let content = cmds.encode()
        print(content)
    }
}
