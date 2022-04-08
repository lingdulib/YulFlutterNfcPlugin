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
    let instance = SwiftYulnfcPlugin(channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  //初始化
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
           case "startSession": handleNfcStartSession(result: result)
           case "stopSession": handleNfcStopSession(call.arguments as! [String : Any?], result: result)
           case "disposeTag": handleNfcDisposeTag(call.arguments as! [String : Any?], result: result) //销毁临时存储
           case "read": handleNdefRead(call.arguments as! [String : Any?], result: result)
           case "write": handleNdefWrite(call.arguments as! [String : Any?], result: result)
           case "readSingleBlock": handleIso15693ReadSingleBlock(call.arguments as! [String : Any?], result: result)
           case "writeSingleBlock": handleIso15693WriteSingleBlock(call.arguments as! [String : Any?], result: result)
           case "readMultipleBlocks": handleIso15693ReadMultipleBlocks(call.arguments as! [String : Any?], result: result)
           case "writeMultipleBlocks": handleIso15693WriteMultipleBlocks(call.arguments as! [String : Any?], result: result)
           case "select": handleIso15693Select(call.arguments as! [String : Any?], result: result)
           case "stayQuiet": handleIso15693StayQuiet(call.arguments as! [String : Any?], result: result)
           case "getSystemInfo": handleIso15693GetSystemInfo(call.arguments as! [String : Any?], result: result)
           case "sendCommand": handleIso7816SendCommand(call.arguments as! [String : Any?], result: result)
           case "sendCommandRaw": handleIso7816SendCommandRaw(call.arguments as! [String : Any?], result: result)
           case "sendMiFareCommand": handleMiFareSendMiFareCommand(call.arguments as! [String : Any?], result: result)
           case "sendMiFareIso7816Command": handleMiFareSendMiFareIso7816Command(call.arguments as! [String : Any?], result: result)
           case "sendMiFareIso7816CommandRaw": handleMiFareSendMiFareIso7816CommandRaw(call.arguments as! [String : Any?], result: result)
           default: result(nil)
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

    //停止寻卡
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

       //销毁临时存储
       @available(iOS 13.0, *)
       private func handleNfcDisposeTag(_ arguments: [String : Any?], result: @escaping FlutterResult) {
           tags.removeValue(forKey: arguments["handle"] as! String)
           result(nil)
       }

       //ndef 读卡
       @available(iOS 13.0, *)
       private func handleNdefRead(_ arguments: [String : Any?], result: @escaping FlutterResult) {
            tagHandler(NFCNDEFTag.self, arguments, result) { tag in
            tag.readNDEF { message, error in
                 if let error = error {
                     result(getFlutterError(error))
                 } else {
                     result(message == nil ? nil : getNDEFMessageMap(message!))
                 }
            }
          }
       }

      //ndef 写卡
      @available(iOS 13.0, *)
      private func handleNdefWrite(_ arguments: [String : Any?], result: @escaping FlutterResult) {
            tagHandler(NFCNDEFTag.self, arguments, result) { tag in
            let message = getNDEFMessage(arguments["message"] as! [String : Any?])
                tag.writeNDEF(message) { error in
                    if let error = error {
                         result(getFlutterError(error))
                     } else {
                         result(nil)
                     }
                 }
             }
      }

    //通用
     @available(iOS 13.0, *)
     private func tagHandler<T>(_ dump: T.Type, _ arguments: [String : Any?], _ result: FlutterResult, callback: ((T) -> Void)) {
        //获取nfc tag实例
        if let tag = tags[arguments["handle"] as! String] as? T {
            callback(tag)
        } else {
            result(FlutterError(code: "invalid_parameter", message: "Tag is not found", details: nil))
        }
    }

     @available(iOS 13.0, *)
     private func handleIso15693ReadSingleBlock(_ arguments: [String : Any?], result: @escaping FlutterResult) {
        tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
          let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
          let blockNumber = arguments["blockNumber"] as! UInt8
          tag.readSingleBlock(requestFlags: requestFlags, blockNumber: blockNumber) { dataBlock, error in
            if let error = error {
              result(getFlutterError(error))
            } else {
              result(dataBlock)
            }
          }
        }
     }

      @available(iOS 13.0, *)
      private func handleIso15693WriteSingleBlock(_ arguments: [String : Any?], result: @escaping FlutterResult) {
        tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
          let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
          let blockNumber = arguments["blockNumber"] as! UInt8
          let dataBlock = (arguments["dataBlock"] as! FlutterStandardTypedData).data
          tag.writeSingleBlock(requestFlags: requestFlags, blockNumber: blockNumber, dataBlock: dataBlock) { error in
            if let error = error {
              result(getFlutterError(error))
            } else {
              result(nil)
            }
          }
        }
      }

        @available(iOS 13.0, *)
        private func handleIso15693ReadMultipleBlocks(_ arguments: [String : Any?], result: @escaping FlutterResult) {
          tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
            let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
            let blockNumber = arguments["blockNumber"] as! Int
            let numberOfBlocks = arguments["numberOfBlocks"] as! Int
            tag.readMultipleBlocks(requestFlags: requestFlags, blockRange: NSMakeRange(blockNumber, numberOfBlocks)) { dataBlocks, error in
              if let error = error {
                result(getFlutterError(error))
              } else {
                result(dataBlocks)
              }
            }
          }
        }

        @available(iOS 13.0, *)
        private func handleIso15693WriteMultipleBlocks(_ arguments: [String : Any?], result: @escaping FlutterResult) {
          tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
            let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
            let blockNumber = arguments["blockNumber"] as! Int
            let numberOfBlocks = arguments["numberOfBlocks"] as! Int
            let dataBlocks = (arguments["dataBlocks"] as! [FlutterStandardTypedData]).map { $0.data }
            tag.writeMultipleBlocks(requestFlags: requestFlags, blockRange: NSMakeRange(blockNumber, numberOfBlocks), dataBlocks: dataBlocks) { error in
              if let error = error {
                result(getFlutterError(error))
              } else {
                result(nil)
              }
            }
          }
        }

        @available(iOS 13.0, *)
        private func handleIso15693Select(_ arguments: [String : Any?], result: @escaping FlutterResult) {
            tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
              let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
              tag.select(requestFlags: requestFlags) { error in
                if let error = error {
                  result(getFlutterError(error))
                } else {
                  result(nil)
                }
              }
            }
         }

         @available(iOS 13.0, *)
          private func handleIso15693StayQuiet(_ arguments: [String : Any?], result: @escaping FlutterResult) {
            tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
              tag.stayQuiet { error in
                if let error = error {
                  result(getFlutterError(error))
                } else {
                  result(nil)
                }
              }
            }
         }

          @available(iOS 13.0, *)
          private func handleIso15693GetSystemInfo(_ arguments: [String : Any?], result: @escaping FlutterResult) {
             tagHandler(NFCISO15693Tag.self, arguments, result) { tag in
               let requestFlags = getRequestFlags(arguments["requestFlags"] as! [String])
               tag.getSystemInfo(requestFlags: requestFlags) { dataStorageFormatIdentifier, applicationFamilyIdentifier, blockSize, totalBlocks, icReference, error in
                 if let error = error {
                   result(getFlutterError(error))
                 } else {
                   result([
                     "dataStorageFormatIdentifier": dataStorageFormatIdentifier,
                     "applicationFamilyIdentifier": applicationFamilyIdentifier,
                     "blockSize": blockSize,
                     "totalBlocks": totalBlocks,
                     "icReference": icReference,
                   ])
                 }
               }
             }
          }

          @available(iOS 13.0, *)
          private func handleIso7816SendCommand(_ arguments: [String : Any?], result: @escaping FlutterResult) {
              tagHandler(NFCISO7816Tag.self, arguments, result) { tag in
                let apdu = NFCISO7816APDU(
                  instructionClass: arguments["instructionClass"] as! UInt8,
                  instructionCode: arguments["instructionCode"] as! UInt8,
                  p1Parameter: arguments["p1Parameter"] as! UInt8,
                  p2Parameter: arguments["p2Parameter"] as! UInt8,
                  data: (arguments["data"] as! FlutterStandardTypedData).data,
                  expectedResponseLength: arguments["expectedResponseLength"] as! Int
                )
                tag.sendCommand(apdu: apdu) { payload, statusWord1, statusWord2, error in
                  if let error = error {
                    result(getFlutterError(error))
                  } else {
                    result([
                      "payload": payload,
                      "statusWord1": statusWord1,
                      "statusWord2": statusWord2,
                    ])
                  }
                }
              }
           }

           @available(iOS 13.0, *)
           private func handleIso7816SendCommandRaw(_ arguments: [String : Any?], result: @escaping FlutterResult) {
                tagHandler(NFCISO7816Tag.self, arguments, result) { tag in
                  guard let apdu = NFCISO7816APDU(data: (arguments["data"] as! FlutterStandardTypedData).data) else {
                    result(FlutterError(code: "invalid_parameter", message: nil, details: nil))
                    return
                  }
                  tag.sendCommand(apdu: apdu) { payload, statusWord1, statusWord2, error in
                    if let error = error {
                      result(getFlutterError(error))
                    } else {
                      result([
                        "payload": payload,
                        "statusWord1": statusWord1,
                        "statusWord2": statusWord2,
                      ])
                    }
                  }
                }
           }

         @available(iOS 13.0, *)
         private func handleMiFareSendMiFareCommand(_ arguments: [String : Any?], result: @escaping FlutterResult) {
            tagHandler(NFCMiFareTag.self, arguments, result) { tag in
              let commandPacket = (arguments["commandPacket"] as! FlutterStandardTypedData).data
              tag.sendMiFareCommand(commandPacket: commandPacket) { data, error in
                if let error = error {
                  result(getFlutterError(error))
                } else {
                  result(data)
                }
              }
            }
         }

         @available(iOS 13.0, *)
         private func handleMiFareSendMiFareCommand(_ arguments: [String : Any?], result: @escaping FlutterResult) {
            tagHandler(NFCMiFareTag.self, arguments, result) { tag in
              let commandPacket = (arguments["commandPacket"] as! FlutterStandardTypedData).data
              tag.sendMiFareCommand(commandPacket: commandPacket) { data, error in
                if let error = error {
                  result(getFlutterError(error))
                } else {
                  result(data)
                }
              }
            }
         }

         @available(iOS 13.0, *)
         private func handleMiFareSendMiFareIso7816Command(_ arguments: [String : Any?], result: @escaping FlutterResult) {
            tagHandler(NFCMiFareTag.self, arguments, result) { tag in
              let apdu = NFCISO7816APDU(
                instructionClass: arguments["instructionClass"] as! UInt8,
                instructionCode: arguments["instructionCode"] as! UInt8,
                p1Parameter: arguments["p1Parameter"] as! UInt8,
                p2Parameter: arguments["p2Parameter"] as! UInt8,
                data: (arguments["data"] as! FlutterStandardTypedData).data,
                expectedResponseLength: arguments["expectedResponseLength"] as! Int
              )
              tag.sendMiFareISO7816Command(apdu) { payload, statusWord1, statusWord2, error in
                if let error = error {
                  result(getFlutterError(error))
                } else {
                  result([
                    "payload": payload,
                    "statusWord1": statusWord1,
                    "statusWord2": statusWord2,
                  ])
                }
              }
            }
        }

        @available(iOS 13.0, *)
        private func handleMiFareSendMiFareIso7816CommandRaw(_ arguments: [String : Any?], result: @escaping FlutterResult) {
            tagHandler(NFCMiFareTag.self, arguments, result) { tag in
              guard let apdu = NFCISO7816APDU(data: (arguments["data"] as! FlutterStandardTypedData).data) else {
                result(FlutterError(code: "invalid_parameter", message: nil, details: nil))
                return
              }
              tag.sendMiFareISO7816Command(apdu) { payload, statusWord1, statusWord2, error in
                if let error = error {
                  result(getFlutterError(error))
                } else {
                  result([
                    "payload": payload,
                    "statusWord1": statusWord1,
                    "statusWord2": statusWord2,
                  ])
                }
              }
            }
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
    //获取nfc标签实例
    let handle = NSUUID().uuidString
    session.connect(to: tags.first!) { error in
      if let error = error {
//         // skip tag detection
        return
      }
      getNFCTagMapAsync(tags.first!) { tag, data, error in
        if let error = error {
//           // skip tag detection
          return
        }
        self.tags[handle] = tag
        //将键值添加到数据字典中 并保持当前值 {current,new in current} 替换当前值{current,new in new},存在相同key下
        self.channel.invokeMethod("onDiscovered", arguments: data.merging(["handle": handle]) { (current, _) in current })
      }
    }
  }
}
