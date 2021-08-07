//
//  TwitterServerArrayResponseV2.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/07.
//

import Foundation

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

    let data: [Result<Element, TwitterServerError>]?
    let meta: Meta?
}
