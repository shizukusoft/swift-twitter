//
//  Session.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation

public actor Session {
    public nonisolated let consumerKey: String
    public nonisolated let consumerSecret: String
    public var credential: Credential?

    nonisolated let delegate: Delegate

    private(set) nonisolated lazy var urlSession = URLSession(configuration: .twt_default, delegate: delegate, delegateQueue: nil)

    public init(consumerKey: String, consumerSecret: String, delegate: Delegate = Delegate()) async {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.delegate = delegate
        
        self.delegate.session = self
    }

    public func updateCredential(_ credential: Credential) {
        self.credential = credential
    }
}

extension Session {
    nonisolated func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = try await urlSession.data(for: request)
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode)
        else {
            throw TwitterError.serverError(data: data, urlResponse: response)
        }

        return (data, response)
    }
}
