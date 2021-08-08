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

        self = try JSONDecoder.twt_default.decode(TwitterServerResponseV2<User>.self, from: data).data.get()
    }
}

extension Array where Element == User {
    public init(ids: [User.ID], session: Session) async throws {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "2/users")!)
        urlRequest.httpMethod = "GET"
        urlRequest.urlComponents?.queryItems = [
            URLQueryItem(name: "ids", value: ids.joined(separator: ",")),
            URLQueryItem(name: "user.fields", value: "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld")
        ]
        await urlRequest.oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        self = try JSONDecoder.twt_default.decode(TwitterServerArrayResponseV2<User>.self, from: data)
            .data?
            .map { try $0.get() } ?? []
    }
}
