//
//  SwiftCordExtraTests.swift
//  
//
//  Created by Pradyun Setti on 7/08/22.
//

import XCTest
@testable import SwiftCord

class SwiftCordExtraTests: XCTestCase {
    let a = A()
    
    func testEvents() {
        a.on("sc.new") { print($0) }
        
        a.sendEvent("sc.new", info: "cum")
    }

}


class A {
    public init() {}
    
    var interactions = [String: [(String) -> Void]]()
    
    func on(_ event: String, _ handler: @escaping (String) -> Void) {
        if interactions[event] != nil {
            interactions[event]?.append(handler)
        } else {
            interactions[event] = [handler]
        }
    }
    
    func sendEvent(_ name: String, info: String) {
        for x in self.interactions[name] ?? [] {
            x(info)
        }
    }
}
