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
        
        print(pingThem.arrayRepresentation)
        
    }
    
    func testEmbedEncoding() {
        var e = Embed(title: "funny moment", text: "aaaaaaa")
        e.addField(title: "field1", text: "field2")
        
        print(["embeds": [e.arrayRepresentation], "tts": false].encode())
    }
}

final class SCFileIOTests: XCTestCase {
    let jsonString =
    """
    {
      "type": 1,
      "description": "Ping the user",
      "name": "hello",
      "options": [
        {
          "description": "idk",
          "required": true,
          "choices": [
            {
              "value": "breadone",
              "name": "breadone"
            },
            {
              "value": "dfk",
              "name": "dfk"
            }
          ],
          "name": "user",
          "type": 6
        }
      ]
    }
    """
    
    func testJsonStuff() {
        let json = JSON(parseJSON: jsonString)
        
        print("A: ", json["options"][0]["choices"][0]["name"].stringValue, "\n\n\n")
        print("B: ", json.stringValue)
    }
    
    
    func testFileRead() {
        var cmds = [Command]()
        
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileContent = try? String(contentsOf: path.appendingPathComponent("SCCommands.json"))
            
            print(fileContent!)
            let json = JSON(parseJSON: fileContent ?? "{}")

            for (_, cmd) in json {
                let name: String = cmd["name"].stringValue
                let desc: String = cmd["description"].stringValue
                let id: String = cmd["id"].stringValue
                let guildID: String = cmd["guild_id"].stringValue

                cmds.append(Command(id: Snowflake(string: id),
                                    name: name,
                                    description: desc,
                                    type: .slashCommand,
                                    guildID: Snowflake(string: guildID),
                                    handler: { _ in "" })) // temporary handler, will get replaced on command re-addition
            }
        }
    }
}
