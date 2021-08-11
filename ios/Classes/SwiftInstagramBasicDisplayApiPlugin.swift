import Flutter
import UIKit

public class SwiftInstagramBasicDisplayApiPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "instagram_basic_display_api", binaryMessenger: registrar.messenger())
        let instance = SwiftInstagramBasicDisplayApiPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "isInstagramTokenValid":
            checkTokenValid(result:result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    class DismissBackImpl : DismissBackDelegate {
        var result: FlutterResult
        init(result: @escaping FlutterResult) {
            self.result = result
        }
        
        func dissmissBack(sentData: Bool) {
            print("dissmissBack data = \(sentData)")
            result(sentData)
        }
    }
    
    func checkTokenValid(result: @escaping FlutterResult){
        
        let host = AccessTokenViewController();
        
        host.delegate = DismissBackImpl(result:result)
        
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        
        viewController?.present(host, animated: true, completion: nil)
    }
}

protocol DismissBackDelegate {
    func dissmissBack(sentData:Bool)
}

