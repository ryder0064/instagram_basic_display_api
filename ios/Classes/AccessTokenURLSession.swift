//
//  AccessTokenURLSession.swift
//  instagram_basic_display_api
//
//  Created by 陳耀奇 on 2021/8/9.
//

import Foundation


class AccessTokenURLSession {
    static let shared = AccessTokenURLSession()
    
    private let boundary = "boundary=\(NSUUID().uuidString)"
    
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
