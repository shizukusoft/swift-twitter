//
//  OAuth1Authenticator.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import Alamofire
import CommonCrypto

class OAuth1Authenticator {
    struct RequestToken: Decodable {
        let token: String
        let tokenSecret: String
        let callbackConfirmed: Bool

        enum CodingKeys: String, CodingKey {
            case token = "oauth_token"
            case tokenSecret = "oauth_token_secret"
            case callbackConfirmed = "oauth_callback_confirmed"
        }
    }

    private unowned let session: Session

    init(session: Session) {
        self.session = session
    }

    public func requestToken(callback: String, completion: @escaping (Result<RequestToken, Error>) -> Void) {
        var urlRequest = URLRequest(url: URL(string: "https://api.twitter.com/oauth/request_token")!)
        urlRequest.method = .post

        apply(additionalOAuthParameters: ["oauth_callback": callback], to: &urlRequest)

        session.alamofireSession
            .request(urlRequest)
            .validate(statusCode: 200..<300)
            .responseString { response in
                completion(
                    response.result
                        .mapError { .request($0) }
                        .flatMap {
                            var urlComponents = URLComponents()
                            urlComponents.percentEncodedQuery = $0

                            guard let token = urlComponents.queryItems?.first(where: { $0.name == "oauth_token" })?.value else {
                                return .failure(.unknown)
                            }

                            guard let tokenSecret = urlComponents.queryItems?.first(where: { $0.name == "oauth_token_secret" })?.value else {
                                return .failure(.unknown)
                            }

                            guard let callbackConfirmed = urlComponents.queryItems?.first(where: { $0.name == "oauth_callback_confirmed" })?.value else {
                                return .failure(.unknown)
                            }

                            return .success(RequestToken(token: token, tokenSecret: tokenSecret, callbackConfirmed: callbackConfirmed == "true"))
                        }
                )
            }
    }

    func apply(
        credential: OAuth1Credential? = nil,
        nonce: String = UUID().uuidString,
        timestamp: TimeInterval = Date().timeIntervalSinceNow,
        additionalOAuthParameters: [String: String]? = nil,
        to urlRequest: inout URLRequest
    ) {
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

        if let token = credential?.token {
            oauthQueryItems += [URLQueryItem(name: "oauth_token", value: token)]
        }

        if let additionalOAuthParameters = additionalOAuthParameters {
            oauthQueryItems += additionalOAuthParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
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
            credential?.tokenSecret?.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed)
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

extension OAuth1Authenticator: Alamofire.Authenticator {
    func apply(_ credential: OAuth1Credential, to urlRequest: inout URLRequest) {
        self.apply(credential: credential, to: &urlRequest)
    }

    func refresh(_ credential: OAuth1Credential, for session: Alamofire.Session, completion: @escaping (Result<OAuth1Credential, Swift.Error>) -> Void) {

    }

    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Swift.Error) -> Bool {
        return false
    }

    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: OAuth1Credential) -> Bool {
        return true
    }
}
