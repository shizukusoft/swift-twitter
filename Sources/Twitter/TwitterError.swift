//
//  File.swift
//  File
//
//  Created by Jaehong Kang on 2021/07/30.
//

import Foundation

public enum TwitterError: Error {
    public enum ServerErrorPayload: Error {
        case error(TwitterServerError)
        case string(String)
    }

    case unknown
    case serverError(ServerErrorPayload? = nil, urlResponse: URLResponse)
    case dataCorrupted

    static func serverError(data: Data, urlResponse: URLResponse) -> Self {
        if let error = try? JSONDecoder.twt_default.decode(TwitterServerError.self, from: data) {
            return .serverError(.error(error), urlResponse: urlResponse)
        } else if let string = String(data: data, encoding: .utf8) {
            return .serverError(.string(string), urlResponse: urlResponse)
        } else {
            return .serverError(nil, urlResponse: urlResponse)
        }
    }
}
