//
//  User+Following.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation

extension User {
    public static func followingUsers(forUserID userID: User.ID, pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "2/users/\(userID)/following")!)
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

    public static func followingUsers(forUserID userID: User.ID, session: Session) async throws -> (users: [User], errors: [TwitterServerError]) {
        func followingUsers(paginationToken: String?, previousPages: [Pagination<User>]) async throws -> [Pagination<User>] {
            let page = try await self.followingUsers(forUserID: userID, pageCount: 1000, paginationToken: paginationToken, session: session)

            if let paginationToken = page.nextToken {
                return try await followingUsers(paginationToken: paginationToken, previousPages: previousPages + [page])
            } else {
                return previousPages + [page]
            }
        }

        let followingUserPages = try await followingUsers(paginationToken: nil, previousPages: [])

        return (users: followingUserPages.flatMap { $0.items }, errors: followingUserPages.flatMap { $0.errors })
    }

    public func followingUsers(pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
        try await Self.followingUsers(forUserID: id, pageCount: pageCount, paginationToken: paginationToken, session: session)
    }

    public func followingUsers(session: Session) async throws -> (users: [User], errors: [TwitterServerError]) {
        try await Self.followingUsers(forUserID: id, session: session)
    }
}

extension User {
    public static func followingUserIDs(forUserID userID: User.ID, paginationToken: String? = nil, session: Session) async throws -> Pagination<User.ID> {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "1.1/friends/ids.json")!)
        urlRequest.httpMethod = "GET"
        urlRequest.urlComponents?.queryItems = [
            URLQueryItem(name: "stringify_ids", value: "true"),
            paginationToken.flatMap { URLQueryItem(name: "cursor", value: $0) },
        ].compactMap({$0})
        await urlRequest.oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        return Pagination(try JSONDecoder.twt_default.decode(TwitterServerUserIDsResponseV1.self, from: data))
    }

    public func followingUserIDs(paginationToken: String? = nil, session: Session) async throws -> Pagination<User.ID> {
        try await Self.followingUserIDs(forUserID: id, paginationToken: paginationToken, session: session)
    }

    public static func followingUserIDs(forUserID userID: User.ID, session: Session) async throws -> (userIDs: [User.ID], errors: [TwitterServerError]) {
        func followingUserIDs(forUserID userID: User.ID, paginationToken: String?, previousPages: [Pagination<User.ID>]) async throws -> [Pagination<User.ID>] {
            let page = try await self.followingUserIDs(forUserID: userID, paginationToken: paginationToken, session: session)

            if let paginationToken = page.nextToken {
                return try await followingUserIDs(forUserID: userID, paginationToken: paginationToken, previousPages: previousPages + [page])
            } else {
                return previousPages + [page]
            }
        }

        let followingUserIDPages = try await followingUserIDs(forUserID: userID, paginationToken: nil, previousPages: [])

        return (userIDs: followingUserIDPages.flatMap { $0.items }, errors: followingUserIDPages.flatMap { $0.errors })
    }

    public func followingUserIDs(session: Session)  async throws -> (userIDs: [User.ID], errors: [TwitterServerError]) {
        try await Self.followingUserIDs(forUserID: id, session: session)
    }
}
