//
//  Endpoint.swift
//  GoldenRetriever
//
//  Created by Sam Taylor on 18/12/2018.
//

import Foundation

public protocol Endpoint {
    var baseAddress: URL { get }
    var info: EndpointInfo { get }
}

public extension Endpoint {
    var url: URL? {
        if var urlComponents = URLComponents(url: baseAddress, resolvingAgainstBaseURL: true) {
            if let pathComponents = URLComponents(string: urlComponents.path + info.path) {
                urlComponents.path = pathComponents.path
                urlComponents.query = pathComponents.query
            }
            urlComponents.queryItems = info.parameters?.map { (key, value) -> URLQueryItem in
                return URLQueryItem(name: key, value: value ?? "")
            }
            return urlComponents.url
        }
        return nil
    }
}
