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
            userUpdated: { userInfoResponse in
                print("userInfoResponse = \(userInfoResponse), \(userInfoResponse.id), \(userInfoResponse.username), \(userInfoResponse.accountType)")
                self.channel.invokeMethod("userUpdated", arguments: [
                                            "ID": userInfoResponse.id,
                                            "USER_NAME": userInfoResponse.username,
                                            "ACCOUNT_TYPE": userInfoResponse.accountType])
            }, mediasUpdated: { mediasResponse in
                self.channel.invokeMethod("mediasUpdated", arguments: [
                                            "DATA": mediasResponse])
            }, albumDetailUpdated: { albumDetailResponse in
                self.channel.invokeMethod("albumDetailUpdated", arguments: [
                                            "DATA": albumDetailResponse])
            }, mediaItemUpdated: { mediaItemResponse in
                self.channel.invokeMethod("mediaItemUpdated", arguments: mediaItemResponse)
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
        case "askInstagramToken":
            askInstagramToken()
            result(nil)
        case "getInstagramUser":
            instagramManager.getUserInfo()
            result(nil)
        case "getMedias":
            instagramManager.getMedias()
            result(nil)
        case "getAlbumDetail":
            guard let arguments = call.arguments as? [AnyHashable: Any] else { return }
            guard let albumId = arguments["albumId"] as? String else {
                return
            }
            instagramManager.getAlbumDetail(albumId: albumId)
            result(nil)
        case "getMediaItem":
            guard let arguments = call.arguments as? [AnyHashable: Any] else { return }
            guard let mediaId = arguments["mediaId"] as? String else {
                return
            }
            instagramManager.getMediaItem(mediaId: mediaId)
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
                self.channel.invokeMethod("errorUpdated", arguments: ["ERROR_TYPE": "ASK_TOKEN_INTERRUPT"])
                return
            }
            
            self.channel.invokeMethod("userUpdated", arguments: [
                                        "ID": userInfoResponse!.id,
                                        "USER_NAME": userInfoResponse!.username,
                                        "ACCOUNT_TYPE": userInfoResponse!.accountType])
        }
    }
    
    func askInstagramToken(){
        
        guard instagramManager.hasFoundInstagramClient() else {
            return
        }
        
        print("Need to set Secrets.xcconfig first.")

        let host = AccessTokenViewController();
        
        host.delegate = DismissBackImpl(channel:channel)
        
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        
        viewController?.present(host, animated: true, completion: nil)
    }
}

protocol DismissBackDelegate {
    func dismissBack(userInfoResponse: UserInfoResponse?)
}
