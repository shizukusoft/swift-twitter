//
//  User+Tweet.swift
//  User+Tweet
//
//  Created by Jaehong Kang on 2021/08/15.
//

import Foundation

extension User {
    public static func tweets(forUserID userID: User.ID, pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<Result<Tweet, TwitterServerError>> {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "2/users/\(userID)/tweets")!)
        urlRequest.httpMethod = "GET"
        urlRequest.urlComponents?.queryItems = [
            pageCount.flatMap { URLQueryItem(name: "max_results", value: String($0)) },
            paginationToken.flatMap { URLQueryItem(name: "pagination_token", value: $0) },
            URLQueryItem(name: "tweet.fields", value: "created_at")
        ].compactMap({$0})
        await urlRequest.oauthSign(session: session)
        
        let (data, _) = try await session.data(for: urlRequest)

        return Pagination(try JSONDecoder.twt_default.decode(TwitterServerArrayResponseV2<Tweet>.self, from: data))
    }
    
    public static func tweets(forUserID userID: User.ID, session: Session) async throws -> [Result<Tweet, TwitterServerError>] {
        func tweets(paginationToken: String?, previousPages: [Pagination<Result<Tweet, TwitterServerError>>]) async throws -> [Pagination<Result<Tweet, TwitterServerError>>] {
            let page = try await self.tweets(forUserID: userID, pageCount: 100, paginationToken: paginationToken, session: session)

            if let paginationToken = page.nextToken {
                return try await tweets(paginationToken: paginationToken, previousPages: previousPages + [page])
            } else {
                return previousPages + [page]
            }
        }

        return try await tweets(paginationToken: nil, previousPages: [])
            .flatMap { $0.paginatedItems }
    }
    
    public func tweets(pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<Result<Tweet, TwitterServerError>> {
        try await Self.tweets(forUserID: id, pageCount: pageCount, paginationToken: paginationToken, session: session)
    }

    public func tweets(session: Session) async throws -> [Result<Tweet, TwitterServerError>] {
        try await Self.tweets(forUserID: id, session: session)
    };
}
