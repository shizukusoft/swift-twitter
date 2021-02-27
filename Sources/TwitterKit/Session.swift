//
//  Session.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import Alamofire

public class Session {
    public let consumerKey: String
    let consumerSecret: String

    public let globalQueue: DispatchQueue
    public let mainQueue: DispatchQueue

    public private(set) lazy var alamofireSession = Alamofire.Session(
        configuration: URLSessionConfiguration.twtk_default,
        rootQueue: mainQueue,
        requestQueue: globalQueue,
        serializationQueue: globalQueue
    )

    public private(set) lazy var oauth1Authenticator = OAuth1Authenticator(session: self)
    public var oauth1Credential: OAuth1Credential? {
        get { oauth1AuthenticationInterceptor.credential }
        set { oauth1AuthenticationInterceptor.credential = newValue }
    }
    private(set) lazy var oauth1AuthenticationInterceptor = AuthenticationInterceptor(authenticator: oauth1Authenticator)

    public init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret

        let globalQueue = DispatchQueue(label: "\(String(reflecting: Session.self))", qos: .default, attributes: .concurrent)
        let mainQueue = DispatchQueue(label: "\(String(reflecting: Session.self)).main", qos: .default, target: globalQueue)

        self.globalQueue = globalQueue
        self.mainQueue = mainQueue
    }
}
