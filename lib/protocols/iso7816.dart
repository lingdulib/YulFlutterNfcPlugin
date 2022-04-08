import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../bean/NfcTag.dart';
import '../utils/IsoTranslator.dart';

/// The class provides access to NFCISO7816Tag API for iOS.
///
/// Acquire `Iso7816` instance using `Iso7816.from`.
class Iso7816 {
  /// Constructs an instance with the given values for testing.
  ///
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `Iso7816.from` are valid.
  const Iso7816({
    required NfcTag tag,
    required this.identifier,
    required this.initialSelectedAID,
    required this.historicalBytes,
    required this.applicationData,
    required this.proprietaryApplicationDataCoding,
    required this.methodChannel
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from identifier on iOS.
  final Uint8List identifier;

  /// The value from initialSelectedAID on iOS.
  final String initialSelectedAID;

  /// The value from historicalBytes on iOS.
  final Uint8List? historicalBytes;

  /// The value from applicationData on iOS.
  final Uint8List? applicationData;

  /// The value from proprietaryApplicationDataCoding on iOS.
  final bool proprietaryApplicationDataCoding;

  final MethodChannel methodChannel;

  /// Get an instance of `Iso7816` for the given tag.
  ///
  /// Returns null if the tag is not compatible with Iso7816.
  static Iso7816? from(NfcTag tag,MethodChannel methodChannel) => _getIso7816(tag,methodChannel);

  /// Sends the APDU to the tag.
  ///
  /// This uses sendCommand API on iOS.
  Future<Iso7816ResponseApdu> sendCommand({
    required int instructionClass,
    required int instructionCode,
    required int p1Parameter,
    required int p2Parameter,
    required Uint8List data,
    required int expectedResponseLength,
  }) async {
    return methodChannel.invokeMethod('sendCommand', {
      'handle': _tag.handle,
      'instructionClass': instructionClass,
      'instructionCode': instructionCode,
      'p1Parameter': p1Parameter,
      'p2Parameter': p2Parameter,
      'data': data,
      'expectedResponseLength': expectedResponseLength,
    }).then((value) => getIso7816ResponseApdu(Map.from(value)));
  }

  /// Sends the APDU to the tag.
  ///
  /// This uses sendCommand API on iOS.
  Future<Iso7816ResponseApdu> sendCommandRaw(Uint8List data) async {
    return methodChannel.invokeMethod('sendCommandRaw', {
      'handle': _tag.handle,
      'data': data,
    }).then((value) => getIso7816ResponseApdu(Map.from(value)));
  }
}

/// The class represents the response APDU.
class Iso7816ResponseApdu {
  /// Constructs an instance with the given values.
  const Iso7816ResponseApdu({
    required this.payload,
    required this.statusWord1,
    required this.statusWord2,
  });

  /// Payload.
  final Uint8List payload;

  /// Status Word1.
  final int statusWord1;

  /// Status Word2.
  final int statusWord2;
}


Iso7816? _getIso7816(NfcTag arg,MethodChannel methodChannel) {
  if (arg.data['iso7816'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['iso7816']);
  return Iso7816(
      tag: arg,
      identifier: data['identifier'],
      historicalBytes: data['historicalBytes'],
      applicationData: data['applicationData'],
      initialSelectedAID: data['initialSelectedAID'],
      proprietaryApplicationDataCoding: data['proprietaryApplicationDataCoding'],
      methodChannel: methodChannel
  );
}
