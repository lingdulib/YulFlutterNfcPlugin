/// nfc 错误信息 for ios
enum NfcErrorType{
  /// The session timed out.
  sessionTimeout,

  /// The session failed because the system is busy.
  systemIsBusy,

  /// The user canceled the session.
  userCanceled,

  /// The session failed because the unexpected error has occurred.
  unknown,
}