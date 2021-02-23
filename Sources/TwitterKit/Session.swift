//
//  Session.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation
import Alamofire

public class Session {
    public private(set) lazy var globalQueue = DispatchQueue(label: "\(String(reflecting: Session.self))", qos: .default, attributes: .concurrent)
    public private(set) lazy var mainQueue = DispatchQueue(label: "\(String(reflecting: Session.self)).main", qos: .default, target: globalQueue)

    private(set) lazy var oauth1Authenticator = OAuth1Authenticator(session: self)
    private(set) lazy var oauth1AuthenticationInterceptor = AuthenticationInterceptor(authenticator: oauth1Authenticator)

    public private(set) lazy var alamofireSession = Alamofire.Session(
        configuration: URLSessionConfiguration.twtk_default,
        rootQueue: mainQueue,
        requestQueue: globalQueue,
        serializationQueue: globalQueue
    )

    public let consumerKey: String
    let consumerSecret: String

    init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }
}
