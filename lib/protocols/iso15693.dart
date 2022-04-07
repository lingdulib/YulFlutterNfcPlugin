import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../bean/Iso15693RequestFlag.dart';
import '../bean/NfcTag.dart';
import '../utils/IosTranslator.dart';


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

  /// The value from NFCISO15693Tag#identifier on iOS.
  final Uint8List identifier;

  /// The value from NFCISO15693Tag#icManufacturerCode on iOS.
  final int icManufacturerCode;

  /// The value from NFCISO15693Tag#icSerialNumber on iOS.
  final Uint8List icSerialNumber;

  final MethodChannel methodChannel;
  /// Get an instance of `Iso15693` for the given tag.
  ///
  /// Returns null if the tag is not compatible with Iso15693.
  static Iso15693? from(NfcTag tag,MethodChannel methodChannel) => _getIso15693(tag,methodChannel);

  /// Sends the Read Single Block command to the tag.
  ///
  /// This uses NFCISO15693Tag#readSingleBlock API on iOS.
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
  /// This uses NFCISO15693Tag#writeSingleBlock API on iOS.
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

  /// Sends the Lock Block command to the tag.
  ///
  /// This uses NFCISO15693Tag#lockBlock API on iOS.
  Future<void> lockBlock({
    required Set<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
  }) async {
    return methodChannel.invokeMethod('lockBlock', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber.toUnsigned(8),
    });
  }

  /// Sends the Read Multiple Blocks command to the tag.
  ///
  /// This uses NFCISO15693Tag#readMultipleBlocks API on iOS.
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
  /// This uses NFCISO15693Tag#writeMultipleBlocks API on iOS.
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

  /// Sends the Get Multiple Block Security Status command to the tag.
  ///
  /// This uses NFCISO15693Tag#getMultipleBlockSecurityStatus API on iOS.
  Future<List<int>> getMultipleBlockSecurityStatus({
    required Set<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
  }) async {
    return methodChannel.invokeMethod('getMultipleBlockSecurityStatus', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
      'numberOfBlocks': numberOfBlocks,
    }).then((value) => List.from(value!));
  }

  /// Sends the Write AFI command to the tag.
  ///
  /// This uses NFCISO15693Tag#writeAFI API on iOS.
  Future<void> writeAfi({
    required Set<Iso15693RequestFlag> requestFlags,
    required int afi,
  }) async {
    return methodChannel.invokeMethod('writeAfi', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'afi': afi.toUnsigned(8),
    });
  }

  /// Sends the Lock AFI command to the tag.
  ///
  /// This uses NFCISO15693Tag#lockAFI API on iOS.
  Future<void> lockAfi({
    required Set<Iso15693RequestFlag> requestFlags,
  }) async {
    return methodChannel.invokeMethod('lockAfi', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
    });
  }

  /// Sends the Write DSFID command to the tag.
  ///
  /// This uses NFCISO15693Tag#writeDSFID API on iOS.
  Future<void> writeDsfId({
    required Set<Iso15693RequestFlag> requestFlags,
    required int dsfId,
  }) async {
    return methodChannel.invokeMethod('writeDsfId', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'dsfId': dsfId.toUnsigned(8),
    });
  }

  /// Sends the Lock DSFID command to the tag.
  ///
  /// This uses NFCISO15693Tag#lockDSFID API on iOS.
  Future<void> lockDsfId({
    required Set<Iso15693RequestFlag> requestFlags,
  }) async {
    return methodChannel.invokeMethod('lockDsfId', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
    });
  }

  /// Sends the Reset To Ready command to the tag.
  ///
  /// This uses NFCISO15693Tag#resetToReady API on iOS.
  Future<void> resetToReady({
    required Set<Iso15693RequestFlag> requestFlags,
  }) async {
    return methodChannel.invokeMethod('resetToReady', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
    });
  }

  /// Sends the Select command to the tag.
  ///
  /// This uses NFCISO15693Tag#select API on iOS.
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
  /// This uses NFCISO15693Tag#stayQuiet API on iOS.
  Future<void> stayQuiet() async {
    return methodChannel.invokeMethod('stayQuiet', {
      'handle': _tag.handle,
    });
  }

  /// Sends the Extended Read Single Block command to the tag.
  ///
  /// This uses NFCISO15693Tag#extendedReadSingleBlock API on iOS.
  Future<Uint8List> extendedReadSingleBlock({
    required Set<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
  }) async {
    return methodChannel.invokeMethod('extendedReadSingleBlock', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
    }).then((value) => value!);
  }

  /// Sends the Extended Write Single Block command to the tag.
  ///
  /// This uses NFCISO15693Tag#extendedWriteSingleBlock API on iOS.
  Future<void> extendedWriteSingleBlock({
    required Set<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
    required Uint8List dataBlock,
  }) async {
    return methodChannel.invokeMethod('extendedWriteSingleBlock', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
      'dataBlock': dataBlock,
    });
  }

  /// Sends the Extended Lock Block command to the tag.
  ///
  /// This uses NFCISO15693Tag#extendedLockBlock API on iOS.
  Future<void> extendedLockBlock({
    required Set<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
  }) async {
    return methodChannel.invokeMethod('extendedLockBlock', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
    });
  }

  /// Sends the Extended Read Multiple Blocks command to the tag.
  ///
  /// This uses NFCISO15693Tag#extendedReadMultipleBlocks API on iOS.
  Future<List<Uint8List>> extendedReadMultipleBlocks({
    required Set<Iso15693RequestFlag> requestFlags,
    required int blockNumber,
    required int numberOfBlocks,
  }) async {
    return methodChannel.invokeMethod('extendedReadMultipleBlocks', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'blockNumber': blockNumber,
      'numberOfBlocks': numberOfBlocks,
    }).then((value) => List.from(value!));
  }

  /// Sends the Get System Info command to the tag.
  ///
  /// This uses NFCISO15693Tag#getSystemInfo API on iOS.
  Future<Iso15693SystemInfo> getSystemInfo({
    required Set<Iso15693RequestFlag> requestFlags,
  }) async {
    return methodChannel.invokeMethod('getSystemInfo', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
    }).then((value) => getIso15693SystemInfo(Map.from(value!)));
  }

  /// Sends the custom command to the tag.
  ///
  /// This uses NFCISO15693Tag#customCommand API on iOS.
  Future<Uint8List> customCommand({
    required Set<Iso15693RequestFlag> requestFlags,
    required int customCommandCode,
    required Uint8List customRequestParameters,
  }) async {
    return methodChannel.invokeMethod('customCommand', {
      'handle': _tag.handle,
      'requestFlags':
          requestFlags.map((e) => iso15693RequestFlagTable[e]).toList(),
      'customCommandCode': customCommandCode,
      'customRequestParameters': customRequestParameters,
    }).then((value) => value!);
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
