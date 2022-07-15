//
//  SCBot+Network.swift
//  
//
//  Created by Pradyun Setti on 3/03/22.
//

import Foundation

extension SCBot {
    /// Makes the network requests to Discord's API
    /// - Parameters:
    ///   - endpoint: Which API Endpoint to request
    ///   - params: Any HTTP Parameters to add to the request
    ///   - auth: Whether authorisation is enabled (Recommended true)
    /// - Returns: API Response as a dictionary
    @discardableResult
    public func request(
        _ endpoint: Endpoint,
        urlParams: [String: Any]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        auth: Bool = true
    ) async throws -> JSONObject {
        // Step one: get url string and add all the params
        var urlString = "https://discord.com/api/v\(options.discordApiVersion)\(endpoint.info.url)"
        
        if let params = urlParams {
            urlString.append("?")
            urlString += params.map { "\($0)=\($1)" }.joined(separator: "&")
        }
        
        // Step two: make url
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.info.method.rawValue
        
        if auth {
            request.addValue("Bot \(self.botToken)", forHTTPHeaderField: "Authorization")
        }
        
        if let headers = headers {
            for (header, value) in headers {
                request.addValue(value, forHTTPHeaderField: header)
            }
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let session = URLSession(configuration: .default)
            let (data, urlresponse) = try await session.data(for: request)
            let response = urlresponse as? HTTPURLResponse
            
            switch response?.statusCode { // probably more to come idk
            case 400: // bad request
                throw  URLError(.unsupportedURL)
            case 401: // unauthorised
                throw SCError.badToken
            case 404: // not found
                throw URLError(.badURL)
            default:
                break
            }
            
            return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? JSONObject ?? [:]
        } catch {
            throw error
        }
        
    }
    
    internal func heartbeat() async {
        try? await Task.sleep(nanoseconds: UInt64(heartbeatInterval * 1_000_000))
        
        self.socket.write(string: Payload(opcode: .heartbeat).encode())
    }
    
}
