import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Third-party code that ships with the app but that Flutter's license page
/// can't discover by itself (#88).
///
/// Flutter already collects the LICENSE of every pub package (including
/// path dependencies such as bible_parser_flutter) and of the engine. What
/// it can't see is code loaded some other way. Add an entry here — with the
/// license text as a file under assets/licenses/ — whenever the app starts
/// shipping or loading something new outside pub (a bundled font, a vendored
/// native library, a script tag in web/index.html).
class AdditionalLicense {
  const AdditionalLicense({
    required this.packages,
    required this.assetPath,
    this.webOnly = false,
  });

  /// Names shown on the license page.
  final List<String> packages;
  final String assetPath;

  /// Only shipped in the web build.
  final bool webOnly;
}

const List<AdditionalLicense> kAdditionalLicenses = [
  // SQLite compiled to WebAssembly; web/index.html loads it from cdnjs for
  // drift's web database. SQLite itself is public domain.
  AdditionalLicense(
    packages: ['sql.js'],
    assetPath: 'assets/licenses/sql.js.txt',
    webOnly: true,
  ),
];

/// Registers [kAdditionalLicenses] with Flutter's [LicenseRegistry]. Call
/// once at startup. Texts load lazily, only when the license page opens.
void registerAdditionalLicenses({
  bool isWeb = kIsWeb,
  AssetBundle? bundle,
}) {
  final licenses = [
    for (final license in kAdditionalLicenses)
      if (!license.webOnly || isWeb) license,
  ];
  if (licenses.isEmpty) return;
  LicenseRegistry.addLicense(() async* {
    for (final license in licenses) {
      yield LicenseEntryWithLineBreaks(
        license.packages,
        await (bundle ?? rootBundle).loadString(license.assetPath),
      );
    }
  });
}
