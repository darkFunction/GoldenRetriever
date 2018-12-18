//
//  EndpointInfo.swift
//  GoldenRetriever
//
//  Created by Sam Taylor on 18/12/2018.
//

import Foundation

public struct EndpointInfo {
    public typealias Parameters = [String: String?]
    
    let method: HTTPMethod
    let path: String
    let parameters: Parameters?
    let body: BodyData?
    let credentials: Credentials?
    
    init(method: HTTPMethod, path: String, parameters: Parameters? = nil, body: BodyData? = nil, credentials: Credentials? = nil) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.body = body
        self.credentials = credentials
    }
    
    // Convenience initializers
    
    public static func get(path: String,  parameters: Parameters? = nil, body: BodyData? = nil, credentials: Credentials? = nil) -> EndpointInfo {
        return EndpointInfo.init(method: .GET, path: path, parameters: parameters, body: body, credentials: credentials)
    }
    
    public static func post(path: String,  parameters: Parameters? = nil, body: BodyData? = nil, credentials: Credentials? = nil) -> EndpointInfo {
        return EndpointInfo.init(method: .POST, path: path, parameters: parameters, body: body, credentials: credentials)
    }
}

// MARK: Namespaced types

public extension EndpointInfo {
    public enum Credentials {
        case basicAuth(username: String, password: String)
        case bearerToken(_: String)
        
        public func headerValue() -> String {
            switch self {
            case .basicAuth(let username, let password):
                let base64String = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
                return "Basic \(base64String)"
            case .bearerToken(let token):
                return "Bearer \(token)"
            }
        }
    }
    
    public enum HTTPMethod: String {
        case GET
        case POST
    }
    
    public enum BodyData {
        case json(_: Codable)
        case raw(_: Data)
    }
}
