//
//  TwitterServerResponseV2.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation
import TwitterCore

struct TwitterServerResponseV2<Value>: Decodable where Value: Decodable {
    let data: Value?
    let error: TwitterServerError?
}
