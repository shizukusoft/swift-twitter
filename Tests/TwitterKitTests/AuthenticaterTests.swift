//
//  AuthenticaterTests.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import XCTest
@testable import TwitterKit

final class AuthenticaterTests: XCTestCase {
    func testApply() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let session = Session(consumerKey: "xvz1evFS4wEEPTGEFPHBog", consumerSecret: "kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw")

        var urlRequest = URLRequest(url: URL(string: "https://api.twitter.com/1.1/statuses/update.json?include_entities=true")!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = "status=Hello%20Ladies%20%2b%20Gentlemen%2c%20a%20signed%20OAuth%20request%21".data(using: .utf8)

        let credential = Credential(token: "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb", tokenSecret: "LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE")

        session.authenticator.apply(credential, timestamp: 1318622958, nonce: "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg", to: &urlRequest)

        XCTAssertEqual(
            urlRequest.headers.value(for: "Authorization"),
            #"OAuth oauth_consumer_key="xvz1evFS4wEEPTGEFPHBog",oauth_nonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg",oauth_signature="hCtSmYh%2BiHYCEqBWrE7C7hYmtUk%3D",oauth_signature_method="HMAC-SHA1",oauth_timestamp="1318622958",oauth_token="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",oauth_version="1.0""#
        )
    }
}
