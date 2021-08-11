//
//  AccessToken.swift
//  instagram_basic_display_api
//
//  Created by 陳耀奇 on 2021/8/9.
//

import Foundation

struct ShortAccessTokenRequestBody: Encodable {
    var clientId: String
    var clientSecret: String
    var code: String
    var grantType: String
    var redirectUri: String
}

struct ShortAccessTokenResponse: Decodable {
    var accessToken : String
    var userId : Int
}

struct LongAccessTokenRequestBody: Encodable {
    var grantType: String
    var clientSecret: String
    var accessToken: String
}

struct LongAccessTokenResponse: Decodable {
    var accessToken : String
    var tokenType : String
    var expiresIn: Int64
}
