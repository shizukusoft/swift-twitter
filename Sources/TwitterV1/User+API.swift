//
//  User+API.swift
//  
//
//  Created by 강재홍 on 2022/04/27.
//

import Foundation
import TwitterCore

extension User {
    public init(id: User.ID, session: Session) async throws {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "1.1/users/show.json")!)
        urlRequest.httpMethod = "GET"
        urlRequest.twt_urlComponents?.queryItems = [
            URLQueryItem(name: "user_id", value: String(id))        ]
        await urlRequest.twt_oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        let user = try JSONDecoder.twt_default.decode(User.self, from: data)

        self = user
    }
}

extension User {
    public static func users(ids: [User.ID], session: Session) async throws -> [User] {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "1.1/users/lookup.json")!)
        urlRequest.httpMethod = "GET"
        urlRequest.twt_urlComponents?.queryItems = [
            URLQueryItem(name: "user_id", value: ids.lazy.map { String($0) }.joined(separator: ","))
        ]
        await urlRequest.twt_oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        let users = try JSONDecoder.twt_default.decode([User].self, from: data)

        return users
    }
}
