//
//  User.swift
//  
//
//  Created by 강재홍 on 2022/04/27.
//

import Foundation
import TwitterCore

public struct User {
    public let id: Int64
    public let name: String
    public let screenName: String

    public let location: String?
    public let url: URL?
    public let userDescription: String?

    public let urlEntities: Entities
    public let userDescriptionEntities: Entities

    public let isProtected: Bool
    public let isVerified: Bool

    public let followersCount: Int
    public let friendsCount: Int
    public let listedCount: Int
    public let favouritesCount: Int
    public let statusesCount: Int

    public let createdAt: Date

    public let profileBannerURL: URL?
    public let profileImageURL: URL?
}

extension User {
    public var profileImageOriginalURL: URL? {
        profileImageURL.flatMap {
            $0
                .deletingLastPathComponent()
                .appendingPathComponent($0.lastPathComponent.replacingOccurrences(of: "_normal.", with: "."))
        }
    }
}

extension User {
    public var profileBannerOriginalURL: URL? {
        profileBannerURL.flatMap {
            $0.appendingPathComponent("1500x500")
        }
    }
}

extension User {
    public var expandedURL: URL? {
        return url.flatMap { url in
            let urlEntities = urlEntities.urls

            return URL(
                string: urlEntities.reduce(into: url.absoluteString) {
                    if let range = $0.range(of: $1.urlString), let expandedURL = $1.expandedURL {
                        $0.replaceSubrange(range, with: expandedURL.absoluteString)
                    }
                }
            )
        }
    }

    public var attributedDescription: AttributedString? {
        return attributedDescription {
            var link = AttributedString($0.urlStringForDisplay ?? $0.urlString)
            link[link.startIndex..<link.endIndex].link = $0.expandedURL ?? URL(string: $0.urlString)
            return link
        }
    }

    public func attributedDescription(_ urlEntityHandler: (URLEntity) -> AttributedString) -> AttributedString? {
        guard let userDescription = userDescription else { return nil }

        var attributedDescription = AttributedString(userDescription)

        userDescriptionEntities.urls.forEach {
            if let range = attributedDescription.range(of: $0.urlString) {
                attributedDescription.replaceSubrange(range, with: urlEntityHandler($0))
            }
        }

        return attributedDescription
    }
}

extension User: Identifiable { }

extension User: Decodable {
    private struct UserEntities: Decodable {
        let url: Entities?
        let description: Entities?
    }

    private enum EntitiesCodingKeys: String, CodingKey {
        case url
        case description
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case screenName = "screen_name"

        case location
        case url
        case userDescription = "description"

        case entities

        case isProtected = "protected"
        case isVerified = "verified"

        case followersCount = "followers_count"
        case friendsCount = "friends_count"
        case listedCount = "listed_count"
        case favouritesCount = "favourites_count"
        case statusesCount = "statuses_count"

        case createdAt = "created_at"

        case profileBannerURL = "profile_banner_url"
        case profileImageURL = "profile_image_url_https"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int64.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.screenName = try container.decode(String.self, forKey: .screenName)

        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.url = try? container.decode(URL.self, forKey: .url)
        self.userDescription = try container.decode(String.self, forKey: .userDescription)

        let userEntities = try container.decodeIfPresent(UserEntities.self, forKey: .entities)
        self.userDescriptionEntities = userEntities?.description ?? Entities(urls: [])
        self.urlEntities = userEntities?.url ?? Entities(urls: [])

        self.isProtected = try container.decode(Bool.self, forKey: .isProtected)
        self.isVerified = try container.decode(Bool.self, forKey: .isVerified)

        self.followersCount = try container.decode(Int.self, forKey: .followersCount)
        self.friendsCount = try container.decode(Int.self, forKey: .friendsCount)
        self.listedCount = try container.decode(Int.self, forKey: .listedCount)
        self.favouritesCount = try container.decode(Int.self, forKey: .favouritesCount)
        self.statusesCount = try container.decode(Int.self, forKey: .statusesCount)

        self.createdAt = try container.decode(Date.self, forKey: .createdAt)

        self.profileBannerURL = try? container.decode(URL.self, forKey: .profileBannerURL)
        self.profileImageURL = try? container.decode(URL.self, forKey: .profileImageURL)
    }
}
