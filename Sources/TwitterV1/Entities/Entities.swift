//
//  Entities.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/04.
//

import Foundation

public struct Entities {
    public let urls: [URLEntity]
}

extension Entities: Decodable {
    enum CodingKeys: String, CodingKey {
        case urls
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.urls = try container.decodeIfPresent([URLEntity].self, forKey: .urls) ?? []
    }
}
