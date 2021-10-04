//
//  User+Follower.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation

extension User {
    public static func followers(forUserID userID: User.ID, pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
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

    public static func followers(forUserID userID: User.ID, session: Session) async throws -> (users: [User], errors: [TwitterServerError]) {
        func followers(paginationToken: String?, previousPages: [Pagination<User>]) async throws -> [Pagination<User>] {
            let page = try await self.followers(forUserID: userID, pageCount: 1000, paginationToken: paginationToken, session: session)

            if let paginationToken = page.nextToken {
                return try await followers(paginationToken: paginationToken, previousPages: previousPages + [page])
            } else {
                return previousPages + [page]
            }
        }

        let followerPages = try await followers(paginationToken: nil, previousPages: [])

        return (users: followerPages.flatMap { $0.items }, errors: followerPages.flatMap { $0.errors })
    }

    public func followers(pageCount: Int16? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
        try await Self.followers(forUserID: id, pageCount: pageCount, paginationToken: paginationToken, session: session)
    }

    public func followers(session: Session) async throws -> (users: [User], errors: [TwitterServerError]) {
        try await Self.followers(forUserID: id, session: session)
    }
}

extension User {
    public static func followerIDs(forUserID userID: User.ID, paginationToken: String? = nil, session: Session) async throws -> Pagination<User.ID> {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "1.1/followers/ids.json")!)
        urlRequest.httpMethod = "GET"
        urlRequest.urlComponents?.queryItems = [
            URLQueryItem(name: "stringify_ids", value: "true"),
            paginationToken.flatMap { URLQueryItem(name: "cursor", value: $0) },
        ].compactMap({$0})
        await urlRequest.oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        return Pagination(try JSONDecoder.twt_default.decode(TwitterServerUserIDsResponseV1.self, from: data))
    }

    public func followerIDs(paginationToken: String? = nil, session: Session) async throws -> Pagination<User.ID> {
        try await Self.followerIDs(forUserID: id, paginationToken: paginationToken, session: session)
    }

    public static func followerIDs(forUserID userID: User.ID, session: Session) async throws -> (userIDs: [User.ID], errors: [TwitterServerError]) {
        func followerIDs(forUserID userID: User.ID, paginationToken: String?, previousPages: [Pagination<User.ID>]) async throws -> [Pagination<User.ID>] {
            let page = try await self.followerIDs(forUserID: userID, paginationToken: paginationToken, session: session)

            if let paginationToken = page.nextToken {
                return try await followerIDs(forUserID: userID, paginationToken: paginationToken, previousPages: previousPages + [page])
            } else {
                return previousPages + [page]
            }
        }

        let followerIDPages = try await followerIDs(forUserID: userID, paginationToken: nil, previousPages: [])

        return (userIDs: followerIDPages.flatMap { $0.items }, errors: followerIDPages.flatMap { $0.errors })
    }

    public func followerIDs(session: Session) async throws -> (userIDs: [User.ID], errors: [TwitterServerError]) {
        try await Self.followerIDs(forUserID: id, session: session)
    }
}

