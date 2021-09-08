//
//  InstagramManager.swift
//  instagram_basic_display_api
//
//  Created by 陳耀奇 on 2021/9/2.
//

import Foundation

class InstagramManager {
    private let userUpdated: ((UserInfoResponse) -> Void)
    private let mediasUpdated: (([[String : Any]]) -> Void)
    private let albumDetailUpdated: (([[String : Any]]) -> Void)
    private let errorUpdated: ((String) -> Void)

    init(userUpdated: @escaping (UserInfoResponse) -> Void,
         mediasUpdated: @escaping ([[String : Any]]) -> Void,
         albumDetailUpdated: @escaping ([[String : Any]]) -> Void,
         errorUpdated: @escaping (String) -> Void) {
        self.userUpdated = userUpdated
        self.mediasUpdated = mediasUpdated
        self.albumDetailUpdated = albumDetailUpdated
        self.errorUpdated = errorUpdated
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
    
    func getAlbumDetail(album: String) {
        do {
            try AccessTokenRepository.shared.getAlbumDetail(album: album, completionHandler: { response in
                self.albumDetailUpdated(response)
            })
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
