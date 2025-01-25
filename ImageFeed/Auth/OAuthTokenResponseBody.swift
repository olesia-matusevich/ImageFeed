//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Alesia Matusevich on 23/12/2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let token: String
    
    private enum CodingKeys: String, CodingKey {
        //case token = "access_token"
        case token = "accessToken"
    }
}
