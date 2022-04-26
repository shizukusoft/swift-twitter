//
//  Tweet+API.swift
//  Tweet+API
//
//  Created by Jaehong Kang on 2021/08/15.
//

import Foundation

extension Tweet {
    public static func delete(_ tweetID: Tweet.ID, session: Session) async throws {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "1.1/statuses/destroy/\(tweetID).json")!)
        urlRequest.httpMethod = "POST"
        await urlRequest.twt_oauthSigned(session: session)

        let (_, _) = try await session.data(for: urlRequest)
    }
    
    public func delete(session: Session) async throws {
        try await Self.delete(id, session: session)
    }
}
