//
//  User.swift
//  
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation

public struct User: Identifiable {
    public let id: String
    public let name: String
    public let username: String

    public let protected: Bool
    public let verified: Bool

    public let description: String
    public let descriptionEntities: Entities

    public let url: URL?
    public let urlEntities: Entities

    public let location: String?

    public let createdAt: Date

    public let profileImageURL: URL
}

extension User: Decodable {
    private struct UserEntities: Decodable {
        let url: Entities?
        let description: Entities?
    }

    enum CodingKeys: String, CodingKey {
        case id, name, username, protected, verified, description, url, location
        case entities
        case createdAt = "created_at"
        case profileImageURL = "profile_image_url"
    }

    enum EntitiesCodingKeys: String, CodingKey {
        case url
        case description
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.username = try container.decode(String.self, forKey: .username)

        self.protected = try container.decode(Bool.self, forKey: .protected)
        self.verified = try container.decode(Bool.self, forKey: .verified)

        self.description = try container.decode(String.self, forKey: .description)
        self.url = try? container.decode(URL.self, forKey: .url)

        let userEntities = try container.decodeIfPresent(UserEntities.self, forKey: .entities)
        self.descriptionEntities = userEntities?.description ?? Entities(urls: [], mentions: [])
        self.urlEntities = userEntities?.url ?? Entities(urls: [], mentions: [])

        self.location = try container.decodeIfPresent(String.self, forKey: .location)

        self.createdAt = try container.decode(Date.self, forKey: .createdAt)

        self.profileImageURL = try container.decode(URL.self, forKey: .profileImageURL)
    }
}

extension User {
    public var profileImageOriginalURL: URL {
        return profileImageURL
            .deletingLastPathComponent()
            .appendingPathComponent(profileImageURL.lastPathComponent.replacingOccurrences(of: "_normal.", with: "."))
    }
}

extension User {
    public var expandedURL: URL? {
        return url.flatMap { url in
            let urlEntities = urlEntities.urls

            return URL(
                string: urlEntities.reduce(into: url.absoluteString) {
                    if let range = $0.range(of: $1.url.absoluteString), let expandedURL = $1.expandedURL {
                        $0.replaceSubrange(range, with: expandedURL.absoluteString)
                    }
                }
            )
        }
    }

    public var attributedDescription: AttributedString? {
        return attributedDescription {
            var link = AttributedString($0.urlStringForDisplay ?? $0.url.absoluteString)
            link[link.startIndex..<link.endIndex].link = $0.expandedURL ?? $0.url
            return link
        }
    }

    public func attributedDescription(_ urlEntityHandler: (URLEntity) -> AttributedString) -> AttributedString {
        var attributedDescription = AttributedString(description)

        descriptionEntities.urls.forEach {
            if let range = attributedDescription.range(of: $0.url.absoluteString) {
                attributedDescription.replaceSubrange(range, with: urlEntityHandler($0))
            }
        }

        return attributedDescription
    }
}

extension User {
    public init(id: User.ID, session: Session) async throws {
        self = try await Task {
            var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "2/users/\(id)")!)
            urlRequest.httpMethod = "GET"
            urlRequest.urlComponents?.queryItems = [
                URLQueryItem(name: "user.fields", value: "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld")
            ]
            await urlRequest.oauthSign(session: session)

            let (data, response) = try await session.urlSession.data(for: urlRequest)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                throw SessionError.serverError(try? JSONDecoder.twt_default.decode(TwitterServerError.self, from: data))
            }

            return try JSONDecoder.twt_default.decode(TwitterServerResponseV2<User>.self, from: data).data.get()
        }.value
    }
}
