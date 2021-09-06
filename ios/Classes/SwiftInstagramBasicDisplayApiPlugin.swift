import Flutter
import UIKit

public class SwiftInstagramBasicDisplayApiPlugin: NSObject, FlutterPlugin {
    private var instagramManager: InstagramManager!
    private var channel: FlutterMethodChannel
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "instagram_basic_display_api", binaryMessenger: registrar.messenger())
        let instance = SwiftInstagramBasicDisplayApiPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
        self.instagramManager = InstagramManager(
            isTokenValid: { isTokenValid in
                self.channel.invokeMethod("isInstagramTokenValid", arguments: "")
            }, userUpdated: { userInfoResponse in
                print("Ryder userInfoResponse = \(userInfoResponse), \(userInfoResponse.id), \(userInfoResponse.username), \(userInfoResponse.accountType)")
                self.channel.invokeMethod("userUpdated", arguments: [
                                            "ID": userInfoResponse.id,
                                            "USER_NAME": userInfoResponse.username,
                                            "ACCOUNT_TYPE": userInfoResponse.accountType])
            }, mediasUpdated: { mediasResponse in
                self.channel.invokeMethod("mediasUpdated", arguments: [
                                            "DATA": mediasResponse])
            }, errorUpdated: { type in
                self.channel.invokeMethod("errorUpdated", arguments: [
                                            "ERROR_TYPE": type])
            }
        )
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "isInstagramTokenValid":
            instagramManager.getTokenValid()
            result(nil)
        case "askInstagramToken":
            askInstagramToken()
            result(nil)
        case "getInstagramUser":
            instagramManager.getUserInfo()
            result(nil)
        case "getMedias":
            instagramManager.getMedias()
            result(nil)
        case "logout":
            instagramManager.logout()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    class DismissBackImpl : DismissBackDelegate {
        var channel: FlutterMethodChannel
        init(channel: FlutterMethodChannel) {
            self.channel = channel
        }
        func dismissBack(userInfoResponse: UserInfoResponse?) {
            guard userInfoResponse != nil else {
                self.channel.invokeMethod("errorUpdated", arguments: ["errorType": "type"])
                return
            }
            
            self.channel.invokeMethod("userUpdated", arguments: [
                                        "ID": userInfoResponse!.id,
                                        "USER_NAME": userInfoResponse!.username,
                                        "ACCOUNT_TYPE": userInfoResponse!.accountType])
        }
    }
    
    func askInstagramToken(){
        let host = AccessTokenViewController();
        
        host.delegate = DismissBackImpl(channel:channel)
        
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        
        viewController?.present(host, animated: true, completion: nil)
    }
}

protocol DismissBackDelegate {
    func dismissBack(userInfoResponse: UserInfoResponse?)
}
