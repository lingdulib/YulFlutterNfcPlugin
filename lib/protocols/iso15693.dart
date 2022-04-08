import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../bean/Iso15693RequestFlag.dart';
import '../bean/NfcTag.dart';
import '../utils/IsoTranslator.dart';


/// The class provides access to NFCISO15693Tag API for iOS.
///
/// Acquire `Iso15693` instance using `Iso15693.from`.
class Iso15693 {
  /// Constructs an instance with the given values for testing.
  ///
  /// The instances constructs by this way are not valid in the production environment.
  /// Only instances obtained from the `Iso15693.from` are valid.
  const Iso15693({
    required NfcTag tag,
    required this.identifier,
    required this.icManufacturerCode,
    required this.icSerialNumber,
    required this.methodChannel
  }) : _tag = tag;

  // _tag
  final NfcTag _tag;

  /// The value from identifier on iOS.
  final Uint8List identifier;

  /// The value from icManufacturerCode on iOS.
  final int icManufacturerCode;

  /// The value from icSerialNumber on iOS.
  final Uint8List icSerialNumber;

  final MethodChannel methodChannel;
  /// Get an instance of `Iso15693` for the given tag.
  ///
  /// Returns null if the tag is not compatible with Iso15693.
  static Iso15693? from(NfcTag tag,MethodChannel methodChannel) => _getIso15693(tag,methodChannel);

  /// Sends the Read Single Block command to the tag.
  ///
  /// This uses readSingleBlock API on iOS.
  Future<Uint8List> readSingleBlock({
    required Set<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
  }) async {
    return methodChannel.invokeMethod('readSingleBlock', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber.toUnsigned(8),
    }).then((value) => value!);
  }

  /// Sends the Write Single Block command to the tag.
  ///
  /// This uses writeSingleBlock API on iOS.
  Future<void> writeSingleBlock({
    required Set<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
    required Uint8List dataBlock,
  }) async {
    return methodChannel.invokeMethod('writeSingleBlock', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber.toUnsigned(8),
      'dataBlock': dataBlock,
    });
  }

  /// Sends the Read Multiple Blocks command to the tag.
  ///
  /// This uses readMultipleBlocks API on iOS.
  Future<List<Uint8List>> readMultipleBlocks({
    required Set<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
  }) async {
    return methodChannel.invokeMethod('readMultipleBlocks', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
      'numberOfBlocks': numberOfBlocks,
    }).then((value) => List.from(value!));
  }

  /// Sends the Write Multiple Blocks command to the tag.
  ///
  /// This uses writeMultipleBlocks API on iOS.
  Future<void> writeMultipleBlocks({
    required Set<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
    required List<Uint8List> dataBlocks,
  }) async {
    return methodChannel.invokeMethod('writeMultipleBlocks', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
      'numberOfBlocks': numberOfBlocks,
      'dataBlocks': dataBlocks,
    });
  }

  /// Sends the Select command to the tag.
  ///
  /// This uses select API on iOS.
  Future<void> select({
    required Set<Iso15693RequestFlag> requestFlags,
  }) async {
    return methodChannel.invokeMethod('select', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
    });
  }

  /// Sends the Stay Quiet command to the tag.
  ///
  /// This uses stayQuiet API on iOS.
  Future<void> stayQuiet() async {
    return methodChannel.invokeMethod('stayQuiet', {
      'handle': _tag.handle,
    });
  }

  /// Sends the Get System Info command to the tag.
  ///
  /// This uses getSystemInfo API on iOS.
  Future<Iso15693SystemInfo> getSystemInfo({
    required Set<Iso15693RequestFlag> requestFlags,
  }) async {
    return methodChannel.invokeMethod('getSystemInfo', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
    }).then((value) => getIso15693SystemInfo(Map.from(value!)));
  }
}

/// The class represents the response of the Get System Info command.
class Iso15693SystemInfo {
  /// Constructs an instance with the given values.
  const Iso15693SystemInfo({
    required this.applicationFamilyIdentifier,
    required this.blockSize,
    required this.dataStorageFormatIdentifier,
    required this.icReference,
    required this.totalBlocks,
  });

  /// Application Family Identifier.
  final int applicationFamilyIdentifier;

  /// Block Size.
  final int blockSize;

  /// Data Storage Format Identifier.
  final int dataStorageFormatIdentifier;

  // IC Reference.
  final int icReference;

  /// Total Blocks.
  final int totalBlocks;
}

Iso15693? _getIso15693(NfcTag arg,MethodChannel methodChannel) {
  if (arg.data['iso15693'] == null) return null;
  final data = Map<String, dynamic>.from(arg.data['iso15693']);
  return Iso15693(
    tag: arg,
    identifier: data['identifier'],
    icManufacturerCode: data['icManufacturerCode'],
    icSerialNumber: data['icSerialNumber'],
    methodChannel: methodChannel
  );
}
