import 'usfm_bundle_support.dart';

const bool supportsNativeUsfmParsing = false;
const String nativeUsfmParsingUnavailabilityReason =
    'Native USFM parsing is not available on this platform.';

Future<List<Map<String, dynamic>>> parseUsfmBundleToSerializable(
  UsfmSourceBundle bundle,
) async {
  throw UnsupportedError(nativeUsfmParsingUnavailabilityReason);
}
