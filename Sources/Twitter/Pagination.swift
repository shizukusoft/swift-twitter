//
//  Pagination.swift
//  
//
//  Created by Jaehong Kang on 2021/03/22.
//

import Foundation
import TwitterCore

public struct Pagination<Element> where Element: Decodable {
    public let items: Array<Element>
    public let errors: Array<TwitterServerError>

    public let previousToken: String?
    public let nextToken: String?
}

extension Pagination {
    init(_ response: TwitterServerArrayResponseV2<Element>) {
        self.items = response.data ?? []
        self.errors = response.errors ?? []
        self.previousToken = response.meta?.previousToken
        self.nextToken = response.meta?.nextToken
    }
}

extension Pagination where Element == User.ID {
    init(_ response: TwitterServerUserIDsResponseV1) {
        self.items = response.ids
        self.errors = []
        self.previousToken = response.previousCursor != 0 ? String(response.previousCursor) : nil
        self.nextToken = response.nextCursor != 0 ? String(response.nextCursor) : nil
    }
}
