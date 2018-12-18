//
//  Client.swift
//  Ticket Samaritan
//
//  Created by Sam Taylor on 23/11/2018.
//  Copyright © 2018 Sam Taylor. All rights reserved.
//

import Foundation

public struct Client<EndpointType: Endpoint, ErrorResponseType: BackendErrorResponse> {
    public typealias NetworkCompletion = (GRError?, Data?)
    public typealias DataTransform<T> = (Data) throws -> T
    public typealias TransformedResponse<T> = (T) -> Void
    public typealias FailureBlock = (GRError) -> Void
    
    public init() {}

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
    
    private func fetchData<T>(endpoint: EndpointType, credentials: EndpointInfo.Credentials? = nil, transform: @escaping DataTransform<T>, success: @escaping TransformedResponse<T>, failure: @escaping FailureBlock) {
        request(endpoint) { (data, response, error) in
            let callback: () -> Void
            if let data = data, error == nil {
                do {
                    let response: T = try transform(data)
                    callback = { success(response) }
                } catch {
                    do {
                        let errorResponse: ErrorResponseType = try data.fromJSON()
                        callback = { failure(GRError.custom(reason: errorResponse.reason)) }
                    } catch {
                        callback = { failure(GRError.custom(reason: error.localizedDescription)) }
                    }
                }
            } else {
                callback = { failure(error == nil ? GRError.unknown : GRError.custom(reason: error!.localizedDescription)) }
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
                    completion?(nil, nil, GRError.encoding)
                    return
                }
            }
            if let credentials = endpoint.info.credentials {
                request.setValue(credentials.headerValue(), forHTTPHeaderField: "Authorization")
            }
            request.request(completion: completion)
        } else {
            completion?(nil, nil, GRError.malformedUrl)
        }
    }
    
    private func setBody(_ body: EndpointInfo.BodyData, on request: inout URLRequest) throws {
        switch body {
        case .json(let value):
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = try value.toJSON()
        case .raw(let data):
            request.httpBody = data
        }
    }
}

public enum GRError: Error {
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

public extension URLRequest {
    public typealias Response = (Data?, URLResponse?, Error?) -> Void
    
    func request(completion: Response? = nil) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: self) { (data, response, error) in
            completion?(data, response, error)
            }.resume()
    }
}

public protocol BackendErrorResponse: Codable {
    var reason: String { get }
}

