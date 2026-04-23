import 'dart:convert';

import 'package:basic_bible/src/features/library/data/remote_translation_catalog_service.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('uses sourceId as the stable translation id when present', () async {
    final service = RemoteTranslationCatalogService(
      client: MockClient((_) async {
        return http.Response(
          jsonEncode({
            'translations': [
              {
                'id': 'NT',
                'sourceId': 'acuNT',
                'name': 'Achuar-shiwiar Bible',
                'language': 'acu',
                'languageName': 'Achuar-shiwiar',
                'artifacts': [
                  {
                    'format': 'usfx',
                    'downloadUrl': 'https://example.com/acuNT_usfx.zip',
                    'fileName': 'acuNT_usfx.zip',
                    'isPreferred': true,
                  },
                ],
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final translations = await service.fetchTranslations(forceRefresh: true);

    expect(translations, hasLength(1));
    expect(translations.single.id, 'acunt');
    expect(translations.single.format, BibleFormat.usfx);
  });

  test('prefers zip artifacts when that is the downloadable container', () {
    final translation = BibleTranslation(
      id: 'acunt',
      name: 'Achuar-shiwiar Bible',
      language: 'acu',
      description: '',
      format: BibleFormat.auto,
      sourceType: BibleSourceType.download,
      artifacts: const [
        BibleTranslationArtifact(
          format: BibleFormat.usfx,
          downloadUrl: 'https://example.com/acuNT_usfx.zip',
          fileName: 'acuNT_usfx.zip',
          isPreferred: true,
        ),
      ],
    );

    final artifact = firstPreferredRemoteArtifact(
      translation,
      supportedFormats: {
        BibleFormat.zip,
        BibleFormat.usfx,
      },
    );

    expect(artifact, isNotNull);
    expect(artifact!.fileName, 'acuNT_usfx.zip');
  });

  test('does not rank usfm ahead of richer formats when no artifact is preferred', () {
    final translation = BibleTranslation(
      id: 'demo',
      name: 'Demo Translation',
      language: 'en',
      description: '',
      format: BibleFormat.auto,
      sourceType: BibleSourceType.download,
      artifacts: const [
        BibleTranslationArtifact(
          format: BibleFormat.usfm,
          downloadUrl: 'https://example.com/demo_usfm.zip',
          fileName: 'demo_usfm.zip',
        ),
        BibleTranslationArtifact(
          format: BibleFormat.usfx,
          downloadUrl: 'https://example.com/demo_usfx.zip',
          fileName: 'demo_usfx.zip',
        ),
      ],
    );

    final artifact = firstPreferredRemoteArtifact(
      translation,
      supportedFormats: {
        BibleFormat.usfm,
        BibleFormat.usfx,
      },
    );

    expect(artifact, isNotNull);
    expect(artifact!.format, BibleFormat.usfx);
  });
}
