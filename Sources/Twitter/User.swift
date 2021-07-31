//
//  User.swift
//  
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation

public struct User: Decodable, Identifiable {
    public let id: Int64
    public let name: String
    public let username: String

    public let protected: Bool
    public let verified: Bool

    public let description: String

    public let createdAt: Date

    public let profileImageURL: URL

    enum CodingKeys: String, CodingKey {
        case id, name, username, protected, verified, description
        case createdAt = "created_at"
        case profileImageURL = "profile_image_url"
    }
}

extension User {
    public init(id: Int64, session: Session) async throws {
        self = try await Task {
            var urlRequest = URLRequest(url: URL(string: "https://api.twitter.com/2/users/\(id)")!)
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
                throw SessionError.invalidServerResponse
            }

            return try JSONDecoder().decode(TwitterV2Response<User>.self, from: data).data
        }.value
    }
}

extension User {
    public static func followings(forUserID userID: User.ID, pageCount: Int? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
        try await Task {
            var urlRequest = URLRequest(url: URL(string: "https://api.twitter.com/2/users/\(userID)/following")!)
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

            return Pagination(try JSONDecoder().decode(TwitterV2Response<[User]>.self, from: data))
        }.value
    }

    public func followings(pageCount: Int? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
        try await Self.followings(forUserID: id, pageCount: pageCount, paginationToken: paginationToken, session: session)
    }
}

extension User {
    public static func followers(forUserID userID: User.ID, pageCount: Int? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
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

            return Pagination(try JSONDecoder().decode(TwitterV2Response<[User]>.self, from: data))
        }.value
    }

    public func followers(pageCount: Int? = nil, paginationToken: String? = nil, session: Session) async throws -> Pagination<User> {
        try await Self.followers(forUserID: id, pageCount: pageCount, paginationToken: paginationToken, session: session)
    }
}
