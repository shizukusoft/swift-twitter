//
//  Session.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import Alamofire

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

    private(set) lazy var urlSession = URLSession(configuration: .twtk_default, delegate: delegate, delegateQueue: mainOperationQueue)

    public init(consumerKey: String, consumerSecret: String, delegate: Delegate = Delegate()) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.delegate = delegate
    }

    public func updateCredential(_ credential: Credential) {
        self.credential = credential
    }
}
