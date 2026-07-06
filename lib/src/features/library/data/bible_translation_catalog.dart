import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:basic_bible/src/models/bible_models.dart';

// =============================================================================
// Built-in translation definitions
// =============================================================================

/// The canonical list of translations shipped with the app.
/// Always appears in the available list even with no network and no DB row.
final List<BibleTranslation> kBuiltInTranslations = [
  // Both bundled KJV assets ship gzipped (62 MB raw → 8 MB shipped); the
  // asset loaders decompress transparently for `.gz` paths.
  //
  // IMPORTANT: kjv.sqlite.gz is a pre-parsed snapshot. When
  // kCurrentParserVersion is bumped, regenerate it (export the re-parsed
  // kjv.sqlite via Advanced Settings, then `gzip -9`) or shipped KJV will
  // silently lack the new parser features — the restore path stamps it with
  // the current version.
  BibleTranslation(
    id: 'kjv',
    name: 'King James Version',
    language: 'en',
    languageName: 'English',
    description: 'The classic English Bible translation',
    isLocal: true,
    filePath: kIsWeb
        ? 'assets/bible/eng-kjv2006_usfx.xml.gz'
        : 'assets/bible/kjv.sqlite.gz',
    githubUrl:
        'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/kjv/eng-kjv2006_usfx.xml',
    format: kIsWeb ? BibleFormat.usfx : BibleFormat.sqlite,
    sourceType: BibleSourceType.asset,
    bundledByDefault: true,
    displayOrder: 10,
    artifacts: [
      BibleTranslationArtifact(
        format: kIsWeb ? BibleFormat.usfx : BibleFormat.sqlite,
        downloadUrl:
            'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/kjv/eng-kjv2006_usfx.xml',
        fileName: kIsWeb ? 'eng-kjv2006_usfx.xml' : 'kjv.sqlite',
        isPreferred: true,
      ),
    ],
  ),
  BibleTranslation(
    id: 'asv',
    name: 'American Standard Version',
    language: 'en',
    languageName: 'English',
    description: 'American Standard Version (1901)',
    isLocal: false,
    githubUrl:
        'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/asv/asv_osis.xml',
    format: BibleFormat.osis,
    sourceType: BibleSourceType.download,
    displayOrder: 20,
    artifacts: [
      BibleTranslationArtifact(
        format: BibleFormat.osis,
        downloadUrl:
            'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/asv/asv_osis.xml',
        fileName: 'asv_osis.xml',
        isPreferred: true,
      ),
    ],
  ),
  BibleTranslation(
    id: 'web',
    name: 'World English Bible',
    language: 'en',
    languageName: 'English',
    description: 'Modern English public domain Bible',
    isLocal: false,
    githubUrl:
        'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/web/eng-web.usfx.xml',
    format: BibleFormat.usfx,
    sourceType: BibleSourceType.download,
    displayOrder: 30,
    artifacts: [
      BibleTranslationArtifact(
        format: BibleFormat.usfx,
        downloadUrl:
            'https://raw.githubusercontent.com/PopGTN/bible-data/main/English/web/eng-web.usfx.xml',
        fileName: 'eng-web.usfx.xml',
        isPreferred: true,
      ),
    ],
  ),
];

// =============================================================================
// Pure merge helpers — no mutable state; all inputs are parameters
// =============================================================================

/// Overlays enriched catalog data from the remote feed onto a built-in entry.
/// Only the fields the catalog is authoritative for are overwritten.
BibleTranslation mergeCatalogTranslation({
  required BibleTranslation builtIn,
  BibleTranslation? remote,
}) {
  if (remote == null) return builtIn;
  return builtIn.copyWith(
    name: remote.name,
    language: remote.language,
    languageName: remote.languageName,
    description: remote.description,
    githubUrl: remote.githubUrl ?? builtIn.githubUrl,
    format: remote.format == BibleFormat.auto ? builtIn.format : remote.format,
    bundledByDefault: remote.bundledByDefault || builtIn.bundledByDefault,
    displayOrder: remote.displayOrder,
    artifacts: remote.artifacts.isEmpty ? builtIn.artifacts : remote.artifacts,
  );
}

/// Overlays persisted DB data onto a base translation entry.
///
/// [overrideSourceType] — when true the base code definition's sourceType wins
/// over whatever was previously stored in the DB. Use this for built-in
/// translations so a stale DB row never hides Remove/Download UI actions.
BibleTranslation mergeStoredTranslation({
  required BibleTranslation base,
  required BibleTranslation? stored,
  bool overrideSourceType = false,
}) {
  if (stored == null) return base;
  final effectiveSourceType =
      overrideSourceType ? base.sourceType : stored.sourceType;
  // Build directly instead of copyWith so filePath can be explicitly cleared
  // to null for download/session types (copyWith cannot pass null).
  final resolvedFilePath = switch (effectiveSourceType) {
    BibleSourceType.asset => base.filePath,
    BibleSourceType.import => stored.filePath,
    BibleSourceType.download || BibleSourceType.session => null,
  };
  return BibleTranslation(
    id: base.id,
    name: stored.name,
    language: stored.language,
    languageName: stored.languageName.isNotEmpty
        ? stored.languageName
        : base.languageName,
    description: stored.description,
    isLocal: stored.isLocal,
    filePath: resolvedFilePath,
    githubUrl: stored.githubUrl ?? base.githubUrl,
    format: stored.format == BibleFormat.auto ? base.format : stored.format,
    sourceType: effectiveSourceType,
    bundledByDefault: base.bundledByDefault,
    displayOrder: base.displayOrder,
    artifacts: base.artifacts,
  );
}

/// Overlays in-memory session state onto a translation.
/// A session translation is one opened from the network without being saved.
BibleTranslation applySessionState(
  BibleTranslation translation,
  Set<String> sessionTranslationIds,
) {
  if (!sessionTranslationIds.contains(translation.id)) return translation;
  return translation.copyWith(
    isLocal: false,
    sourceType: BibleSourceType.session,
  );
}

/// Returns the canonical source location string for a translation to persist
/// in the installed-translations registry.
String? sourceLocationForTranslation(BibleTranslation translation) {
  return switch (translation.sourceType) {
    BibleSourceType.asset || BibleSourceType.import => translation.filePath,
    BibleSourceType.session => translation.githubUrl,
    BibleSourceType.download => translation.githubUrl,
  };
}
