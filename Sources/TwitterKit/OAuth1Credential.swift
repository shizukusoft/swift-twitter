//
//  OAuth1Credential.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import Alamofire

struct OAuth1Credential: Alamofire.AuthenticationCredential {
    let token: String?
    let tokenSecret: String?

    var requiresRefresh: Bool { false }

    init(token: String?, tokenSecret: String?) {
        self.token = token
        self.tokenSecret = tokenSecret
    }
}
