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
    public static func fetchMe(session: Session, completion: @escaping (Result<Account, TwitterKitError>) -> Void) {
        session.alamofireSession
            .request("https://api.twitter.com/1.1/account/verify_credentials.json", method: .get, interceptor: session.oauth1AuthenticationInterceptor)
            .validate(statusCode: 200..<300)
            .responseDecodable(
                of: Account.self,
                queue: session.mainQueue
            ) { response in
                completion(
                    response.result
                        .mapError { .request($0) }
                )
            }
    }
}
