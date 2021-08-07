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
    public let expandedURL: URL?
    public let urlStringForDisplay: String?
}

extension URLEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case start
        case end
        case url
        case expandedURL = "expanded_url"
        case urlStringForDisplay = "display_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.range = try container.decode(Int.self, forKey: .start)..<container.decode(Int.self, forKey: .end)
        self.url = try container.decode(URL.self, forKey: .url)
        self.expandedURL = try container.decodeIfPresent(URL.self, forKey: .expandedURL)
        self.urlStringForDisplay = try container.decodeIfPresent(String.self, forKey: .urlStringForDisplay)
    }
}
