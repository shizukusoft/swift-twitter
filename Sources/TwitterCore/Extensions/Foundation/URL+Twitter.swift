//
//  URL+Twitter.swift
//
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation

extension URL {
    public static let twitterAPI: URL = URL(string: "https://api.twitter.com/")!

    public init?(twitterAPIURLWithPath path: String) {
        self.init(string: path, relativeTo: Self.twitterAPI)
    }

    public init(twitterOAuthAuthorizeURLWithOAuthToken oAuthToken: String) {
        self.init(twitterAPIURLWithPath: "oauth/authorize?oauth_token=\(oAuthToken)")!
    }
}
