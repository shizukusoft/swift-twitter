//
//  OAuth1Credential.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import Alamofire

public struct OAuth1Credential: Alamofire.AuthenticationCredential {
    public let token: String?
    let tokenSecret: String?

    public var requiresRefresh: Bool { false }

    public init(token: String?, tokenSecret: String?) {
        self.token = token
        self.tokenSecret = tokenSecret
    }
}
