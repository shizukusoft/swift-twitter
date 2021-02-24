//
//  File.swift
//  
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation

public struct User: Decodable {
    public let id: Int64
}

extension User {
    public static func fetchMe(session: Session, completion: @escaping (Result<User, Error>) -> Void) {
        session.alamofireSession
            .request("https://api.twitter.com/1.1/account/verify_credentials.json", method: .get, interceptor: session.oauth1AuthenticationInterceptor)
            .validate(statusCode: 200..<300)
            .responseDecodable(
                of: User.self,
                queue: session.mainQueue
            ) { response in
                completion(
                    response.result
                        .mapError { .request($0) }
                )
            }
    }
}
