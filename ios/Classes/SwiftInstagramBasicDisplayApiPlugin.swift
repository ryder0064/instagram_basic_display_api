import Flutter
import UIKit

public class SwiftInstagramBasicDisplayApiPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "instagram_basic_display_api", binaryMessenger: registrar.messenger())
    let instance = SwiftInstagramBasicDisplayApiPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
