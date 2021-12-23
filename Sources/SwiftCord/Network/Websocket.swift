//
//  Websocket.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
//

import Foundation

class Websocket: NSObject, URLSessionWebSocketDelegate, URLSessionDelegate {
    let url: URL
    private let session = URLSession(configuration: .default)//, delegate: self, delegateQueue: OperationQueue())
    let webSocket: URLSessionWebSocketTask?
    
    internal init(url: String) {
        self.url = URL(string: url) ?? URL(string: Endpoint.base)!
        self.webSocket = session.webSocketTask(with: self.url)
        self.webSocket?.resume()
    }

}

// MARK: WSDelegate Conformance
extension Websocket {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?)
    {
        print("opened connection")
    }
    
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?)
    {
        print("closed with: \(String(data: reason!, encoding: .utf8) ?? "hello")")
    }
    
    func ping() {}
    func close() {}
    func receive() {}
}
