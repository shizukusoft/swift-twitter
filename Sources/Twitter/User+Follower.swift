//
//  User+Follower.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation

extension User {
    public static func followers(forUserID userID: User.ID, pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
        try await Task {
            var urlRequest = URLRequest(url: URL(string: "https://api.twitter.com/2/users/\(userID)/followers")!)
            urlRequest.httpMethod = "GET"
            urlRequest.urlComponents?.queryItems = [
                pageCount.flatMap { URLQueryItem(name: "max_results", value: String($0)) },
                paginationToken.flatMap { URLQueryItem(name: "pagination_token", value: $0) },
                URLQueryItem(name: "user.fields", value: "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld")
            ].compactMap({$0})
            await urlRequest.oauthSign(session: session)

            let (data, response) = try await session.urlSession.data(for: urlRequest)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                throw SessionError.invalidServerResponse
            }

            return Pagination(try JSONDecoder.twtk_default.decode(TwitterV2Response<[User]>.self, from: data))
        }.value
    }

    public static func followers(forUserID userID: User.ID, session: Session) async throws -> [User] {
        func followers(paginationToken: String?, previousPages: [Pagination<User>]) async throws -> [Pagination<User>] {
            let page = try await self.followers(forUserID: userID, pageCount: 1000, paginationToken: paginationToken, session: session)

            if let paginationToken = page.nextToken {
                return try await followers(paginationToken: paginationToken, previousPages: previousPages + [page])
            } else {
                return previousPages + [page]
            }
        }

        return try await followers(paginationToken: nil, previousPages: [])
            .flatMap { $0.paginatedItems }
    }

    public func followers(pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
        try await Self.followers(forUserID: id, pageCount: pageCount, paginationToken: paginationToken, session: session)
    }

    public func followers(session: Session) async throws -> [User] {
        try await Self.followers(forUserID: id, session: session)
    }
}
