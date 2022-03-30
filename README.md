# yulnfc

一个flutter MifareClassic卡读写插件,仅支持Android系统.

> Flutter 使用

1. 导入插件

  ```dart
  import 'package:yulnfc/yulnfc.dart' as yulnfc;
  ```

2. 检测设备是否支持NFC

```dart
 yulnfc.supportNfc.then((support) {
if (support) {
print("设备支持nfc");
} else {
print("设备不支持nfc");
}
});
```

3. 检测设备NFC是否可用

```dart
  yulnfc.enableNfc.then((enable) {
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
yulnfc.startReadNfcSearch(0, 0);
```

6. 寻卡并写卡

```dart
yulnfc.startWriteNfcSearch(0, 0);
```

7. 停止寻卡

```dart
yulnfc.stopNfcSearch();
```



### Android 端配置

> Android 权限配置

在AndroidManifest.xml添加

```xml
<uses-permission android:name="android.permission.NFC"/>
```

