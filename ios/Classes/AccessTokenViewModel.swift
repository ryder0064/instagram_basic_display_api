//
//  AccessTokenViewModel.swift
//  instagram_basic_display_api
//
//  Created by 陳耀奇 on 2021/8/9.
//

import Foundation
import CoreData

class AccessTokenViewModel: ObservableObject {
    
    enum State {
        case isLoading
        case failed(Error)
        case loaded
    }
    
    @Published private(set) var state = State.isLoading
    
    func isTokenValid() -> Bool {
        return false
    }
    
    func getAccessToken(clientId: String, clientSecret: String, code: String, redirectUri: String) {
        
        AccessTokenURLSession.shared.getShortAccessTokenInfo(clientId: clientId, clientSecret: clientSecret, code: code, redirectUri: redirectUri) { response in
            DispatchQueue.main.async {
                AccessTokenURLSession.shared.getLongAccessTokenInfo(accessToken: response.accessToken, clientSecret: clientSecret, grantType: "ig_exchange_token") { LongAccessTokenResponse in
                    print("QQQQQ \(LongAccessTokenResponse)")
                }
            }
        }
    }
}
