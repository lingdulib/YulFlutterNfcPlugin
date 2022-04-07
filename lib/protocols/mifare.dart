import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../bean/NfcTag.dart';
import './iso7816.dart';
import '../bean/MiFareFamily.dart';
import '../utils/IosTranslator.dart';

/// The class provides access to NFCMiFareTag API for iOS.
///
/// Acquire `MiFare` instance using `MiFare.from`.
class MiFare {
  /// Constructs an instance with the given values for testing.
  ///
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `MiFare.from` are valid.
  const MiFare(
      {required NfcTag tag,
      required this.mifareFamily,
      required this.identifier,
      required this.historicalBytes,
      required this.methodChannel})
      : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from NFCMiFareTag#mifareFamily on iOS.
  final MiFareFamily mifareFamily;

  /// The value from NFCMiFareTag#identifier on iOS.
  final Uint8List identifier;

  /// The value from NFCMiFareTag#historicalBytes on iOS.
  final Uint8List? historicalBytes;

  final MethodChannel methodChannel;

  /// Get an instance of `MiFare` for the given tag.
  ///
  /// Returns null if the tag is not compatible with MiFare.
  static MiFare? from(NfcTag tag, MethodChannel methodChannel) =>
      _getMiFare(tag, methodChannel);

  /// Sends the native MiFare command to the tag.
  ///
  /// This uses NFCMiFareTag#sendMiFareCommand API on iOS.
  Future<Uint8List> sendMiFareCommand(Uint8List commandPacket) async {
    return methodChannel.invokeMethod('sendMiFareCommand', {
      'handle': _tag.handle,
      'commandPacket': commandPacket,
    }).then((value) => value!);
  }

  /// Sends the ISO7816 APDU to the tag.
  ///
  /// This uses NFCMiFareTag#sendMiFareISO7816Command API on iOS.
  Future<Iso7816ResponseApdu> sendMiFareIso7816Command({
    required int instructionClass,
    required int instructionCode,
    required int p1Parameter,
    required int p2Parameter,
    required Uint8List data,
    required int expectedResponseLength,
  }) async {
    return methodChannel.invokeMethod('sendMiFareIso7816Command', {
      'handle': _tag.handle,
      'instructionClass': instructionClass,
      'instructionCode': instructionCode,
      'p1Parameter': p1Parameter,
      'p2Parameter': p2Parameter,
      'data': data,
      'expectedResponseLength': expectedResponseLength,
    }).then((value) => getIso7816ResponseApdu(Map.from(value)));
  }

  /// Sends the ISO7816 APDU to the tag.
  ///
  /// This uses NFCMiFareTag#sendMiFareISO7816Command API on iOS.
  Future<Iso7816ResponseApdu> sendMiFareIso7816CommandRaw(
      Uint8List data) async {
    return methodChannel.invokeMethod('sendMiFareIso7816CommandRaw', {
      'handle': _tag.handle,
      'data': data,
    }).then((value) => getIso7816ResponseApdu(Map.from(value)));
  }
}

MiFare? _getMiFare(NfcTag arg, MethodChannel methodChannel) {
  if (arg.data['mifare'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['mifare']);
  return MiFare(
      tag: arg,
      identifier: data['identifier'],
      mifareFamily: miFareFamilyTable.entries
          .firstWhere((e) => e.value == data['mifareFamily'])
          .key,
      historicalBytes: data['historicalBytes'],
      methodChannel: methodChannel);
}
