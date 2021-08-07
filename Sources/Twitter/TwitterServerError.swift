//
//  TwitterServerError.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation

public struct TwitterServerError: Decodable, Error {
    var type: String
    var title: String
    var detail: String
    var reason: String?
}

extension Result: Decodable where Success: Decodable, Failure == TwitterServerError {
    enum CodingKeys: CodingKey {
        case errors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let error = try container.decodeIfPresent(TwitterServerError.self, forKey: .errors) else {
            self = try.success(Success(from: decoder))
            return
        }

        self = .failure(error)
    }
}
