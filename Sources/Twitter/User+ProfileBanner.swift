//
//  User+ProfileBanner.swift
//  
//
//  Created by Jaehong Kang on 2021/10/03.
//

import Foundation

extension User {
    public struct ProfileBanner {
        public struct SizeClass {
            public let width: Double
            public let height: Double

            public let url: URL
        }

        public let sizes: [String: SizeClass]
    }

    public static func profileBanner(forUserID userID: User.ID, session: Session) async throws -> ProfileBanner? {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "1.1/users/profile_banner.json")!)
        urlRequest.httpMethod = "GET"
        urlRequest.urlComponents?.queryItems = [
            URLQueryItem(name: "user_id", value: userID)
        ]
        await urlRequest.oauthSign(session: session)

        do {
            let (data, _) = try await session.data(for: urlRequest)

            return try JSONDecoder.twt_default.decode(ProfileBanner.self, from: data)
        } catch TwitterError.serverError(let serverErrorPayload, let urlResponse) {
            guard (urlResponse as? HTTPURLResponse)?.statusCode == 404 else {
                throw TwitterError.serverError(serverErrorPayload, urlResponse: urlResponse)
            }

            return nil
        }
    }

    public func profileBanner(session: Session) async throws -> ProfileBanner? {
        try await Self.profileBanner(forUserID: id, session: session)
    }
}

extension User.ProfileBanner: Decodable {}

extension User.ProfileBanner.SizeClass: Decodable {
    enum CodingKeys: String, CodingKey {
        case width = "w"
        case height = "h"
        case url
    }
}
