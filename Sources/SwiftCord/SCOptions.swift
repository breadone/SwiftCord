//
//  SCOptions.swift
//  
//
//  Created by Pradyun Setti on 24/12/21.
//

import Foundation

public struct SCOptions {
    public static let `default` = SCOptions()
    
    /// The verison of Discord api to use. Should be kept default *most* of the time
    public var discordApiVersion: Int = 9
}
