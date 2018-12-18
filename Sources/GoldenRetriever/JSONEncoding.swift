//
//  JSONEncoding.swift
//  GoldenRetriever
//
//  Created by Sam Taylor on 18/12/2018.
//

import Foundation

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

