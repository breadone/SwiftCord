//
//  Websocket.swift
//
//
//  (re)Created by Pradyun Setti on 28/12/21.
//

import Foundation

class Websocket: NSObject {
    var url: URL
    private var session: URLSession!
    var webSocket: URLSessionWebSocketTask!
    
    internal init(url: URL) {
        self.url = url
        super.init()
        
        self.setup()
    }
    
    private func setup() {
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        self.webSocket = session.webSocketTask(with: self.url)
    }
    
    public func connect() {
        self.webSocket.resume()
    }
    
    public func send(string: String) {
        self.webSocket.send(.string(string)) { error in
            print(error!.localizedDescription)
        }
    }

}

// MARK: WSDelegate Conformance
extension Websocket: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("[WEBSOCKET]: Connection Resumed")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("[WEBSOCKET]: Connection Closed")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("\(error!)")
    }
}

