//
//  TwitterKitError.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation

public enum TwitterKitError: Swift.Error {
    case unknown
    case request(_ underlyingError: Swift.Error)
}
