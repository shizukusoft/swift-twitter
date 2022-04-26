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
        await urlRequest.twt_oauthSign(session: session)

        let (data, _) = try await session.data(for: urlRequest)

        return try JSONDecoder.twt_default.decode(Account.self, from: data)
    }
}
