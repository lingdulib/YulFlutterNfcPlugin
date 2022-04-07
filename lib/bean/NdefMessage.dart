
import 'dart:convert';
import 'dart:typed_data';

import 'NdefTypeNameFormat.dart';

///
class NdefMessage{
  /// Constructs an instance with given records.
  const NdefMessage(this.records);

  /// Records.
  final List<NdefRecord> records;

  /// The length in bytes of the NDEF message when stored on the tag.
  int get byteLength => records.isEmpty
      ? 0
      : records.map((e) => e.byteLength).reduce((a, b) => a + b);
}

class NdefRecord{
  static const URI_PREFIX_LIST = [
    '',
    'http://www.',
    'https://www.',
    'http://',
    'https://',
    'tel:',
    'mailto:',
    'ftp://anonymous:anonymous@',
    'ftp://ftp.',
    'ftps://',
    'sftp://',
    'smb://',
    'nfs://',
    'ftp://',
    'dav://',
    'news:',
    'telnet://',
    'imap:',
    'rtsp://',
    'urn:',
    'pop:',
    'sip:',
    'sips:',
    'tftp:',
    'btspp://',
    'btl2cap://',
    'btgoep://',
    'tcpobex://',
    'irdaobex://',
    'file://',
    'urn:epc:id:',
    'urn:epc:tag:',
    'urn:epc:pat:',
    'urn:epc:raw:',
    'urn:epc:',
    'urn:nfc:',
  ];
  /// Type Name Format.
  final NdefTypeNameFormat typeNameFormat;

  /// Type.
  final Uint8List type;

  /// Identifier.
  final Uint8List identifier;

  /// Payload.
  final Uint8List payload;

  /// The length in bytes of the NDEF record when stored on the tag.
  int get byteLength {
    var length = 3 + type.length + identifier.length + payload.length;
    // not short record
    if (payload.length > 255) length += 3;
    // id length
    if (typeNameFormat == NdefTypeNameFormat.empty || identifier.isNotEmpty) {
      length += 1;
    }

    return length;
  }

  const NdefRecord._({
    required this.typeNameFormat,
    required this.type,
    required this.identifier,
    required this.payload,
  });

  factory NdefRecord({
    required NdefTypeNameFormat typeNameFormat,
    required Uint8List type,
    required Uint8List identifier,
    required Uint8List payload,
  }) {
    _validateFormat(typeNameFormat, type, identifier, payload);
    return NdefRecord._(
      typeNameFormat: typeNameFormat,
      type: type,
      identifier: identifier,
      payload: payload,
    );
  }

  factory NdefRecord.createText(String text, {String languageCode = 'en'}) {
    final languageCodeBytes = ascii.encode(languageCode);
    if (languageCodeBytes.length >= 64) throw ('languageCode is too long');

    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.nfcWellknown,
      type: Uint8List.fromList([0x54]),
      identifier: Uint8List.fromList([]),
      payload: Uint8List.fromList(
        [languageCodeBytes.length] + languageCodeBytes + utf8.encode(text),
      ),
    );
  }

  factory NdefRecord.createUri(Uri uri) {
    final uriString = uri.normalizePath().toString();
    if (uriString.isEmpty) throw ('uri is empty');

    int prefixIndex =
    URI_PREFIX_LIST.indexWhere((e) => uriString.startsWith(e), 1);
    if (prefixIndex < 0) prefixIndex = 0;

    return NdefRecord(
        typeNameFormat: NdefTypeNameFormat.nfcWellknown,
        type: Uint8List.fromList([0x55]),
        identifier: Uint8List.fromList([]),
        payload: Uint8List.fromList(
          [prefixIndex] +
              utf8.encode(
                  uriString.substring(URI_PREFIX_LIST[prefixIndex].length)),
        ));
  }

  /// Constructs an instance containing media data as defined by RFC 2046.
  factory NdefRecord.createMime(String type, Uint8List data) {
    type = type.toLowerCase().trim().split(';').first;
    if (type.isEmpty) throw ('type is empty');

    final slashIndex = type.indexOf('/');
    if (slashIndex == 0) throw ('type must have mojor type');
    if (slashIndex == type.length - 1) throw ('type must have minor type');

    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.media,
      type: ascii.encode(type),
      identifier: Uint8List.fromList([]),
      payload: data,
    );
  }

  /// Constructs an instance containing external (application-specific) data.
  factory NdefRecord.createExternal(
      String domain, String type, Uint8List data) {
    domain = domain.trim().toLowerCase();
    type = type.trim().toLowerCase();
    if (domain.isEmpty) throw ('domain is empty');
    if (type.isEmpty) throw ('type is empty');

    return NdefRecord(
      typeNameFormat: NdefTypeNameFormat.nfcExternal,
      type: Uint8List.fromList(
          utf8.encode(domain) + ':'.codeUnits + utf8.encode(type)),
      identifier: Uint8List.fromList([]),
      payload: data,
    );
  }

  // _validateFormat
  static void _validateFormat(NdefTypeNameFormat format, Uint8List type,
      Uint8List identifier, Uint8List payload) {
    switch (format) {
      case NdefTypeNameFormat.empty:
        if (type.isNotEmpty || identifier.isNotEmpty || payload.isNotEmpty) {
          throw ('unexpected data in EMPTY record');
        }
        break;
      case NdefTypeNameFormat.nfcWellknown:
      case NdefTypeNameFormat.media:
      case NdefTypeNameFormat.absoluteUri:
      case NdefTypeNameFormat.nfcExternal:
        break;
      case NdefTypeNameFormat.unknown:
        if (type.isNotEmpty) throw ('unexpected type field in UNKNOWN record');
        break;
      case NdefTypeNameFormat.unchanged:
        throw ('unexpected UNCHANGED in first chunk or logical record');
      default:
        throw ('unexpected format: $format');
    }
  }
}