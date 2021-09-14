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
    private let mediaItemUpdated: (([String : Any]) -> Void)
    private let errorUpdated: ((String) -> Void)

    init(userUpdated: @escaping (UserInfoResponse) -> Void,
         mediasUpdated: @escaping ([[String : Any]]) -> Void,
         albumDetailUpdated: @escaping ([[String : Any]]) -> Void,
         mediaItemUpdated: @escaping ([String : Any]) -> Void,
         errorUpdated: @escaping (String) -> Void) {
        self.userUpdated = userUpdated
        self.mediasUpdated = mediasUpdated
        self.albumDetailUpdated = albumDetailUpdated
        self.mediaItemUpdated = mediaItemUpdated
        self.errorUpdated = errorUpdated
    }
    
    func getUserInfo() {
        do {
            try AccessTokenRepository.shared.getUserInfo { response in
                self.userUpdated(response)
            }
        }catch(let error) {
            if(error as? InstagramErrors == InstagramErrors.tokenEmpty){
                self.errorUpdated("TOKEN_EMPTY")
                return
            }
            if(error as? InstagramErrors == InstagramErrors.tokenExpired){
                self.errorUpdated("TOKEN_EXPIRED")
                return
            }
            print(error.localizedDescription)
            self.errorUpdated("UNKNOWN_EXCEPTION")
        }
    }
    
    func getMedias() {
        do {
            try AccessTokenRepository.shared.getMedias { response in
                self.mediasUpdated(response)
            }
        }catch(let error) {
            if(error as? InstagramErrors == InstagramErrors.tokenEmpty){
                self.errorUpdated("TOKEN_EMPTY")
                return
            }
            if(error as? InstagramErrors == InstagramErrors.tokenExpired){
                self.errorUpdated("TOKEN_EXPIRED")
                return
            }
            print(error.localizedDescription)
            self.errorUpdated("UNKNOWN_EXCEPTION")
        }
    }
    
    func getAlbumDetail(albumId: String) {
        do {
            try AccessTokenRepository.shared.getAlbumDetail(albumId: albumId, completionHandler: { response in
                self.albumDetailUpdated(response)
            })
        }catch(let error) {
            if(error as? InstagramErrors == InstagramErrors.tokenEmpty){
                self.errorUpdated("TOKEN_EMPTY")
                return
            }
            if(error as? InstagramErrors == InstagramErrors.tokenExpired){
                self.errorUpdated("TOKEN_EXPIRED")
                return
            }
            print(error.localizedDescription)
            self.errorUpdated("UNKNOWN_EXCEPTION")
        }
    }
    
    func getMediaItem(mediaId: String) {
        do {
            try AccessTokenRepository.shared.getMediaItem(mediaId: mediaId, completionHandler: { response in
                self.mediaItemUpdated(response)
            })
        }catch(let error) {
            if(error as? InstagramErrors == InstagramErrors.tokenEmpty){
                self.errorUpdated("TOKEN_EMPTY")
                return
            }
            if(error as? InstagramErrors == InstagramErrors.tokenExpired){
                self.errorUpdated("TOKEN_EXPIRED")
                return
            }
            print(error.localizedDescription)
            self.errorUpdated("UNKNOWN_EXCEPTION")
        }
    }
    
    func logout(){
        AccessTokenRepository.shared.logout()
        self.userUpdated(UserInfoResponse(id: "", username: "", accountType: ""))
    }
    
    func hasFoundInstagramClient() -> Bool{
        guard Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_CLIENT_ID") as? String != nil,
              Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_CLIENT_SECRET") as? String != nil,
              Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URI") as? String != nil else {
            self.errorUpdated("NOT_FOUND_IG_CLIENT")
            return false
        }
        return true
    }
}
