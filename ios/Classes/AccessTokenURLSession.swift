//
//  AccessTokenURLSession.swift
//  instagram_basic_display_api
//
//  Created by 陳耀奇 on 2021/8/9.
//

import Foundation


class AccessTokenURLSession {
    static let shared = AccessTokenURLSession()
    
    func getShortAccessTokenInfo(requestBody: ShortAccessTokenRequestBody,completionHandler: @escaping (ShortAccessTokenResponse) -> Void) {
        print("requestBody \(requestBody) ")
        
        let url = URL(string: "https://api.instagram.com/oauth/access_token")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let httpBody = try? encoder.encode(requestBody) else {
            print("Invalid httpBody")
            return
        }
        
        request.httpBody = httpBody
        print("httpBody \(httpBody) ")
        
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let response = try decoder.decode(ShortAccessTokenResponse.self, from: data)
                    completionHandler(response)
                } catch {
                    let httpResponse = response as! HTTPURLResponse
                    print("\nhttpResponse.statusCode = \(httpResponse.statusCode)\n")
                    print("\nhttpResponse.allHeaderFields = \(httpResponse.allHeaderFields)\n")
                    print("\nhttpResponse.description = \(httpResponse.description)\n")

                    let outputStr  = String(data: data, encoding: String.Encoding.utf8)! as String
                    print("data = \(outputStr)")
                }
                            
            } else {
                print("No Data")
            }
        }.resume()
    }
    
    func getLongAccessTokenInfo(requestBody: LongAccessTokenRequestBody, completionHandler: @escaping (LongAccessTokenResponse) -> Void) {
        
        let url = URL(string: "https://graph.instagram.com/access_token")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let httpBody = try? JSONEncoder().encode(requestBody) else {
            print("Invalid httpBody")
            return
        }
        
        request.httpBody = httpBody
        
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
}
