//
//  TwitterV2Response.swift
//  
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation

struct TwitterV2Response<T: Decodable>: Decodable {
    struct Meta: Decodable {
        let resultCount: Int?

        let previousToken: String?
        let nextToken: String?

        enum CodingKeys: String, CodingKey {
            case resultCount = "result_count"
            case previousToken = "previous_token"
            case nextToken = "next_token"
        }
    }

    let data: T?
    let meta: Meta?
}
