//
// Created by Pradyun Setti on 30/03/22.
//

import Foundation

protocol ArrayRepresentable: JSONEncodable {
    var arrayRepresentation: JSONObject { get set }
}
