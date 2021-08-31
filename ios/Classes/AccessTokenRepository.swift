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
    let initialValue: Value
    
    private let keychain: KeychainAccess.Keychain
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(wrappedValue initialValue: Value, _ key: String, service: String? = nil) {
        self.initialValue = initialValue
        self.key = key
        self.service = service ?? Bundle.main.bundleIdentifier ?? "com.kishikawakatsumi.KeychainAccess"
        self.keychain = KeychainAccess.Keychain(service: self.service)
        
//        // remove key
//        try? keychain.remove("INSTAGRAM_USER_INFO")
    }
    
    var wrappedValue: Value {
        get {
            guard let data = try? keychain.getData(key),
                  let value = try? decoder.decode(Value.self, from: data) else {
                return initialValue
            }
            return value
        }
        set {
            guard let newData = try? encoder.encode(newValue) else {
                return
            }
            try? keychain.set(newData, key: key)
        }
    }
}
