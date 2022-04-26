//
//  User+Blocking.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation
import TwitterCore

extension User {
    public static func blockingUsers(forUserID userID: User.ID, pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "2/users/\(userID)/blocking")!)
        urlRequest.httpMethod = "GET"
        urlRequest.twt_urlComponents?.queryItems = [
            pageCount.flatMap { URLQueryItem(name: "max_results", value: String($0)) },
            paginationToken.flatMap { URLQueryItem(name: "pagination_token", value: $0) },
            URLQueryItem(name: "user.fields", value: "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld")
        ].compactMap({$0})
        await urlRequest.twt_oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        return Pagination(try JSONDecoder.twt_default.decode(TwitterServerArrayResponseV2<User>.self, from: data))
    }

    public func blockingUsers(pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
        try await Self.blockingUsers(forUserID: id, pageCount: pageCount, paginationToken: paginationToken, session: session)
    }

    public static func blockingUsers(forUserID userID: User.ID, session: Session) async throws -> (users: [User], errors: [TwitterServerError]) {
        func blockingUsers(paginationToken: String?, previousPages: [Pagination<User>]) async throws -> [Pagination<User>] {
            let page = try await self.blockingUsers(forUserID: userID, pageCount: 1000, paginationToken: paginationToken, session: session)

            if let paginationToken = page.nextToken {
                return try await blockingUsers(paginationToken: paginationToken, previousPages: previousPages + [page])
            } else {
                return previousPages + [page]
            }
        }

        let blockingUserPages = try await blockingUsers(paginationToken: nil, previousPages: [])

        return (users: blockingUserPages.flatMap { $0.items }, errors: blockingUserPages.flatMap { $0.errors })
    }

    public func blockingUsers(session: Session) async throws -> (users: [User], errors: [TwitterServerError]) {
        try await Self.blockingUsers(forUserID: id, session: session)
    }
}

extension User {
    public static func myBlockingUserIDs(paginationToken: String? = nil, session: Session) async throws -> Pagination<User.ID> {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "1.1/blocks/ids.json")!)
        urlRequest.httpMethod = "GET"
        urlRequest.twt_urlComponents?.queryItems = [
            URLQueryItem(name: "stringify_ids", value: "true"),
            paginationToken.flatMap { URLQueryItem(name: "cursor", value: $0) },
        ].compactMap({$0})
        await urlRequest.twt_oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        return Pagination(try JSONDecoder.twt_default.decode(TwitterServerUserIDsResponseV1.self, from: data))
    }

    public static func myBlockingUserIDs(session: Session) async throws -> (userIDs: [User.ID], errors: [TwitterServerError]) {
        func myBlockingUserIDs(paginationToken: String?, previousPages: [Pagination<User.ID>]) async throws -> [Pagination<User.ID>] {
            let page = try await self.myBlockingUserIDs(paginationToken: paginationToken, session: session)

            if let paginationToken = page.nextToken {
                return try await myBlockingUserIDs(paginationToken: paginationToken, previousPages: previousPages + [page])
            } else {
                return previousPages + [page]
            }
        }

        let myBlockingUserIDPages = try await myBlockingUserIDs(paginationToken: nil, previousPages: [])

        return (userIDs: myBlockingUserIDPages.flatMap { $0.items }, errors: myBlockingUserIDPages.flatMap { $0.errors })
    }
}
