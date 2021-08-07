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
    init(_ response: TwitterV2Response<[Element]>) where Element: Decodable {
        self.paginatedItems = response.data ?? []
        self.previousToken = response.meta?.previousToken
        self.nextToken = response.meta?.nextToken
    }
}
