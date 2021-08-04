//
//  MentionEntity.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/04.
//

import Foundation

public struct MentionEntity: Entity {
    public let range: Range<Int>
    public let username: String
}

extension MentionEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case start
        case end
        case username
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.range = try container.decode(Int.self, forKey: .start)..<container.decode(Int.self, forKey: .end)
        self.username = try container.decode(String.self, forKey: .username)
    }
}
