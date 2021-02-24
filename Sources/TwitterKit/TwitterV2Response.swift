//
//  TwitterV2Response.swift
//  
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation

struct TwitterV2Response<T: Decodable>: Decodable {
    let data: T
}
