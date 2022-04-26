//
//  User+Tweet.swift
//  User+Tweet
//
//  Created by Jaehong Kang on 2021/08/15.
//

import Foundation
import TwitterCore

extension User {
    public static func tweets(forUserID userID: User.ID, pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<Tweet> {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "2/users/\(userID)/tweets")!)
        urlRequest.httpMethod = "GET"
        urlRequest.twt_urlComponents?.queryItems = [
            pageCount.flatMap { URLQueryItem(name: "max_results", value: String($0)) },
            paginationToken.flatMap { URLQueryItem(name: "pagination_token", value: $0) },
            URLQueryItem(name: "tweet.fields", value: "created_at")
        ].compactMap({$0})
        await urlRequest.twt_oauthSign(session: session)
        
        let (data, _) = try await session.data(for: urlRequest)

        return Pagination(try JSONDecoder.twt_default.decode(TwitterServerArrayResponseV2<Tweet>.self, from: data))
    }
    
    public static func tweets(forUserID userID: User.ID, session: Session) async throws -> (tweets: [Tweet], errors: [TwitterServerError]) {
        func tweets(paginationToken: String?, previousPages: [Pagination<Tweet>]) async throws -> [Pagination<Tweet>] {
            let page = try await self.tweets(forUserID: userID, pageCount: 100, paginationToken: paginationToken, session: session)

            if let paginationToken = page.nextToken {
                return try await tweets(paginationToken: paginationToken, previousPages: previousPages + [page])
            } else {
                return previousPages + [page]
            }
        }

        let tweetPages = try await tweets(paginationToken: nil, previousPages: [])

        return (tweets: tweetPages.flatMap { $0.items }, tweetPages.flatMap { $0.errors })
    }
    
    public func tweets(pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<Tweet> {
        try await Self.tweets(forUserID: id, pageCount: pageCount, paginationToken: paginationToken, session: session)
    }

    public func tweets(session: Session) async throws-> (tweets: [Tweet], errors: [TwitterServerError]) {
        try await Self.tweets(forUserID: id, session: session)
    }
}
