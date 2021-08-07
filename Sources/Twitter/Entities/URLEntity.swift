//
//  URLEntity.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/04.
//

import Foundation

public struct URLEntity: Entity {
    public let range: Range<Int>
    public let urlString: String
    public let urlStringForDisplay: String?
    public let expandedURL: URL?
}

extension URLEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case start
        case end
        case urlString = "url"
        case urlStringForDisplay = "display_url"
        case expandedURL = "expanded_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.range = try container.decode(Int.self, forKey: .start)..<container.decode(Int.self, forKey: .end)
        self.urlString = try container.decode(String.self, forKey: .urlString)
        self.urlStringForDisplay = try container.decodeIfPresent(String.self, forKey: .urlStringForDisplay)
        self.expandedURL = try container.decodeIfPresent(URL.self, forKey: .expandedURL)
    }
}
