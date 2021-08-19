//
//  Tweet.swift
//  Tweet
//
//  Created by Jaehong Kang on 2021/08/15.
//

import Foundation

public struct Tweet {
    public let id: String
    
    public let text: String
    
    public let createdAt: Date
}

extension Tweet: Hashable {}
extension Tweet: Identifiable {}

extension Tweet: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, text
        case createdAt = "created_at"
    }
    
    enum CodingKeysV1: String, CodingKey {
        case id = "id_str"
        case fullText = "full_text"
        case createdAt = "created_at"
    }
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let id = try container.decode(String.self, forKey: .id)
            let text = try container.decode(String.self, forKey: .text)
            let createdAt = try container.decode(Date.self, forKey: .createdAt)
            
            self.id = id
            self.text = text
            self.createdAt = createdAt
        } catch let originalError {
            do {
                let container = try decoder.container(keyedBy: CodingKeysV1.self)

                self.id = try container.decode(String.self, forKey: .id)
                self.text = try container.decode(String.self, forKey: .fullText)
                self.createdAt = try container.decode(Date.self, forKey: .createdAt)
            } catch {
                debugPrint(error)
                throw originalError
            }
        }
    }
}
