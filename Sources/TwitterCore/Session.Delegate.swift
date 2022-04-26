//
//  SessionDelegate.swift
//
//
//  Created by Jaehong Kang on 2021/07/30.
//

import Foundation

extension Session {
    open class Delegate: NSObject {
        open internal(set) weak var session: Session?
    }
}

extension Session.Delegate: URLSessionTaskDelegate {
    
}
