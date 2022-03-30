import 'package:flutter/material.dart';
import 'package:yulnfc/yulnfc.dart' as yulnfc;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    yulnfc.supportNfc.then((support) {
      if (support) {
        print("设备支持nfc");
      } else {
        print("设备不支持nfc");
      }
    });
    yulnfc.enableNfc.then((enable) {
      if (enable) {
        print("设备nfc可用");
      } else {
        print("设备nfc不可用");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var nfcText="";
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Nfc m1卡读写插件'),
        ),
        body: Center(
          child: Text('Running on: $nfcText\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            yulnfc.startNfcSearch(0, 0).then((result){
               setState(() {
                  nfcText=result??"读取失败.";
               });
            });
          },
          child:const Icon(Icons.nfc),
        ),
      ),
    );
  }
}
