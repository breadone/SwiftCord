//
//  Error.swift
//  
//
//  Created by Pradyun Setti on 27/12/21.
//

import Foundation

public enum SCError: Error {
    case badToken
}

extension SCError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badToken:
            return "Invalid Bot token."
        }
    }
}
