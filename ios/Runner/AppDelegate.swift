import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up YubiKey platform channel
    let controller = window?.rootViewController as! FlutterViewController
    let yubiKeyChannel = FlutterMethodChannel(name: "securevault/yubikey",
                                              binaryMessenger: controller.binaryMessenger)
    
    yubiKeyChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "isYubiKeyConnected":
        self.checkYubiKeyConnection(result: result)
      case "generateTOTP":
        self.generateTOTP(result: result)
      case "performHardwareConfirmation":
        self.performHardwareConfirmation(result: result)
      case "getYubiKeyInfo":
        self.getYubiKeyInfo(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func checkYubiKeyConnection(result: @escaping FlutterResult) {
    // Mock implementation - simulate YubiKey connection
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      // Simulate successful connection for testing
      result(true)
    }
  }
  
  private func generateTOTP(result: @escaping FlutterResult) {
    // Mock TOTP generation
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      let mockTOTP = String(format: "%06d", Int.random(in: 0..<999999))
      result(mockTOTP)
    }
  }
  
  private func performHardwareConfirmation(result: @escaping FlutterResult) {
    // Mock hardware confirmation
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      result(true)
    }
  }
  
  private func getYubiKeyInfo(result: @escaping FlutterResult) {
    // Mock YubiKey info
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      let info: [String: Any] = [
        "name": "YubiKey 5 NFC",
        "version": "5.4.3",
        "serial": "12345678"
      ]
      result(info)
    }
  }
}
