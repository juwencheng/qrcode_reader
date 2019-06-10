import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class QrcodeReader {
  static const MethodChannel _channel =
      const MethodChannel('flutter.baizi.io/qrcode_reader');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  // 扫描二维码
  static Future<void> scan(
      {@required Function(String) success,
      @required Function(String) failed}) async {
    Map<dynamic, dynamic> result = await _channel.invokeMapMethod("readQrCode");
    print(result);
    if (result["success"] == 1) {
      success(result["result"].toString());
    } else if (result["success"] == 0) {
      failed(result["result"].toString());
    }
  }
}
