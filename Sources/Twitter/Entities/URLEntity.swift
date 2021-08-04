//
//  URLEntity.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/04.
//

import Foundation

public struct URLEntity: Entity {
    public let range: Range<Int>
    public let url: URL
    public let expandedURL: URL
    public let displayURLString: String
}

extension URLEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case start
        case end
        case url
        case expandedURL = "expanded_url"
        case displayURLString = "display_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.range = try container.decode(Int.self, forKey: .start)..<container.decode(Int.self, forKey: .end)
        self.url = try container.decode(URL.self, forKey: .url)
        self.expandedURL = try container.decode(URL.self, forKey: .expandedURL)
        self.displayURLString = try container.decode(String.self, forKey: .displayURLString)
    }
}
