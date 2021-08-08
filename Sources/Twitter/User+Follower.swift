//
//  User+Follower.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation

extension User {
    public static func followers(forUserID userID: User.ID, pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<Result<User, TwitterServerError>> {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "2/users/\(userID)/followers")!)
        urlRequest.httpMethod = "GET"
        urlRequest.urlComponents?.queryItems = [
            pageCount.flatMap { URLQueryItem(name: "max_results", value: String($0)) },
            paginationToken.flatMap { URLQueryItem(name: "pagination_token", value: $0) },
            URLQueryItem(name: "user.fields", value: "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld")
        ].compactMap({$0})
        await urlRequest.oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        return Pagination(try JSONDecoder.twt_default.decode(TwitterServerArrayResponseV2<User>.self, from: data))
    }

    public static func followers(forUserID userID: User.ID, session: Session) async throws -> [Result<User, TwitterServerError>] {
        func followers(paginationToken: String?, previousPages: [Pagination<Result<User, TwitterServerError>>]) async throws -> [Pagination<Result<User, TwitterServerError>>] {
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

    public func followers(pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<Result<User, TwitterServerError>> {
        try await Self.followers(forUserID: id, pageCount: pageCount, paginationToken: paginationToken, session: session)
    }

    public func followers(session: Session) async throws -> [Result<User, TwitterServerError>] {
        try await Self.followers(forUserID: id, session: session)
    }
}
