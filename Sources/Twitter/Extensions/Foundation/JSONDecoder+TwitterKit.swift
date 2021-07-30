//
//  Foundaion.JSONDecoder.swift
//  
//
//  Created by Jaehong Kang on 2021/02/24.
//

import Foundation

extension JSONDecoder {
    public static var twtk_default: JSONDecoder {
        let jsonDecoder = JSONDecoder()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

        return jsonDecoder
    }
}
