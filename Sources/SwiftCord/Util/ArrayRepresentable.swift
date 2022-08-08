//
// Created by Pradyun Setti on 30/03/22.
//

import Foundation
import SwiftyJSON

public protocol ArrayRepresentable: JSONEncodable {
    var arrayRepresentation: JSON { get }
}
