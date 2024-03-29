import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String text = "";
  String error = "";
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await QrcodeReader.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                child: Text("扫描结果: $text"),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Text("扫描错误: $error"),
              ),
              FlatButton(
                onPressed: () {
                  QrcodeReader.scan(success: (result) {
                    setState(() {
                      text = result;
                      error = "";
                    });
                  }, failed: (message) {
                    setState(() {
                      error = message;
                      text = "";
                    });
                  });
                },
                child: Text("扫描二维码"),
              )
            ],
          )),
    );
  }
}
