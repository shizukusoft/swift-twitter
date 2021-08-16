//
//  Tweet.swift
//  Tweet
//
//  Created by Jaehong Kang on 2021/08/15.
//

import Foundation

public struct Tweet {
    public let id: String
    
    public let text: String
    
    public let createdAt: Date
}

extension Tweet: Hashable {}
extension Tweet: Identifiable {}

extension Tweet: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, text
        case createdAt = "created_at"
    }
}
