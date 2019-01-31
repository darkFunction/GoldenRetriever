//
//  MockEndpoint.swift
//  GoldenRetrieverTests
//
//  Created by Sam Taylor on 31/01/2019.
//

import Foundation
@testable import GoldenRetriever

enum MockEndpoint: Endpoint {
    var baseAddress: URL {
        return URL(string: "https://example.com")!
    }
    
    case tickets(param1: String?, param2: String?)
    case basicAuthProtected
    
    var info: EndpointInfo {
        switch self {
        case .tickets(let param1, let param2):
            return .get(path: "/tickets", parameters: ["param1": param1, "param2": param2])
        case .basicAuthProtected:
            return .get(path: "/basicAuthProtected", parameters: nil, body: nil, credentials: .basicAuth(username: "Golden", password: "Retreiver"))
        }
    }
}

struct TestResponse: Codable {
    let something: String
}

struct TestBackendError: BackendErrorResponse {
    let reason: String
}
