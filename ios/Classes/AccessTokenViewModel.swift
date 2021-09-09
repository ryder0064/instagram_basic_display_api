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
        case loaded(UserInfoResponse)
    }
    
    @Published private(set) var state :State? = nil
    
    func getAccessToken(clientId: String, clientSecret: String, code: String, redirectUri: String) {
        state = State.isLoading
        
        AccessTokenRepository.shared.getShortAccessTokenInfo(clientId: clientId, clientSecret: clientSecret, code: code, redirectUri: redirectUri) { response in
            DispatchQueue.main.async {
                AccessTokenRepository.shared.getLongAccessTokenInfo(accessToken: response.accessToken, clientSecret: clientSecret, grantType: "ig_exchange_token") { longAccessTokenResponse in
                    
                    AccessTokenRepository.shared.saveInstagramInfo(userId: clientId, accessToken: longAccessTokenResponse.accessToken, expiresIn: longAccessTokenResponse.expiresIn)
                    
                    do {
                        try AccessTokenRepository.shared.getUserInfo { response in
                            self.state = State.loaded(response)
                        }
                    }catch(let error) {
                        print(error.localizedDescription)
                        self.state = State.failed(error)
                    }

                }
            }
        }
    }
}
