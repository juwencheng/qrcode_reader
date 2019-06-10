import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

void main() {
  const MethodChannel channel = MethodChannel('qrcode_reader');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await QrcodeReader.platformVersion, '42');
  });
}
