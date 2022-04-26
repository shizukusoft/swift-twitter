//
//  JSONDecoder+Twitter.swift
//  
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static func formatted(_ dateFormatters: [DateFormatter]) -> Self {
        .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let date = dateFormatters
                .lazy
                .compactMap {
                    $0.date(from: dateString)
                }
                .first
            
            if let date = date {
                return date
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date string does not match format expected by formatter.")
            }
        }
    }
}

extension JSONDecoder {
    public static var twt_default: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        
        jsonDecoder.dateDecodingStrategy = .formatted([
            {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                
                return dateFormatter
            }(),
            {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z yyyy"
                
                return dateFormatter
            }()
        ])

        return jsonDecoder
    }
}
