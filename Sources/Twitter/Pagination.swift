//
//  Pagination.swift
//  
//
//  Created by Jaehong Kang on 2021/03/22.
//

import Foundation

public struct Pagination<Element> {
    public let paginatedItems: Array<Element>

    public let previousToken: String?
    public let nextToken: String?
}

extension Pagination {
    init<V>(_ response: TwitterServerArrayResponseV2<V>) where Element == Result<V, TwitterServerError> {
        self.paginatedItems = response.data ?? []
        self.previousToken = response.meta?.previousToken
        self.nextToken = response.meta?.nextToken
    }
}

extension Pagination where Element == User.ID {
    init(_ response: TwitterServerUserIDsResponseV1) {
        self.paginatedItems = response.ids
        self.previousToken = response.previousCursor != 0 ? String(response.previousCursor) : nil
        self.nextToken = response.nextCursor != 0 ? String(response.nextCursor) : nil
    }
}
