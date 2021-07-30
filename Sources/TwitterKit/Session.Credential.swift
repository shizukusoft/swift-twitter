//
//  File.swift
//  File
//
//  Created by Jaehong Kang on 2021/07/30.
//

import Foundation
import CommonCrypto

extension Session {
    public struct Credential {
        public let token: String
        let tokenSecret: String

        public init(token: String, tokenSecret: String) {
            self.token = token
            self.tokenSecret = tokenSecret
        }

        public init(_ tokenResponse: TokenResponse) {
            self.token = tokenResponse.token
            self.tokenSecret = tokenResponse.tokenSecret
        }
    }
}

extension URLRequest {
    mutating func oauthSign(
        session: Session,
        nonce: String = UUID().uuidString,
        timestamp: TimeInterval = Date().timeIntervalSince1970,
        additionalOAuthParameters: [String: String]? = nil
    ) async {
        let consumerKey = session.consumerKey
        let consumerSecret = session.consumerSecret
        let credential = await session.credential

        var bodyURLComponents = URLComponents()
        bodyURLComponents.percentEncodedQuery = httpBody
            .flatMap { String(data: $0, encoding: .utf8) }
        let bodyQueryItems = bodyURLComponents.queryItems ?? []

        var urlComponents = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: true) }

        let urlQueryItems = urlComponents?.queryItems ?? []

        urlComponents?.query = nil

        var oauthQueryItems = [
            URLQueryItem(name: "oauth_consumer_key", value: consumerKey),
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
            "\((httpMethod ?? "GET").uppercased())",
            urlComponents?.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed),
            oauthSignatureParametersString.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed)
        ].compactMap { $0 }.joined(separator: "&")

        let oauthSigningKey = [
            consumerSecret.addingPercentEncoding(withAllowedCharacters: .twtk_rfc3986Allowed),
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

        setValue(oauthAuthorization, forHTTPHeaderField: "Authorization")
    }

    func oauthSigned(
        session: Session,
        nonce: String = UUID().uuidString,
        timestamp: TimeInterval = Date().timeIntervalSince1970,
        additionalOAuthParameters: [String: String]? = nil
    ) async -> URLRequest {
        var urlRequest = self
        await urlRequest.oauthSign(session: session, nonce: nonce, timestamp: timestamp, additionalOAuthParameters: additionalOAuthParameters)
        return urlRequest
    }
}

extension Session {
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

    public func fetchRequestToken(callback: String) async throws -> TokenResponse {
        try await Task { [self] in
            var urlRequest = URLRequest(url: URL(string: "https://api.twitter.com/oauth/request_token")!)
            urlRequest.httpMethod = "POST"

            await urlRequest.oauthSign(session: self, additionalOAuthParameters: ["oauth_callback": callback])

            let (data, response) = try await urlSession.data(for: urlRequest)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                throw SessionError.invalidServerResponse
            }

            guard let string = String(data: data, encoding: .utf8) else {
                throw SessionError.dataCorrupted
            }

            guard let token = TokenResponse(response: string) else {
                throw SessionError.dataCorrupted
            }

            return token
        }.value
    }

    public func fetchAccessToken(token: String, verifier: String) async throws -> TokenResponse {
        try await Task { [self] in
            var urlRequest = URLRequest(url: URL(string: "https://api.twitter.com/oauth/access_token")!)
            urlRequest.httpMethod = "POST"

            await urlRequest.oauthSign(session: self, additionalOAuthParameters: [
                "oauth_verifier": verifier,
                "oauth_token": token
            ])

            let (data, response) = try await urlSession.data(for: urlRequest)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                throw SessionError.invalidServerResponse
            }

            guard let string = String(data: data, encoding: .utf8) else {
                throw SessionError.dataCorrupted
            }

            guard let token = TokenResponse(response: string) else {
                throw SessionError.dataCorrupted
            }

            return token
        }.value
    }
}
