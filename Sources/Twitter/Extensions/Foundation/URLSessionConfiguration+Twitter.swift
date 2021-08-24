//
//  URLSessionConfiguration+Twitter.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import OrderedCollections

extension URLSessionConfiguration {
    public static var twt_default: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        let ephemeral = URLSessionConfiguration.ephemeral

        configuration.httpCookieStorage = ephemeral.httpCookieStorage
        configuration.urlCredentialStorage = ephemeral.urlCredentialStorage
        
        configuration.httpAdditionalHeaders = {
            var httpAdditionalHeaders = configuration.httpAdditionalHeaders ?? [:]
            
            let preferredLanguages = OrderedSet(Locale.preferredLanguages.flatMap { [$0, $0.components(separatedBy: "-")[0]] } + ["*"])
            httpAdditionalHeaders["Accept-Language"] = preferredLanguages.qualityJoined
            
            httpAdditionalHeaders["Accept-Encoding"] = OrderedSet(["br", "gzip", "deflate"]).qualityJoined
            
            return httpAdditionalHeaders
        }()

        return configuration
    }
}

extension Collection where Element == String {
    var qualityJoined: String {
        enumerated()
            .map { offset, language in
                let quality = 1.0 - ((Decimal(offset + 1)) / Decimal(count + 1))
                return "\(language);q=\(quality)"
            }
            .joined(separator: ", ")
    }
}
