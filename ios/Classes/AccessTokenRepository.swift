//
//  AccessTokenURLSession.swift
//  instagram_basic_display_api
//
//  Created by 陳耀奇 on 2021/8/9.
//

import Foundation
import KeychainAccess

class AccessTokenRepository {
    static let shared = AccessTokenRepository()
    
    private let boundary = "boundary=\(NSUUID().uuidString)"
    @KeychainStorage("INSTAGRAM_USER_INFO") private var instagramUser :InstagramUser? = nil
    
    func saveInstagramInfo(userId: String, accessToken: String, expiresIn: Int64)  {
        let newExpiresIn = Int64(NSDate().timeIntervalSince1970) + expiresIn
        instagramUser = InstagramUser(userId: userId, accessToken: accessToken, expiresIn: newExpiresIn)
    }
    
    func isTokenValid() -> Bool {
        if(instagramUser != nil){
            print("\nnow: \(Int64(NSDate().timeIntervalSince1970)), expiresIn: \(instagramUser!.expiresIn)\n")
        }
        if(instagramUser == nil || instagramUser!.expiresIn < Int64(NSDate().timeIntervalSince1970)){
            return false
        }else{
            return true
        }
    }
    
    func getUserInfo(completionHandler: @escaping (UserInfoResponse) -> Void) throws {
        guard instagramUser != nil else {
            throw InstagramErrors.tokenEmpty
        }
        
        guard isTokenValid() == true else {
            throw InstagramErrors.tokenExpired
        }
        
        let url = URL(string: "https://graph.instagram.com/me?fields=id,username,account_type&access_token=\(instagramUser!.accessToken)")!
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let response = try decoder.decode(UserInfoResponse.self, from: data)
                    print("response \(response)")
                    completionHandler(response)
                    
                }catch(let error) {
                    print(error.localizedDescription)
                }
            } else {
                print("No Data")
            }
        }.resume()
    }
    
    func getMedias(completionHandler: @escaping ([[String : Any]]) -> Void) throws {
        guard instagramUser != nil else {
            throw InstagramErrors.tokenEmpty
        }
        
        guard isTokenValid() == true else {
            throw InstagramErrors.tokenExpired
        }
        
        let url = URL(string: "https://graph.instagram.com/me/media?fields=id,caption,media_type,timestamp,permalink,media_url,thumbnail_url&access_token=\(instagramUser!.accessToken)")!
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // try to read out a dictionary
                        print("json = \(json)")
                        if let data = json["data"] as? [[String:Any]] {
                            print("\n\n\n\ndata = \(data)")
                            completionHandler(data)
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            } else {
                print("No Data")
            }
        }.resume()
    }
    
    func getAlbumDetail(albumId: String, completionHandler: @escaping ([[String : Any]]) -> Void) throws {
        guard instagramUser != nil else {
            throw InstagramErrors.tokenEmpty
        }
        
        guard isTokenValid() == true else {
            throw InstagramErrors.tokenExpired
        }
        
        let url = URL(string: "https://graph.instagram.com/\(albumId)/children?fields=id,media_type,media_url,timestamp,thumbnail_url&access_token=\(instagramUser!.accessToken)")!
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // try to read out a dictionary
                        print("json = \(json)")
                        if let data = json["data"] as? [[String:Any]] {
                            print("\n\n\n\ndata = \(data)")
                            completionHandler(data)
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            } else {
                print("No Data")
            }
        }.resume()
    }
    
    func getMediaItem(mediaId: String, completionHandler: @escaping ([String : Any]) -> Void) throws {
        guard instagramUser != nil else {
            throw InstagramErrors.tokenEmpty
        }
        
        guard isTokenValid() == true else {
            throw InstagramErrors.tokenExpired
        }
        
        let url = URL(string: "https://graph.instagram.com/\(mediaId)?fields=id,caption,media_type,timestamp,permalink,media_url,thumbnail_url&access_token=\(instagramUser!.accessToken)")!
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("\n\n\n\njson = \(json)")
                        completionHandler(json)
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            } else {
                print("No Data")
            }
        }.resume()
    }
    
    func getShortAccessTokenInfo(clientId: String, clientSecret: String, code: String, redirectUri: String, completionHandler: @escaping (ShortAccessTokenResponse) -> Void) {
        
        let url = URL(string: "https://api.instagram.com/oauth/access_token")!
        
        
        let headers = [
            "content-type": "multipart/form-data; boundary=\(boundary)"
        ]
        let parameters = [
            [
                "name": "client_id",
                "value": clientId
            ],
            [
                "name": "client_secret",
                "value": clientSecret
            ],
            [
                "name": "grant_type",
                "value": "authorization_code"
            ],
            [
                "name": "redirect_uri",
                "value": redirectUri
            ],
            [
                "name": "code",
                "value": code
            ]
        ]
        
        var request = URLRequest(url: url)
        let postData = getFormBody(parameters, boundary)
        
        request.allHTTPHeaderFields = headers
        request.httpMethod = "POST"
        
        request.httpBody = postData
        
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let response = try decoder.decode(ShortAccessTokenResponse.self, from: data)
                    completionHandler(response)
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print("No Data")
            }
        }.resume()
    }
    
    func getLongAccessTokenInfo(accessToken: String,clientSecret: String,grantType: String, completionHandler: @escaping (LongAccessTokenResponse) -> Void) {
        
        let url = URL(string: "https://graph.instagram.com/access_token?access_token=\(accessToken)&client_secret=\(clientSecret)&grant_type=\(grantType)")!
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let response = try decoder.decode(LongAccessTokenResponse.self, from: data)
                    
                    completionHandler(response)
                    
                }catch(let error) {
                    print(error.localizedDescription)
                }
            } else {
                print("No Data")
            }
        }.resume()
    }
    
    func logout() {
        instagramUser = nil
    }
    
    private func getFormBody(_ parameters: [[String : String]], _ boundary: String) -> Data {
        var body = ""
        let error: NSError? = nil
        for param in parameters {
            let paramName = param["name"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if let filename = param["fileName"] {
                let contentType = param["content-type"]!
                var fileContent: String = ""
                do { fileContent = try String(contentsOfFile: filename, encoding: String.Encoding.utf8)}
                catch {
                    print(error)
                }
                if (error != nil) {
                    print(error!)
                }
                body += "; filename=\"\(filename)\"\r\n"
                body += "Content-Type: \(contentType)\r\n\r\n"
                body += fileContent
            } else if let paramValue = param["value"] {
                body += "\r\n\r\n\(paramValue)"
            }
        }
        return body.data(using: .utf8)!
    }
}

@propertyWrapper
struct KeychainStorage<Value: Codable> {
    
    let key: String
    let service: String
    let initialValue: Value?
    
    private let keychain: KeychainAccess.Keychain
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(wrappedValue initialValue: Value?, _ key: String, service: String? = nil) {
        self.initialValue = initialValue
        self.key = key
        self.service = service ?? Bundle.main.bundleIdentifier ?? "com.kishikawakatsumi.KeychainAccess"
        self.keychain = KeychainAccess.Keychain(service: self.service)
    }
    
    var wrappedValue: Value? {
        get {
            guard let data = try? keychain.getData(key),
                  let value = try? decoder.decode(Value.self, from: data) else {
                return initialValue
            }
            return value
        }
        set {
            guard newValue != nil,
                let newData = try? encoder.encode(newValue) else {
                try? keychain.remove("INSTAGRAM_USER_INFO")
                return
            }
            try? keychain.set(newData, key: key)
        }
    }
}

enum InstagramErrors: Error {
    case tokenEmpty
    case tokenExpired
}
