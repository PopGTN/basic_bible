// #88: code shipped outside pub must appear on the open-source licenses page.

import 'package:basic_bible/src/services/additional_licenses.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every listed license file exists and is not empty', () async {
    for (final license in kAdditionalLicenses) {
      final text = await rootBundle.loadString(license.assetPath);
      expect(text.trim(), isNotEmpty, reason: license.assetPath);
    }
  });

  test('sql.js is registered on web with its MIT text, and not on native',
      () async {
    LicenseRegistry.reset();
    registerAdditionalLicenses(isWeb: false);
    expect(await LicenseRegistry.licenses.toList(), isEmpty);

    LicenseRegistry.reset();
    registerAdditionalLicenses(isWeb: true);
    final entries = await LicenseRegistry.licenses.toList();
    expect(entries.single.packages, ['sql.js']);
    final text = entries.single.paragraphs.map((p) => p.text).join('\n');
    expect(text, contains('MIT license'));
    expect(text, contains('Copyright (c) 2017 sql.js authors'));
    LicenseRegistry.reset();
  });
}
