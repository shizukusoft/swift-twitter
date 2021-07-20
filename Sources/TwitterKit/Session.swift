//
//  Session.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import Alamofire

open class Session {
    public let consumerKey: String
    let consumerSecret: String

    open private(set) lazy var globalQueue = DispatchQueue(
        label: "\(String(reflecting: self)).0x\(String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16))",
        qos: .default,
        attributes: .concurrent
    )

    open private(set) lazy var requestOperationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "\(String(reflecting: self)).0x\(String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)).request"
        operationQueue.underlyingQueue = globalQueue
        operationQueue.maxConcurrentOperationCount = 1

        return operationQueue
    }()

    open private(set) lazy var mainQueue = DispatchQueue(
        label: "\(String(reflecting: self)).0x\(String(UInt(bitPattern: ObjectIdentifier(self)), radix: 16)).main",
        qos: .default,
        target: globalQueue
    )

    open private(set) lazy var alamofireSession = Alamofire.Session(
        configuration: URLSessionConfiguration.twtk_default,
        rootQueue: mainQueue,
        requestQueue: globalQueue,
        serializationQueue: globalQueue
    )

    open private(set) lazy var oauth1Authenticator = OAuth1Authenticator(session: self)
    open var oauth1Credential: OAuth1Credential? {
        get { oauth1AuthenticationInterceptor.credential }
        set { oauth1AuthenticationInterceptor.credential = newValue }
    }
    private(set) lazy var oauth1AuthenticationInterceptor = AuthenticationInterceptor(authenticator: oauth1Authenticator)

    public init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }
}
