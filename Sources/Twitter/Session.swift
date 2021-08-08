//
//  Session.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation

public actor Session {
    public let consumerKey: String
    public let consumerSecret: String
    public var credential: Credential?

    let delegate: Delegate

    private(set) lazy var mainQueue = DispatchQueue(
        label: "\(String(reflecting: self)).0x\(String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)).main",
        qos: .default
    )

    private(set) lazy var mainOperationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.underlyingQueue = self.mainQueue
        operationQueue.name = "\(String(reflecting: self)).0x\(String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)).main"

        return operationQueue
    }()

    private(set) lazy var urlSession = URLSession(configuration: .twt_default, delegate: delegate, delegateQueue: mainOperationQueue)

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
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
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
