import 'dart:async';

import 'package:flutter/services.dart';

/// 实现类

const MethodChannel _channel = MethodChannel('yulnfc');

///  设备是否支持nfc
Future<bool> get supportNfc async {
  final bool supportResult = await _channel.invokeMethod("nfcSupport");
  return supportResult;
}

/// 设备nfc是否启用
Future<bool> get enableNfc async {
  final bool enableNfcResult = await _channel.invokeMethod("nfcEnable");
  return enableNfcResult;
}

/// 打开nfc设置
Future<bool> get openNfcSetting async {
  final bool open = await _channel.invokeMethod("openNfcSetting");
  return open;
}

/// 读取扇区内容
Future<String?> startNfcSearch(int sectorIndx, int blockIndex,
    {String nfcPwd = "FFFFFFFFFFFF"}) async {
  final String readResult = await _channel.invokeMethod("readNfcCard", {
    "sectorIndex": sectorIndx,
    "blockIndex": blockIndex,
    "sectorPwd": nfcPwd
  });
  return readResult;
}

/// 写入扇区内容
Future<String?> startWriteNfcSearch(int sectorIndx, int blockIndex,
    {String nfcPwd = "FFFFFFFFFFFF", String? writeContent}) async {
  final String writeResult = await _channel.invokeMethod("writeNfcCard", {
    "sectorIndex": sectorIndx,
    "blockIndex": blockIndex,
    "sectorPwd": nfcPwd,
    "writeContent": writeContent
  });
  return writeResult;
}

/// 停止寻卡
Future stopNfcSearch() async {
  await _channel.invokeMethod("stopNfcCard");
}
