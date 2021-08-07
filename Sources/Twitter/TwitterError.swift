//
//  File.swift
//  File
//
//  Created by Jaehong Kang on 2021/07/30.
//

import Foundation

public enum TwitterError: Error {
    case unknown
    case serverError(urlResponse: URLResponse, serverError: TwitterServerError? = nil)
    case dataCorrupted
}
