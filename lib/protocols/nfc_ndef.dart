import 'package:flutter/services.dart';

import '../bean/NdefMessage.dart';
import '../bean/NfcTag.dart';
import '../utils/IosTranslator.dart';

/// The class provides access to NDEF operations on the tag.
///
/// Acquire `Ndef` instance using `Ndef.from`.
class Ndef {
  /// Constructs an instance with the given values for testing.
  ///
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `Ndef.from` are valid.
  const Ndef(
      {required NfcTag tag,
      required this.isWritable,
      required this.maxSize,
      required this.cachedMessage,
      required this.additionalData,
      required this.methodChannel})
      : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from Ndef#isWritable on Android, NFCNDEFTag#queryStatus on iOS.
  final bool isWritable;

  /// The value from Ndef#maxSize on Android, NFCNDEFTag#queryStatus on iOS.
  final int maxSize;

  /// The value from Ndef#cachedNdefMessage on Android, NFCNDEFTag#read on iOS.
  ///
  /// This value is cached at tag discovery.
  final NdefMessage? cachedMessage;

  /// The value represents some additional data.
  final Map<String, dynamic> additionalData;

  final MethodChannel methodChannel;

  /// Get an instance of `Ndef` for the given tag.
  ///
  /// Returns null if the tag is not compatible with NDEF.
  static Ndef? from(NfcTag tag, MethodChannel methodChannel) =>
      _getNdef(tag, methodChannel);

  /// Read the current NDEF message on this tag.
  Future<NdefMessage> read() async {
    return methodChannel.invokeMethod('read', {
      'handle': _tag.handle,
    }).then((value) => getNdefMessage(Map.from(value)));
  }

  /// Write the NDEF message on this tag.
  Future<void> write(NdefMessage message) async {
    return methodChannel.invokeMethod('write', {
      'handle': _tag.handle,
      'message': getNdefMessageMap(message),
    });
  }

  /// Change the NDEF status to read-only.
  ///
  /// This is a permanent action that you cannot undo. After locking the tag, you can no longer write data to it.
  Future<void> writeLock() async {
    return methodChannel.invokeMethod('writeLock', {
      'handle': _tag.handle,
    });
  }
}

Ndef? _getNdef(NfcTag arg, MethodChannel methodChannel) {
  if (arg.data['ndef'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['ndef']);
  return Ndef(
      tag: arg,
      isWritable: data.remove('isWritable'),
      maxSize: data.remove('maxSize'),
      cachedMessage: data['cachedMessage'] == null
          ? null
          : getNdefMessage(
              Map<String, dynamic>.from(data.remove('cachedMessage'))),
      additionalData: data,
      methodChannel: methodChannel);
}
