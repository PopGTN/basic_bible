import 'usfm_bundle_support.dart';
import 'usfm_parser_bridge_stub.dart'
    if (dart.library.io) 'usfm_parser_bridge_native.dart'
    if (dart.library.js_interop) 'usfm_parser_bridge_web.dart' as impl;

bool get supportsNativeUsfmParsing => impl.supportsNativeUsfmParsing;
String get nativeUsfmParsingUnavailabilityReason =>
    impl.nativeUsfmParsingUnavailabilityReason;

Future<List<Map<String, dynamic>>> parseUsfmBundleToSerializable(
  UsfmSourceBundle bundle,
) => impl.parseUsfmBundleToSerializable(bundle);
