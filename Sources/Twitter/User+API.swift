//
//  User+API.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/08.
//

import Foundation

extension User {
    public init(id: User.ID, session: Session) async throws {
        self = try await Task {
            var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "2/users/\(id)")!)
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
                throw TwitterError.serverError(data: data, urlResponse: response)
            }

            return try JSONDecoder.twt_default.decode(TwitterServerResponseV2<User>.self, from: data).data.get()
        }.value
    }
}

extension Array where Element == User {
    public init(ids: [User.ID], session: Session) async throws {
        self = try await Task {
            var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "2/users")!)
            urlRequest.httpMethod = "GET"
            urlRequest.urlComponents?.queryItems = [
                URLQueryItem(name: "ids", value: ids.joined(separator: ",")),
                URLQueryItem(name: "user.fields", value: "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld")
            ]
            await urlRequest.oauthSign(session: session)

            let (data, response) = try await session.urlSession.data(for: urlRequest)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                throw TwitterError.serverError(data: data, urlResponse: response)
            }

            return try JSONDecoder.twt_default.decode(TwitterServerResponseV2<[User]>.self, from: data).data.get()
        }.value
    }
}
