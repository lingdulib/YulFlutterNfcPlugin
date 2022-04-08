# yulnfc

一个flutter MifareClassic卡读写插件,仅支持Android系统.

> Flutter 使用

1. 导入插件

  ```yaml
yulnfc:
  git: https://github.com/lingdulib/YulFlutterNfcPlugin.git
```

  ```dart
  import 'package:yulnfc/yulnfc.dart' as yulnfc;
  ```

2. 检测设备是否支持NFC

```dart
 yulnfc.supportNfc.then((
support) {
if (support) {
print("设备支持nfc");
} else {
print("设备不支持nfc");
}
});
```

3. 检测设备NFC是否可用

```dart
  yulnfc.enableNfc.then((
enable) {
if (enable) {
print("设备nfc可用");
} else {
print("设备nfc不可用");
}
});
```

4. 打开NFC设置

```dart
yulnfc.openNfcSetting;
```

5. 寻卡并读卡

```dart
/// 参数1扇区 参数2区块 参数3 区块密码
yulnfc.startReadNfcSearch(0
,
0
);
```

6. 寻卡并写卡

```dart
yulnfc.startWriteNfcSearch(0
,
0
);
```

7. 停止寻卡

```dart
yulnfc.stopNfcSearch();
```

### Android 端配置

> Android 权限配置

在AndroidManifest.xml添加

```xml

<uses-permission android:name="android.permission.NFC" />
```

> ios 配置

- 概述（ios 使用nfc必须的配置）

```tex
Use NFCTagReaderSession to interact with one of the tag types listed in NFCTagType. To use this reader session, you must:

Include the Near Field Communication Tag Reader Session Formats Entitlement in your app.

Provide a non-empty string for the NFCReaderUsageDescription key in your app’s info.plist file.

To interact with ISO 7816 tags, add the list of the application identifiers supported in your app to the com.apple.developer.nfc.readersession.iso7816.select-identifiers information property list key. If you include the application identifier D2760000850101—the identifier for the NDEF application on MIFARE DESFire tags (NFC Forum T4T tag platform)—and the reader session finds a tag matching this identifier, it sends the delegate an NFCISO7816Tag tag object. To get the MIFARE DESFire tag as an NFCMiFareTag object, don't include D2760000850101 in the application identifier list.

Only one reader session of any type can be active in the system at a time. The system puts additional sessions in a queue and processes them in first-in, first-out (FIFO) order.

```

来自:https://developer.apple.com/documentation/corenfc/nfctagreadersession/



> flutter中ios使用



1. 开始寻卡并获取Nfc Tag

```dart
 yulnfc.startSessionForIos(onDiscovered: (NfcTag tag,MethodChannel channel) async {
                     setState(() {
                        nfcText=tag.data.toString();
                        yulnfc.stopSessionForIos();
                     });
                  },onError: (NfcError error) async {
                       print("nfcErrorMessage:${error.message}");
                       yulnfc.stopSessionForIos();
                  });
```

2. 停止寻卡

```dart
 yulnfc.stopSessionForIos();
```

3. 读取Nfc卡 ndef标签

```dart
yulnfc.startSessionForIos(onDiscovered: (NfcTag tag,MethodChannel channel) async {
                      var ndef=Ndef.from(tag, channel);
                      ndef?.read().then((ndefMessage){
                          print("信息读取成功.");
                      });
                  },onError: (NfcError error) async {
                    print("nfcErrorMessage:${error.message}");
                    yulnfc.stopSessionForIos();
                  });
```

4. 写入Nfc卡 ndef标签

```dart
    yulnfc.startSessionForIos(onDiscovered:(NfcTag tag,MethodChannel channel) async {
                     var ndef = Ndef.from(tag,channel);
                     if (ndef == null || !ndef.isWritable) {
                       print("nfc tag not write");
                       yulnfc.stopSessionForIos(errorMessage: "nfc tag 不能写入ndef数据.");
                       return;
                     }
                     NdefMessage message = NdefMessage([
                       NdefRecord.createText('Test a nfc Tag'),
                       NdefRecord.createUri(Uri.parse('http://127.0.0.1:9101')),
                       NdefRecord.createMime(
                           'text/plain', Uint8List.fromList('testText'.codeUnits)),
                       NdefRecord.createExternal(
                           'com.demo', 'text/plain', Uint8List.fromList('myNfcData'.codeUnits)),
                     ]);

                     try {
                       await ndef.write(message);
                       print("nfc tag 写入ndef数据成功.");
                       yulnfc.stopSessionForIos();
                     } catch (e) {
                       yulnfc.stopSessionForIos(errorMessage: e.toString());
                       return;
                     }
                   },onError: (NfcError error) async{
                      print("nfcErrorMessage:${error.message}");
                      yulnfc.stopSessionForIos();
                   });
```

注意:ios flutter插件参考自其他开源项目

