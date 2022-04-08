import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'bean/NfcError.dart';
import 'bean/NfcTag.dart';
import 'utils/IsoTranslator.dart';

/// 实现类
/// Signature for `startSession` onDiscovered callback.
typedef NfcTagCallback = Future<void> Function(NfcTag tag,MethodChannel methodChannel);

/// Signature for `startSession` onError callback.
typedef NfcErrorCallback = Future<void> Function(NfcError error);

// _onDiscovered
NfcTagCallback? _onDiscovered;

// _onError
NfcErrorCallback? _onError;

const MethodChannel _channel = MethodChannel('yulnfc');

///  设备是否支持nfc 通用方法
Future<bool> get supportNfc async {
  final bool supportResult = await _channel.invokeMethod("nfcSupport");
  return supportResult;
}

/// 设备nfc是否启用 Android only
Future<bool> get enableNfc async {
  final bool enableNfcResult = await _channel.invokeMethod("nfcEnable");
  return enableNfcResult;
}

/// 打开nfc设置 Android only
Future<bool> get openNfcSetting async {
  final bool open = await _channel.invokeMethod("openNfcSetting");
  return open;
}

/// 读取扇区内容 Android only
Future<String> startReadNfcSearch(int sectorIndx, int blockIndex,
    {String nfcPwd = "FFFFFFFFFFFF"}) async {
  final String readResult = await _channel.invokeMethod("readNfcCard", {
    "sectorIndex": sectorIndx,
    "blockIndex": blockIndex,
    "sectorPwd": nfcPwd
  });
  return readResult;
}

/// 写入扇区内容 Android only
Future<String> startWriteNfcSearch(
    int sectorIndx, int blockIndex, String writeContent,
    {String nfcPwd = "FFFFFFFFFFFF"}) async {
  final String writeResult = await _channel.invokeMethod("writeNfcCard", {
    "sectorIndex": sectorIndx,
    "blockIndex": blockIndex,
    "sectorPwd": nfcPwd,
    "writeContent": writeContent
  });
  return writeResult;
}

/// 停止寻卡 Android Only
Future stopNfcSearch() async {
  await _channel.invokeMethod("stopNfcCard");
}

/// ios适配
/// 初始化回调接收
Future<void> initHandlerForIos() async{
  if(Platform.isIOS){
    _channel.setMethodCallHandler(_handleMethodCall);
  }
}

Future<void> _handleMethodCall(MethodCall call) async {
  switch (call.method) {
    case 'onDiscovered':
      _handleOnDiscovered(call);
      break;
    case 'onError':
      _handleOnError(call);
      break;
    default:
      throw ('Not implemented: ${call.method}');
  }
}

_handleOnDiscovered(MethodCall methodCall) async {
  final tag = getNfcTag(Map.from(methodCall.arguments));
  await _onDiscovered?.call(tag,_channel);
  await _disposeTagForIos(tag.handle);
}

_handleOnError(MethodCall methodCall) async {
  final error = getNfcError(Map.from(methodCall.arguments));
  await _onError?.call(error);
}

/// 发现nfc设备
Future<void> startSessionForIos({
  required NfcTagCallback onDiscovered,
  NfcErrorCallback? onError,
}) async {
  if(Platform.isIOS){
    _onDiscovered = onDiscovered;
    _onError = onError;
    return _channel.invokeMethod('startSession');
  }
}

///停止发现
Future<void> stopSessionForIos({
  String? alertMessage,
  String? errorMessage,
}) async {
  if(Platform.isIOS){
    _onDiscovered = null;
    _onError = null;
    return _channel.invokeMethod('stopSession', {
      'alertMessage': alertMessage,
      'errorMessage': errorMessage,
    });
  }
}

// _disposeTag
Future<void> _disposeTagForIos(String handle) async => _channel.invokeMethod('disposeTag', {
  'handle': handle,
});

