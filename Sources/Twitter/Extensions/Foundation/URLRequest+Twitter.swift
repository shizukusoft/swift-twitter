//
//  URLRequest+Twitter.swift
//
//
//  Created by Jaehong Kang on 2021/07/31.
//

import Foundation

extension URLRequest {
    var urlComponents: URLComponents? {
        get {
            url.flatMap {
                URLComponents(url: $0, resolvingAgainstBaseURL: false)
            }
        }
        set {
            url = newValue?.url
        }
    }
}
