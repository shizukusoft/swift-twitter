//
//  OAuth1Authenticator.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import Alamofire
import CommonCrypto

public class OAuth1Authenticator {
    public struct TokenResponse {
        public let token: String
        public let tokenSecret: String
        public let callbackConfirmed: Bool?

        init?(response: String) {
            var urlComponents = URLComponents()
            urlComponents.percentEncodedQuery = response

            guard let token = urlComponents.queryItems?.first(where: { $0.name == "oauth_token" })?.value else {
                return nil
            }
            self.token = token

            guard let tokenSecret = urlComponents.queryItems?.first(where: { $0.name == "oauth_token_secret" })?.value else {
                return nil
            }
            self.tokenSecret = tokenSecret

            self.callbackConfirmed = urlComponents.queryItems?.first(where: { $0.name == "oauth_callback_confirmed" })?.value.flatMap { $0 == "true" }
        }
    }

    private weak var session: Session?

    init(session: Session) {
        self.session = session
    }

    func apply(
        credential: OAuth1Credential? = nil,
        nonce: String = UUID().uuidString,
        timestamp: TimeInterval = Date().timeIntervalSince1970,
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
            URLQueryItem(name: "oauth_consumer_key", value: session?.consumerKey),
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

        let oauthSignatureParameters = bodyQueryItems + urlQueryItems + oauthQueryItems
        let oauthSignatureParametersString = oauthSignatureParameters
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
            oauthSignatureParametersString.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed)
        ].compactMap { $0 }.joined(separator: "&")

        let oauthSigningKey = [
            session?.consumerSecret.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed),
            credential?.tokenSecret.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed) ?? ""
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

extension OAuth1Authenticator {
    public func fetchRequestToken(callback: String) async throws -> OAuth1Authenticator.TokenResponse {
        guard let session = session else { throw TwitterKitError.unknown; }

        return try await withCheckedThrowingContinuation { continuation in
            var urlRequest = URLRequest(url: URL(string: "https://api.twitter.com/oauth/request_token")!)
            urlRequest.method = .post

            apply(additionalOAuthParameters: ["oauth_callback": callback], to: &urlRequest)

            session.alamofireSession
                .request(urlRequest)
                .validate(statusCode: 200..<300)
                .responseString(queue: session.mainQueue) { response in
                    continuation.resume(
                        with: response.result
                            .mapError { TwitterKitError.request($0) }
                            .flatMap {
                                guard let token = TokenResponse(response: $0) else {
                                    return .failure(TwitterKitError.unknown)
                                }

                                return .success(token)
                            }
                    )
                }
        }
    }

    public func fetchAccessToken(token: String, verifier: String) async throws -> OAuth1Authenticator.TokenResponse {
        guard let session = session else { throw TwitterKitError.unknown; }

        return try await withCheckedThrowingContinuation { continuation in
            var urlRequest = URLRequest(url: URL(string: "https://api.twitter.com/oauth/access_token")!)
            urlRequest.method = .post

            apply(additionalOAuthParameters: [
                "oauth_verifier": verifier,
                "oauth_token": token
            ], to: &urlRequest)

            session.alamofireSession
                .request(urlRequest)
                .validate(statusCode: 200..<300)
                .responseString(queue: session.mainQueue) { response in
                    continuation.resume(
                        with: response.result
                            .mapError { TwitterKitError.request($0) }
                            .flatMap {
                                guard let token = TokenResponse(response: $0) else {
                                    return .failure(TwitterKitError.unknown)
                                }

                                return .success(token)
                            }
                    )
                }
        }
    }
}

extension OAuth1Authenticator: Alamofire.Authenticator {
    public func apply(_ credential: OAuth1Credential, to urlRequest: inout URLRequest) {
        self.apply(credential: credential, to: &urlRequest)
    }

    public func refresh(_ credential: OAuth1Credential, for session: Alamofire.Session, completion: @escaping (Result<OAuth1Credential, Swift.Error>) -> Void) {

    }

    public func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Swift.Error) -> Bool {
        return false
    }

    public func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: OAuth1Credential) -> Bool {
        return true
    }
}
