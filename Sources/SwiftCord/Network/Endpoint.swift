//
//  Endpoint.swift
//  
//
//  Created by Pradyun Setti on 23/12/21.
//

import Foundation

internal enum Endpoint {
    case gateway
    
}

extension Endpoint {
    
    var url: String {
        switch self {
        case .gateway:
            return ""
        }
    }
}
