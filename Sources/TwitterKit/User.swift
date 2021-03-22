//
//  User.swift
//  
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation
import Alamofire

public struct User: Decodable, Identifiable {
    public let id: String
    public let name: String
    public let username: String

    public let protected: Bool
    public let verified: Bool

    public let description: String

    public let createdAt: Date

    public let profileImageURL: URL

    enum CodingKeys: String, CodingKey {
        case id, name, username, protected, verified, description
        case createdAt = "created_at"
        case profileImageURL = "profile_image_url"
    }
}

extension User {
    public static func fetchUser(id: Int64, session: Session, completion: @escaping (Result<User, TwitterKitError>) -> Void) {
        session.alamofireSession
            .request(
                "https://api.twitter.com/2/users/\(id)",
                method: .get,
                parameters: [
                    "user.fields": "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld",
                ],
                encoding: URLEncoding(),
                interceptor: session.oauth1AuthenticationInterceptor
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(
                of: TwitterV2Response<User>.self,
                queue: session.mainQueue,
                decoder: JSONDecoder.twtk_default
            ) { response in
                completion(
                    response.result
                        .mapError { .request($0) }
                        .map { $0.data }
                )
            }
    }

    public static func fetchFollowingUsers(forUserID userID: Int64, pageCount: Int? = nil, paginationToken: String? = nil, session: Session, completion: @escaping (Result<Pagination<User>, TwitterKitError>) -> Void) {
        var parameters = [String: String]()
        parameters["max_results"] = pageCount.flatMap { String($0) }
        parameters["pagination_token"] = paginationToken
        parameters["user.fields"] = "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld"

        session.alamofireSession
            .request(
                "https://api.twitter.com/2/users/\(userID)/following",
                method: .get,
                parameters: parameters,
                encoding: URLEncoding(),
                interceptor: session.oauth1AuthenticationInterceptor
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(
                of: TwitterV2Response<[User]>.self,
                queue: session.mainQueue,
                decoder: JSONDecoder.twtk_default
            ) { response in
                completion(
                    response.result
                        .mapError { .request($0) }
                        .map { Pagination($0) }
                )
            }
    }

    public static func fetchFollowerUsers(forUserID userID: Int64, pageCount: Int? = nil, paginationToken: String? = nil, session: Session, completion: @escaping (Result<Pagination<User>, TwitterKitError>) -> Void) {
        var parameters = [String: String]()
        parameters["max_results"] = pageCount.flatMap { String($0) }
        parameters["pagination_token"] = paginationToken
        parameters["user.fields"] = "created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld"

        session.alamofireSession
            .request(
                "https://api.twitter.com/2/users/\(userID)/followers",
                method: .get,
                parameters: parameters,
                encoding: URLEncoding(),
                interceptor: session.oauth1AuthenticationInterceptor
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(
                of: TwitterV2Response<[User]>.self,
                queue: session.mainQueue,
                decoder: JSONDecoder.twtk_default
            ) { response in
                completion(
                    response.result
                        .mapError { .request($0) }
                        .map { Pagination($0) }
                )
            }
    }
}
