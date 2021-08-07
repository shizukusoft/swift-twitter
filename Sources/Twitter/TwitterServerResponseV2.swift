//
//  TwitterServerResponseV2.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation

struct TwitterServerResponseV2<Value>: Decodable where Value: Decodable {
    let data: Result<Value, TwitterServerError>
}
