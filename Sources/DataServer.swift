//
//  DataServer.swift
//  Ticket Samaritan
//
//  Created by Sam Taylor on 23/11/2018.
//  Copyright © 2018 Sam Taylor. All rights reserved.
//

import Foundation

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

public struct EndpointInfo {
    public typealias Parameters = [String: String?]
    
    let method: HTTPMethod
    let path: String
    let params: [String: String?]?
    let body: BodyData?
    let credentials: Credentials?
    
    init(method: HTTPMethod, path: String, params: Parameters? = nil, body: BodyData? = nil, credentials: Credentials? = nil) {
        self.method = method
        self.path = path
        self.params = params
        self.body = body
        self.credentials = credentials
    }
    
    // Convenience initializers
    
    public static func get(path: String,  params: Parameters? = nil, body: BodyData? = nil, credentials: Credentials? = nil) -> EndpointInfo {
        return EndpointInfo.init(method: .GET, path: path, params: params, body: body, credentials: credentials)
    }
    
    public static func post(path: String,  params: Parameters? = nil, body: BodyData? = nil, credentials: Credentials? = nil) -> EndpointInfo {
        return EndpointInfo.init(method: .POST, path: path, params: params, body: body, credentials: credentials)
    }
}

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
            urlComponents.queryItems = info.params?.map { (key, value) -> URLQueryItem in
                 return URLQueryItem(name: key, value: value ?? "")
            }
            return urlComponents.url
        }
        return nil
    }
}

public enum ServerError: Error {
    case malformedUrl
    case unknown
    case encoding
    case custom(reason: String)
    
    public var localizedDescription: String {
        switch self {
        case .malformedUrl:
            return "Malformed request URL"
        case .encoding:
            return "Encoding error"
        case .custom(let reason):
            return reason
        default:
            return "Unknown error"
        }
    }
}

public struct DataServer<EndpointType: Endpoint, ErrorResponseType: ServerErrorResponse> {
    public typealias NetworkCompletion = (ServerError?, Data?)
    public typealias DataTransform<T> = (Data) throws -> T
    public typealias TransformedResponse<T> = (T) -> Void
    public typealias FailureBlock = (ServerError) -> Void
    
    /**
     Requests data from an endpoint and transforms it, finally returning a response of the correct data type
     
     - Parameter endpoint:    An endpoint
     - Parameter transform:   A closure accepting raw Data and returning your desired data type
     - Parameter success:     A closure containing your transformed data
     - Parameter failure:     A closure containing an error
     */
    public func request<T>(_ endpoint: EndpointType, transform: @escaping DataTransform<T>, success: @escaping TransformedResponse<T>, failure: @escaping FailureBlock) {
        fetchData(endpoint: endpoint, transform: transform, success: success, failure: failure)
    }
    
    /**
     Requests data from an endpoint and automatically transforms JSON to a Codable object, finally returning a response of the correct data type
     
     - Parameter endpoint:    An endpoint
     - Parameter credentials: Authentication header credentials
     - Parameter success:     A closure containing your transformed data
     - Parameter failure:     A closure containing an error
     */
    public func request<T: Codable>(_ endpoint: EndpointType, success: @escaping TransformedResponse<T>, failure: @escaping FailureBlock) {
        fetchData(endpoint: endpoint, transform: { (data) throws -> T in
            return try data.fromJSON() as T
        }, success: success, failure: failure)
    }
    
    // MARK: Private
    
    private func fetchData<T>(endpoint: EndpointType, credentials: Credentials? = nil, transform: @escaping DataTransform<T>, success: @escaping TransformedResponse<T>, failure: @escaping FailureBlock) {
        request(endpoint) { (data, response, error) in
            let callback: () -> Void
            if let data = data, error == nil {
                do {
                    let response: T = try transform(data)
                    callback = { success(response) }
                } catch {
                    do {
                        let errorResponse: ErrorResponseType = try data.fromJSON()
                        callback = { failure(ServerError.custom(reason: errorResponse.reason)) }
                    } catch {
                        callback = { failure(ServerError.custom(reason: error.localizedDescription)) }
                    }
                }
            } else {
                callback = { failure(error == nil ? ServerError.unknown : ServerError.custom(reason: error!.localizedDescription)) }
            }
            DispatchQueue.main.async { callback() }
        }
    }
    
    /**
     Get raw data from endpoint
     */
    private func request(_ endpoint: EndpointType, completion: URLRequest.Response? = nil) {
        if let url = endpoint.url {
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.info.method.rawValue
            if let body = endpoint.info.body {
                do {
                    try setBody(body, on: &request)
                } catch {
                    completion?(nil, nil, ServerError.encoding)
                    return
                }
            }
            if let credentials = endpoint.info.credentials {
                request.setValue(credentials.headerValue(), forHTTPHeaderField: "Authorization")
            }
            request.request(completion: completion)
        } else {
            completion?(nil, nil, ServerError.malformedUrl)
        }
    }
    
    private func setBody(_ body: BodyData, on request: inout URLRequest) throws {
        switch body {
        case .json(let value):
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = try value.toJSON()
        case .raw(let data):
            request.httpBody = data
        }
    }
}

public extension URLRequest {
    public typealias Response = (Data?, URLResponse?, Error?) -> Void
    
    func request(completion: Response? = nil) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: self) { (data, response, error) in
            completion?(data, response, error)
            }.resume()
    }
}

public extension Data {
    public func fromJSON<T: Decodable>() throws -> T {
        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(T.self, from: self)
    }
}

public extension Encodable {
    public func toJSON() throws -> Data {
        let jsonEncoder = JSONEncoder()
        return try jsonEncoder.encode(self)
    }
}

public protocol ServerErrorResponse: Codable {
    var reason: String { get }
}

