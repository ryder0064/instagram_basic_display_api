//
//  InstagramManager.swift
//  instagram_basic_display_api
//
//  Created by 陳耀奇 on 2021/9/2.
//

import Foundation

class InstagramManager {
    private let isTokenValid: ((Bool) -> Void)
    private let userUpdated: ((UserInfoResponse) -> Void)
    private let mediasUpdated: (([[String : Any]]) -> Void)
    private let errorUpdated: ((String) -> Void)

    init(isTokenValid: @escaping (Bool) -> Void, userUpdated: @escaping (UserInfoResponse) -> Void, mediasUpdated: @escaping ([[String : Any]]) -> Void, errorUpdated: @escaping (String) -> Void) {
        self.isTokenValid = isTokenValid
        self.userUpdated = userUpdated
        self.mediasUpdated = mediasUpdated
        self.errorUpdated = errorUpdated
    }
    
    func getTokenValid() {
        isTokenValid(AccessTokenRepository.shared.isTokenValid())
    }
    
    func getUserInfo() {
        do {
            try AccessTokenRepository.shared.getUserInfo { response in
                self.userUpdated(response)
            }
        }catch(let error) {
            guard error as! InstagramErrors == InstagramErrors.tokenInvalid else {
                print(error.localizedDescription)
                return
            }
            self.errorUpdated("tokenInvalid")
        }
    }
    
    func getMedias() {
        do {
            try AccessTokenRepository.shared.getMedias { response in
                self.mediasUpdated(response)
            }
        }catch(let error) {
            guard error as! InstagramErrors == InstagramErrors.tokenInvalid else {
                print(error.localizedDescription)
                return
            }
            self.errorUpdated("tokenInvalid")
        }
    }
    
    func logout(){
        AccessTokenRepository.shared.logout()
        self.userUpdated(UserInfoResponse(id: "", username: "", accountType: ""))
    }
}
