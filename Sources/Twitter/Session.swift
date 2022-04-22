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

    weak var delegate: Delegate?
    
    nonisolated let urlSession: URLSession

    private init(_ consumerKey: String, _ consumerSecret: String, _ urlSessionConfiguration: URLSessionConfiguration, _ delegate: Delegate) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.delegate = delegate
        self.urlSession = URLSession(configuration: urlSessionConfiguration, delegate: delegate, delegateQueue: nil)
    }
    
    public convenience init(consumerKey: String, consumerSecret: String, urlSessionConfiguration: URLSessionConfiguration = .default, delegate: Delegate = Delegate()) {
        self.init(consumerKey, consumerSecret, urlSessionConfiguration, delegate)
        
        Task {
            await self.delegate?.session = self
        }
    }
    
    deinit {
        urlSession.invalidateAndCancel()
    }

    public func updateCredential(_ credential: Credential?) {
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
