//
//  Foundation.CharacterSet.swift
//  
//
//  Created by Jaehong Kang on 2021/02/23.
//

import Foundation

extension CharacterSet {
    public static let twtk_rfc3986Allowed: CharacterSet = {
        let digits = CharacterSet(charactersIn: "0123456789")
        let uppercaseLetters = CharacterSet(charactersIn: "ABCDEFGHJIKLMNOPQRSTUVWXYZ")
        let lowercaseLetters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
        let reservedCharacters = CharacterSet(charactersIn: "-._~")

        return digits.union(uppercaseLetters).union(lowercaseLetters).union(reservedCharacters)
    }()
}
