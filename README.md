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

```text
Use NFCTagReaderSession to interact with one of the tag types listed in NFCTagType. To use this reader session, you must:

Include the Near Field Communication Tag Reader Session Formats Entitlement in your app.

Provide a non-empty string for the NFCReaderUsageDescription key in your app’s info.plist file.

To interact with ISO 7816 tags, add the list of the application identifiers supported in your app to the com.apple.developer.nfc.readersession.iso7816.select-identifiers information property list key. If you include the application identifier D2760000850101—the identifier for the NDEF application on MIFARE DESFire tags (NFC Forum T4T tag platform)—and the reader session finds a tag matching this identifier, it sends the delegate an NFCISO7816Tag tag object. To get the MIFARE DESFire tag as an NFCMiFareTag object, don't include D2760000850101 in the application identifier list.

Only one reader session of any type can be active in the system at a time. The system puts additional sessions in a queue and processes them in first-in, first-out (FIFO) order.
```

来自：https://developer.apple.com/documentation/corenfc/nfctagreadersession/

