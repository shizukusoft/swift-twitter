//
//  TwitterServerArrayResponseV2.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation
import TwitterCore

struct TwitterServerArrayResponseV2<Element>: Decodable where Element: Decodable {
    struct Meta: Decodable {
        let resultCount: Int

        let previousToken: String?
        let nextToken: String?

        enum CodingKeys: String, CodingKey {
            case resultCount = "result_count"
            case previousToken = "previous_token"
            case nextToken = "next_token"
        }
    }

    let data: [Element]?
    let meta: Meta?
    let errors: [TwitterServerError]?
}
