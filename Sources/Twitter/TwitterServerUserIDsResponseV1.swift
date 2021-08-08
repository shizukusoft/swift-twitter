//
//  TwitterServerUserIDsResponseV1.swift
//  swift-twitter
//
//  Created by Jaehong Kang on 2021/08/08.
//

import Foundation

struct TwitterServerUserIDsResponseV1 {
    let ids: [User.ID]

    let nextCursor: Int
    let previousCursor: Int
}

extension TwitterServerUserIDsResponseV1: Decodable {
    enum CodingKeys: String, CodingKey {
        case ids
        case nextCursor = "next_cursor"
        case previousCursor = "previous_cursor"
    }
}
