
import 'dart:async';

import 'package:flutter/services.dart';

class Yulnfc {
  static const MethodChannel _channel = MethodChannel('yulnfc');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
