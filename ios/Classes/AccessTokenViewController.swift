//
//  AccessTokenViewController.swift
//  instagram_basic_display_api
//
//  Created by 陳耀奇 on 2021/8/2.
//

import UIKit
import WebKit
import Combine

class AccessTokenViewController: UIViewController, WKUIDelegate, WKNavigationDelegate{
    
    var webView: WKWebView!
    var delegate: DismissBackDelegate?
    
    var clientId: String?
    var clientSecret: String?
    var redirectUri: String?
    
    private let viewModel = AccessTokenViewModel()
    private var cancellable: AnyCancellable? = nil
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientId = Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_CLIENT_ID") as? String
        clientSecret = Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_CLIENT_SECRET") as? String
        redirectUri = Bundle.main.object(forInfoDictionaryKey: "REDIRECT_URI") as? String
        
        if clientId != nil && redirectUri != nil {
            let urlString = "https://www.instagram.com/oauth/authorize?client_id=\(clientId!)&redirect_uri=\(redirectUri!)&scope=user_profile,user_media&response_type=code"
            
            print("\n\n\n\n QQQQ \n\(urlString)")
            
            let myURL = URL(string:urlString)
            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
        }else{
            print("Need to set Secrets.xcconfig first.")
        }
        
        cancellable = viewModel.objectWillChange.sink { [weak self] in
            self?.render()
        }
    }
    
    private func render() {
        switch viewModel.state {
        case .isLoading:
            print("isLoading")
        // Show loading spinner
        case .failed(let error):
            print("failed \(error)")
        case .loaded:
            print("loaded")
        }
    }
    
    deinit {
        delegate?.dissmissBack(sentData: false)
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let frame = navigationAction.targetFrame,
           !frame.isMainFrame {
            decisionHandler(.cancel)
            return
        }
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        print("\n\n\n\n url = \(url.absoluteString) \n\n\n\n \(url.absoluteString.starts(with: redirectUri!)) \n\n\n\n\n")
        
        if url.absoluteString.starts(with: redirectUri!) {
            decisionHandler(.cancel)
            //            delegate?.dissmissBack(sentData: true)
            //            dismiss(animated: true, completion: nil)
          
            let index = url.absoluteString.index(of: "code=")!
            let start = url.absoluteString.index(index, offsetBy: 5)
            let end = url.absoluteString.index(url.absoluteString.endIndex, offsetBy: -2)
            
            let range = start..<end
            
            let substring = url.absoluteString[range]
            let code = String(substring)
            
            viewModel.getAccessToken(clientId: clientId!, clientSecret: clientSecret!, code: code, redirectUri: redirectUri!)
            
        }
        else {
            decisionHandler(.allow)
        }
    }
}
