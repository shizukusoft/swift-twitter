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

    public let isProtected: Bool
    public let isVerified: Bool

    public let followersCount: Int
    public let friendsCount: Int
    public let listedCount: Int
    public let favouritesCount: Int
    public let statusesCount: Int

    public let createdAt: Date

    public let profileBannerURL: URL?
    public let profileImageURL: URL
}

extension User {
    public var profileImageOriginalURL: URL? {
        profileImageURL
            .deletingLastPathComponent()
            .appendingPathComponent(profileImageURL.lastPathComponent.replacingOccurrences(of: "_normal.", with: "."))
    }
}

extension User {
    public var profileBannerOriginalURL: URL? {
        profileBannerURL.flatMap {
            $0.appendingPathComponent("1500x500")
        }
    }
}

extension User: Identifiable { }

extension User: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case screenName = "screen_name"

        case location
        case url
        case userDescription = "description"

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
}
