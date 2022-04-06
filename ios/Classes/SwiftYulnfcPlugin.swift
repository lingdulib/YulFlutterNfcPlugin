import Flutter
import UIKit
import CoreNFC

///ios mifare卡，具体未测试，不知道是否支持m1卡
public class SwiftYulnfcPlugin: NSObject, FlutterPlugin {

    private let channel: FlutterMethodChannel

    @available(iOS 13.0, *)
    private lazy var session: NFCTagReaderSession? = nil

    @available(iOS 13.0, *)
    private lazy var tags: [String : NFCNDEFTag] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "yulnfc", binaryMessenger: registrar.messenger())
    let instance = SwiftYulnfcPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private init(_ channel: FlutterMethodChannel){
         self.channel=channel
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard #available(iOS 13.0, *) else {
          result(FlutterError(code: "unavailable", message: "仅适用于iOS 13.0或更新版本.", details: nil))
          return
        }
       switch call.method {
           case "nfcSupport":handleNfcIsAvailable(call.arguments, result: result)

           default: result(FlutterMethodNotImplemented)
       }
  }

    //设备是否支持nfc标签读取
    @available(iOS 13.0, *)
    private func handleNfcIsAvailable(_ arguments: Any?, result: @escaping FlutterResult) {
      result(NFCTagReaderSession.readingAvailable)
    }

   //寻卡
    @available(iOS 13.0, *)
    private func handleNfcStartSession(result: @escaping FlutterResult) {
        session = NFCTagReaderSession(pollingOption: getPollingOption(), delegate: self)
        session?.alertMessage = "把你的iPhone放在一个NFC标签旁边。"
        session?.begin()
        result(nil)
    }

     @available(iOS 13.0, *)
      private func handleNfcStopSession(_ arguments: [String : Any?], result: @escaping FlutterResult) {
        guard let session = session else {
          result(nil)
          return
        }

        if let errorMessage = arguments["errorMessage"] as? String {
          session.invalidate(errorMessage: errorMessage)
          self.session = nil
          result(nil)
        }

        if let alertMessage = arguments["alertMessage"] as? String { session.alertMessage = alertMessage }
        session.invalidate()
        self.session = nil
        result(nil)
      }

}

@available(iOS 13.0, *)
extension SwiftYulnfcPlugin: NFCTagReaderSessionDelegate {

  public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
  }

  public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
    channel.invokeMethod("onError", arguments: getErrorMap(error))
  }

  public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
   ///读取到nfc标签
    let handle = NSUUID().uuidString
    session.connect(to: tags.first!) { error in
      if let error = error {
        // skip tag detection
        print(error)
        return
      }
      getNFCTagMapAsync(tags.first!) { tag, data, error in
        if let error = error {
          // skip tag detection
          print(error)
          return
        }
        self.tags[handle] = tag
        self.channel.invokeMethod("onDiscovered", arguments: data.merging(["handle": handle]) { cur, _ in cur })
      }
    }
  }
}
