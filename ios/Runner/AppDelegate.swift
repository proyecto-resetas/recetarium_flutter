import Flutter
import UIKit
import Security

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let securityChannel = FlutterMethodChannel(name: "com.recetarium/security",
                                              binaryMessenger: controller.binaryMessenger)
    
    securityChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getEncryptionKey" {
        self.getOrCreateMasterKey(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getOrCreateMasterKey(result: FlutterResult) {
    let keyName = "com.recetarium.hive_master_key"
    
    // Intentar leer la clave del Keychain
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: keyName,
        kSecReturnData as String: kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var dataTypeRef: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
    
    if status == errSecSuccess {
        // La clave existe, la retornamos
        if let keyData = dataTypeRef as? Data {
            result(FlutterStandardTypedData(bytes: keyData))
            return
        }
    }
    
    // Si no existe, generamos una nueva de 32 bytes (AES-256)
    var keyBytes = [UInt8](repeating: 0, count: 32)
    let _ = SecRandomCopyBytes(kSecRandomDefault, keyBytes.count, &keyBytes)
    let keyData = Data(keyBytes)
    
    // Guardamos la nueva clave en el Keychain
    let addQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: keyName,
        kSecValueData as String: keyData,
        kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    ]
    
    let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
    
    if addStatus == errSecSuccess {
        result(FlutterStandardTypedData(bytes: keyData))
    } else {
        result(FlutterError(code: "SECURE_KEY_ERROR", 
                           message: "Error saving key to Keychain", 
                           details: nil))
    }
  }
}
