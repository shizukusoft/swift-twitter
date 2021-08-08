//
//  Account.swift
//  
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation

public struct Account: Decodable, Identifiable {
    public let id: Int64
    public let name: String
    public let username: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username = "screen_name"
    }
}

extension Account {
    public static func me(session: Session) async throws -> Account {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "1.1/account/verify_credentials.json")!)
        urlRequest.httpMethod = "GET"
        await urlRequest.oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        return try JSONDecoder.twt_default.decode(Account.self, from: data)
    }
}

extension Account {
    public static func myBlockingIDs(paginationToken: String? = nil, session: Session) async throws -> Pagination<User.ID> {
        var urlRequest = URLRequest(url: URL(twitterAPIURLWithPath: "1.1/blocks/ids.json")!)
        urlRequest.httpMethod = "GET"
        urlRequest.urlComponents?.queryItems = [
            URLQueryItem(name: "stringify_ids", value: "true"),
            paginationToken.flatMap { URLQueryItem(name: "pagination_token", value: $0) },
        ].compactMap({$0})
        await urlRequest.oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        return Pagination(try JSONDecoder.twt_default.decode(TwitterServerUserIDsResponseV1.self, from: data))
    }

    public static func myBlockingIDs(session: Session) async throws -> [User.ID] {
        func myBlockingIDs(paginationToken: String?, previousPages: [Pagination<User.ID>]) async throws -> [Pagination<User.ID>] {
            let page = try await self.myBlockingIDs(paginationToken: paginationToken, session: session)

            if let paginationToken = page.nextToken {
                return try await myBlockingIDs(paginationToken: paginationToken, previousPages: previousPages + [page])
            } else {
                return previousPages + [page]
            }
        }

        return try await myBlockingIDs(paginationToken: nil, previousPages: [])
            .flatMap { $0.paginatedItems }
    }
}
