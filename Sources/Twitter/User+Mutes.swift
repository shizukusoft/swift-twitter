//
//  User+Mutes.swift
//  
//
//  Created by Jaehong Kang on 2021/10/04.
//

import Foundation
import TwitterCore

extension User {
    public static func myMutingUserIDs(paginationToken: String? = nil, session: Session) async throws -> Pagination<User.ID> {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "1.1/mutes/users/ids.json")!)
        urlRequest.httpMethod = "GET"
        urlRequest.twt_urlComponents?.queryItems = [
            URLQueryItem(name: "stringify_ids", value: "true"),
            paginationToken.flatMap { URLQueryItem(name: "cursor", value: $0) },
        ].compactMap({$0})
        await urlRequest.twt_oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        return Pagination(try JSONDecoder.twt_default.decode(TwitterServerUserIDsResponseV1.self, from: data))
    }

    public static func myMutingUserIDs(session: Session) async throws -> (userIDs: [User.ID], errors: [TwitterServerError]) {
        func myMutingUserIDs(paginationToken: String?, previousPages: [Pagination<User.ID>]) async throws -> [Pagination<User.ID>] {
            let page = try await self.myMutingUserIDs(paginationToken: paginationToken, session: session)

            if let paginationToken = page.nextToken {
                return try await myMutingUserIDs(paginationToken: paginationToken, previousPages: previousPages + [page])
            } else {
                return previousPages + [page]
            }
        }

        let myMutingUserIDPages = try await myMutingUserIDs(paginationToken: nil, previousPages: [])

        return (userIDs: myMutingUserIDPages.flatMap { $0.items }, errors: myMutingUserIDPages.flatMap { $0.errors })
    }
}
