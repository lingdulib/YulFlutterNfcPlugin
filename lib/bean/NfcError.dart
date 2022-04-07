import 'NfcErrorType.dart';
/// nfc 错误信息 for ios
class NfcError{

  /// The error type.
  final NfcErrorType type;

  /// The error message.
  final String message;

  /// The error details information.
  final dynamic details;

  const NfcError({
    required this.type,
    required this.message,
    this.details,
  });
}