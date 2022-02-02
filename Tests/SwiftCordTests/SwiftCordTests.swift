import XCTest
@testable import SwiftCord

fileprivate func getToken() -> String {
    do {
        return try String(contentsOfFile: "\(NSHomeDirectory())/Code/SwiftCord/Tests/SwiftCordTests/token.txt")
    } catch {
        print(error.localizedDescription)
        return "oops"
    }
}

final class SCBotTests: XCTestCase {
    func testBotConnection() async {
        let bot = SCBot(token: getToken(), intents: 1 << 16)
        bot.presence = SCPresence(status: .idle, activity: "Star Citizen", activityType: .playing)
        bot.connect()
        try? await Task.sleep(nanoseconds: 120 * 1_000_000_000)
    }
}

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
    
    func testPresenceCoding() {
        let data: JSONObject = [
            "token": "aaaaaa",
            "properties": [
                "$os": "macOS",
                "$browser": "SwiftCord",
                "$device": "SwiftCord"
            ],
            "presence": SCPresence(status: .online, activity: "Star Citizen").arrayRepresentation,
            "compress": false,
            "intents": 8
        ]
        
        let p = Payload(opcode: .identify, data: data).encode()
//        let x = Payload(json: p)
        print(p)
    }
    
    func testUserDecoding() {
        var json: String {
            """
            {\"t\":\"READY\",
            \"s\":1,
            \"op\":0,
            \"d\":
                {\"v\":9,
                \"user_settings\":{},
                \"user\":
                    {\"verified\":true,
                        \"username\":\"horse\",
                        \"mfa_enabled\":false,
                        \"id\":\"715096508801875990\",
                        \"flags\":0,
                        \"email\":null,
                        \"discriminator\":\"1507\",
                        \"bot\":true,
                        \"avatar\":\"fe495c61c9996bc211ecf4ab33556bbb\"
                    },
                \"session_id\":\"349f876db839707a7cb6288a418543ab\",
                \"relationships\":[],
                \"private_channels\":[],
                \"presences\":[],
                \"guilds\":[
                    {\"unavailable\":true,\"id\":\"608227026113134601\"},
                    {\"unavailable\":true,\"id\":\"715391148096618568\"}
                ],
                \"guild_join_requests\":[],
                \"geo_ordered_rtc_regions\":[\"sydney\",\"singapore\",\"japan\",\"hongkong\",\"santiago\"],
                \"application\":{
                    \"id\":
                    \"715096508801875990\",
                    \"flags\":827392
                }
            }
            """
        }
        
        var newnew: String {
            "{\"t\":\"READY\",\"s\":1,\"op\":0,\"d\":{\"v\":9,\"user_settings\":{},\"user\":{\"verified\":true,\"username\":\"horse\",\"mfa_enabled\":false,\"id\":\"715096508801875990\",\"flags\":0,\"email\":null,\"discriminator\":\"1507\",\"bot\":true,\"avatar\":\"fe495c61c9996bc211ecf4ab33556bbb\"},\"session_id\":\"4507d5e898c42002413c3a76e3bec9c7\",\"relationships\":[],\"private_channels\":[],\"presences\":[],\"guilds\":[{\"unavailable\":true,\"id\":\"608227026113134601\"},{\"unavailable\":true,\"id\":\"715391148096618568\"}],\"guild_join_requests\":[],\"geo_ordered_rtc_regions\":[\"sydney\",\"singapore\",\"japan\",\"hongkong\",\"santiago\"],\"application\":{\"id\":\"715096508801875990\",\"flags\":827392},\"_trace\":[\"[\"gateway-prd-main-nb20\",{\"micros\":105096,\"calls\":[\"discord-sessions-green-prd-2-19\",{\"micros\":90394,\"calls\":[\"start_session\",{\"micros\":75223,\"calls\":[\"api-prd-main-fhkl\",{\"micros\":67383,\"calls\":[\"get_user\",{\"micros\":8899},\"add_authorized_ip\",{\"micros\":12340},\"get_guilds\",{\"micros\":12337},\"coros_wait\",{\"micros\":2}]}]},\"guilds_connect\",{\"micros\":2,\"calls\":[]},\"presence_connect\",{\"micros\":7711,\"calls\":[]}]}]}]\"]}}"
        }
        
        let p = Payload(json: newnew)
        print(p)
        
//        let object = newnew.decode()
//        print(object)
    }
}
