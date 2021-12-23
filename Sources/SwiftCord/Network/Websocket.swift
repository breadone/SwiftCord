//
//  Websocket.swift
//  
//
//  Created by Pradyun Setti on 22/12/21.
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
        self.webSocket = session.webSocketTask(with: url)
        self.webSocket.resume()
    }
    
    internal func ping() {
        self.webSocket.sendPing { error in
            if let error = error {
                print("[WEBSOCKET ERROR]: Ping Error: \(error.localizedDescription)")
            } else {
                print("socket is alive ig")
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    self.ping()
                }
            }
        }
    }

}

// MARK: WSDelegate Conformance
extension Websocket: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("\n\nsession opened\n\n")
        self.ping()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("\n\nsession closed\n\n")
    }
}
