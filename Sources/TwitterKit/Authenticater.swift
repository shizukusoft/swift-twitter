//
//  Authenticater.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import Alamofire
import CommonCrypto

class Authenticator {
    private unowned let session: Session

    init(session: Session) {
        self.session = session
    }

    public func requestToken(callback: String) {

    }

    func apply(_ credential: Credential, timestamp: TimeInterval, nonce: String, to urlRequest: inout URLRequest) {
        var bodyURLComponents = URLComponents()
        bodyURLComponents.percentEncodedQuery = urlRequest.httpBody
            .flatMap { String(data: $0, encoding: .utf8) }
        let bodyQueryItems = bodyURLComponents.queryItems ?? []

        var urlComponents = urlRequest.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: true) }

        let urlQueryItems = urlComponents?.queryItems ?? []

        urlComponents?.query = nil

        var oauthQueryItems = [
            URLQueryItem(name: "oauth_consumer_key", value: session.consumerKey),
            URLQueryItem(name: "oauth_nonce", value: nonce),
            URLQueryItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            URLQueryItem(name: "oauth_timestamp", value: "\(UInt(timestamp))"),
            URLQueryItem(name: "oauth_version", value: "1.0")
        ]

        if let token = credential.token {
            oauthQueryItems += [URLQueryItem(name: "oauth_token", value: token)]
        }

        let oauthSignatureParameterString = (bodyQueryItems + urlQueryItems + oauthQueryItems)
            .sorted(by: {
                if $0.name == $1.name {
                    return $0.value ?? "" < $1.value ?? ""
                } else {
                    return $0.name < $1.name
                }
            })
            .map { [$0.name, $0.value].compactMap { $0?.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed) } }
            .map { $0.joined(separator: "=") }
            .joined(separator: "&")

        let oauthSignatureBaseString = [
            "\((urlRequest.httpMethod ?? "GET").uppercased())",
            urlComponents?.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed),
            oauthSignatureParameterString.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed)
        ].compactMap { $0 }.joined(separator: "&")

        let oauthSigningKey = [
            session.consumerSecret.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed),
            credential.tokenSecret?.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed)
        ].compactMap { $0 }.joined(separator: "&")

        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), oauthSigningKey, oauthSigningKey.count, oauthSignatureBaseString, oauthSignatureBaseString.count, &digest)

        let oauthSignature = Data(digest).base64EncodedString(options: [])
        oauthQueryItems += [URLQueryItem(name: "oauth_signature", value: oauthSignature)]

        let oauthAuthorization = "OAuth " + oauthQueryItems
            .sorted(by: {
                if $0.name == $1.name {
                    return $0.value ?? "" < $1.value ?? ""
                } else {
                    return $0.name < $1.name
                }
            })
            .map { [$0.name.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed), $0.value?.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed).flatMap { "\"\($0)\"" }].compactMap { $0 } }
            .map { $0.joined(separator: "=") }
            .joined(separator: ",")

        urlRequest.headers.add(.authorization(oauthAuthorization))
    }
}

extension Authenticator: Alamofire.Authenticator {
    func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        self.apply(credential, timestamp: Date().timeIntervalSinceNow, nonce: UUID().uuidString, to: &urlRequest)
    }

    func refresh(_ credential: Credential, for session: Alamofire.Session, completion: @escaping (Result<Credential, Error>) -> Void) {

    }

    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool {
        return false
    }

    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Credential) -> Bool {
        return true
    }
}
