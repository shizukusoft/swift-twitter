//
//  URLSessionConfiguration+TwitterKit.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import Alamofire

extension URLSessionConfiguration {
    public static var twtk_default: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.af.default
        let ephemeral = URLSessionConfiguration.ephemeral

        configuration.httpCookieStorage = ephemeral.httpCookieStorage
        configuration.urlCredentialStorage = ephemeral.urlCredentialStorage

        return configuration
    }
}
