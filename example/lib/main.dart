import 'package:flutter/material.dart';
import 'package:yulnfc/bean/NfcError.dart';
import 'package:yulnfc/bean/NfcTag.dart';
import 'package:yulnfc/yulnfc.dart' as yulnfc;
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var nfcText = "";

  @override
  void initState() {
    super.initState();
    yulnfc.initHandlerForIos();
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Nfc m1卡读写插件'),
        ),
        body: Center(
          child: Column(
            children: [
              ...[
                const SizedBox(
                  height: 45.0,
                ),
                Text('Running on: $nfcText\n'),
                TextButton(
                    onPressed: () => yulnfc.openNfcSetting,
                    child: const Text("打开NFC设置")),
                TextButton(
                    onPressed: () {
                      yulnfc
                          .startWriteNfcSearch(0, 3, "1234567890")
                          .then((result) {
                        setState(() {
                          nfcText = result;
                        });
                      });
                    },
                    child: const Text("写卡")),
                TextButton(onPressed: (){
                  yulnfc.startSessionForIos(onDiscovered: (NfcTag tag) async {

                  },onError: (NfcError error) async {

                  });
                }, child:const Text("写值+10")),
                TextButton(onPressed: (){

                },child: const Text("减值-10"),)
              ]
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            yulnfc.startReadNfcSearch(0, 3).then((result) {
              setState(() {
                nfcText = result;
                print(nfcText);
                Map<String, dynamic> map = jsonDecode(nfcText);
                print("map1====>${map["uid"]}");
                print("map2====>${map["code"]}");
                print("map3====>${map["msg"]}");
                print("map4====>${map["content"]}");
              });
            });
          },
          child: const Icon(Icons.nfc),
        ),
      ),
    );
  }
}
