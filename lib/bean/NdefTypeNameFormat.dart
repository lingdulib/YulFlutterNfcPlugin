
/// ndef 类型名称格式
enum NdefTypeNameFormat{
  /// The record contains no data.
  empty,
  /// The record contains well-known NFC record type data.
  nfcWellknown,

  /// The record contains media data as defined by RFC 2046.
  media,

  /// The record contains uniform resource identifier.
  absoluteUri,

  /// The record contains NFC external type data.
  nfcExternal,

  /// The record type is unknown.
  unknown,

  /// The record is part of a series of records containing chunked data.
  unchanged,
}