import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:yulnfc/yulnfc.dart' as YulNfc;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    YulNfc.supportNfc.then((support) {
      if (support) {
        print("设备支持nfc");
      } else {
        print("设备不支持nfc");
      }
    });
    YulNfc.enableNfc.then((enable) {
      if (enable) {
        print("设备nfc可用");
      } else {
        print("设备nfc不可用");
      }
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = 'Unknown platform version';
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
    var nfcText="";
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $nfcText\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            YulNfc.startNfcSearch(0, 0).then((result){
               setState(() {
                  nfcText=result??"读取失败.";
               });
            });
          },
        ),
      ),
    );
  }
}
