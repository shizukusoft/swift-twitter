//
//  File.swift
//  File
//
//  Created by Jaehong Kang on 2021/07/30.
//

import Foundation

public enum SessionError: Error {
    case unknown
    case serverError(TwitterServerError?)
    case dataCorrupted
}
