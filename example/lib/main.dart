import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:yulnfc/bean/NdefMessage.dart';
import 'package:yulnfc/bean/NfcError.dart';
import 'package:yulnfc/bean/NfcTag.dart';
import 'package:yulnfc/protocols/mifare.dart';
import 'package:yulnfc/protocols/nfc_ndef.dart';
import 'package:yulnfc/yulnfc.dart' as yulnfc;
import 'dart:convert';
import 'package:flutter/services.dart';

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
                  yulnfc.startSessionForIos(onDiscovered: (NfcTag tag,MethodChannel channel) async {
                     setState(() {
                        nfcText=tag.data.toString();
                        yulnfc.stopSessionForIos();
                     });
                  },onError: (NfcError error) async {
                       print("nfcErrorMessage:${error.message}");
                       yulnfc.stopSessionForIos();
                  });
                }, child:const Text("建立ios nfc tag连接")),
                TextButton(onPressed: (){
                  yulnfc.startSessionForIos(onDiscovered: (NfcTag tag,MethodChannel channel) async {
                      var ndef=Ndef.from(tag, channel);
                      ndef?.read().then((ndefMessage){
                          print("信息读取成功.");
                      });
                  },onError: (NfcError error) async {
                    print("nfcErrorMessage:${error.message}");
                    yulnfc.stopSessionForIos();
                  });
                },child: const Text("读取ios nfc tag"),),
                TextButton(onPressed: (){
                   yulnfc.startSessionForIos(onDiscovered:(NfcTag tag,MethodChannel channel) async {
                     var ndef = Ndef.from(tag,channel);
                     if (ndef == null || !ndef.isWritable) {
                       print("nfc tag not write");
                       yulnfc.stopSessionForIos(errorMessage: "nfc tag 不能写入ndef数据.");
                       return;
                     }
                     NdefMessage message = NdefMessage([
                       NdefRecord.createText('Test a nfc Tag'),
                       NdefRecord.createUri(Uri.parse('http://127.0.0.1:9101')),
                       NdefRecord.createMime(
                           'text/plain', Uint8List.fromList('testText'.codeUnits)),
                       NdefRecord.createExternal(
                           'com.demo', 'text/plain', Uint8List.fromList('myNfcData'.codeUnits)),
                     ]);

                     try {
                       await ndef.write(message);
                       print("nfc tag 写入ndef数据成功.");
                       yulnfc.stopSessionForIos();
                     } catch (e) {
                       yulnfc.stopSessionForIos(errorMessage: e.toString());
                       return;
                     }
                   },onError: (NfcError error) async{
                      print("nfcErrorMessage:${error.message}");
                      yulnfc.stopSessionForIos();
                   });
                }, child: const Text("写入ios nfc tag ndef 数据")),
                TextButton(onPressed: (){
                    yulnfc.startSessionForIos(onDiscovered: (NfcTag tag,MethodChannel channel) async {
                      var mifare=MiFare.from(tag, channel);

                    },onError: (NfcError error) async{

                    });
                }, child: const Text("ios m1 卡")),
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
