
import '../bean/Iso15693RequestFlag.dart';
import '../bean/MiFareFamily.dart';
import '../bean/NdefMessage.dart';
import '../bean/NdefTypeNameFormat.dart';
import '../bean/NfcError.dart';
import '../bean/NfcErrorType.dart';
import '../bean/NfcTag.dart';
import '../protocols/iso15693.dart';
import '../protocols/iso7816.dart';
import '../protocols/mifare.dart';

const Map<NfcErrorType, String> nfcErrorTypeTable = {
  NfcErrorType.sessionTimeout: 'sessionTimeout',
  NfcErrorType.systemIsBusy: 'systemIsBusy',
  NfcErrorType.userCanceled: 'userCanceled',
  NfcErrorType.unknown: 'unknown',
};

Iso7816ResponseApdu getIso7816ResponseApdu(Map<String, dynamic> arg) {
  return Iso7816ResponseApdu(
    payload: arg['payload'],
    statusWord1: arg['statusWord1'],
    statusWord2: arg['statusWord2'],
  );
}

const Map<Iso15693RequestFlag, String> iso15693RequestFlagTable = {
  Iso15693RequestFlag.address: 'address',
  Iso15693RequestFlag.dualSubCarriers: 'dualSubCarriers',
  Iso15693RequestFlag.highDataRate: 'highDataRate',
  Iso15693RequestFlag.option: 'option',
  Iso15693RequestFlag.protocolExtension: 'protocolExtension',
  Iso15693RequestFlag.select: 'select',
};

const Map<NdefTypeNameFormat, int> ndefTypeNameFormatTable = {
  NdefTypeNameFormat.empty: 0x00,
  NdefTypeNameFormat.nfcWellknown: 0x01,
  NdefTypeNameFormat.media: 0x02,
  NdefTypeNameFormat.absoluteUri: 0x03,
  NdefTypeNameFormat.nfcExternal: 0x04,
  NdefTypeNameFormat.unknown: 0x05,
  NdefTypeNameFormat.unchanged: 0x06,
};

Iso15693SystemInfo getIso15693SystemInfo(Map<String, dynamic> arg) {
  return Iso15693SystemInfo(
    dataStorageFormatIdentifier: arg['dataStorageFormatIdentifier'],
    applicationFamilyIdentifier: arg['applicationFamilyIdentifier'],
    blockSize: arg['blockSize'],
    totalBlocks: arg['totalBlocks'],
    icReference: arg['icReference'],
  );
}

const Map<MiFareFamily, int> miFareFamilyTable = {
  MiFareFamily.unknown: 1,
  MiFareFamily.ultralight: 2,
  MiFareFamily.plus: 3,
  MiFareFamily.desfire: 4,
};

NfcTag getNfcTag(Map<String, dynamic> arg) {
  return NfcTag(
    handle: arg.remove('handle'),
    data: arg,
  );
}

NfcError getNfcError(Map<String, dynamic> arg) {
  return NfcError(
    type: nfcErrorTypeTable.values.contains(arg['type'])
        ? nfcErrorTypeTable.entries
        .firstWhere((e) => e.value == arg['type'])
        .key
        : NfcErrorType.unknown,
    message: arg['message'],
    details: arg['details'],
  );
}

Map<String, dynamic> getNdefMessageMap(NdefMessage arg) {
  return {
    'records': arg.records
        .map((e) => {
      'typeNameFormat': ndefTypeNameFormatTable[e.typeNameFormat],
      'type': e.type,
      'identifier': e.identifier,
      'payload': e.payload,
    })
        .toList()
  };
}


NdefMessage getNdefMessage(Map<String, dynamic> arg) {
  return NdefMessage((arg['records'] as Iterable)
      .map((e) => NdefRecord(
    typeNameFormat: ndefTypeNameFormatTable.entries
        .firstWhere((ee) => ee.value == e['typeNameFormat'])
        .key,
    type: e['type'],
    identifier: e['identifier'],
    payload: e['payload'],
  ))
      .toList());
}