//
//  User+API.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/08.
//

import Foundation

extension User {
    public init(id: User.ID, session: Session) async throws {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "2/users/\(id)")!)
        urlRequest.httpMethod = "GET"
        urlRequest.urlComponents?.queryItems = [
            URLQueryItem(name: "user.fields", value: "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld")
        ]
        await urlRequest.oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        let response = try JSONDecoder.twt_default.decode(TwitterServerResponseV2<User>.self, from: data)

        guard let user = response.data else {
            throw response.error ?? TwitterError.dataCorrupted
        }

        self = user
    }
}

extension User {
    public static func users(ids: [User.ID], session: Session) async throws -> (users: [User], errors: [TwitterServerError]) {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "2/users")!)
        urlRequest.httpMethod = "GET"
        urlRequest.urlComponents?.queryItems = [
            URLQueryItem(name: "ids", value: ids.joined(separator: ",")),
            URLQueryItem(name: "user.fields", value: "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld")
        ]
        await urlRequest.oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        let response = try JSONDecoder.twt_default.decode(TwitterServerArrayResponseV2<User>.self, from: data)

        return (response.data ?? [], response.errors ?? [])
    }
}
