//
//  TwitterServerError.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation

public struct TwitterServerError: Decodable, Error {
    public var type: String
    public var title: String
    public var detail: String
    public var reason: String?
    public var value: String?
}

extension TwitterServerError: LocalizedError {
    public var errorDescription: String? {
        title
    }

    public var failureReason: String? {
        detail
    }

    public var recoverySuggestion: String? {
        reason
    }
}
