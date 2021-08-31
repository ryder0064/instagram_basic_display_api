//
//  AccessToken.swift
//  instagram_basic_display_api
//
//  Created by 陳耀奇 on 2021/8/9.
//

import Foundation

struct ShortAccessTokenResponse: Decodable {
    var accessToken : String
    var userId : Int
}

struct LongAccessTokenResponse: Decodable {
    var accessToken : String
    var tokenType : String
    var expiresIn: Int64
}

struct InstagramUser :Codable{
    var userId : String
    var accessToken : String
    var expiresIn: Int64
}
