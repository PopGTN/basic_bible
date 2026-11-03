import 'package:flutter/foundation.dart';

/// Where a reader font comes from.
enum ReaderFontSource {
  /// The app's normal theme font (no override).
  systemDefault,

  /// Shipped inside the app under `assets/fonts/`.
  bundled,

  /// Found in the operating system's font folders.
  device,

  /// A font file the user imported; copied into app storage.
  imported,
}

/// One selectable font for Bible text.
@immutable
class ReaderFont {
  const ReaderFont({
    required this.id,
    required this.name,
    required this.source,
    this.family,
    this.paths = const [],
    this.sizeBytes = 0,
  });

  /// The "no override" choice.
  static const systemDefault = ReaderFont(
    id: 'default',
    name: 'System Default',
    source: ReaderFontSource.systemDefault,
  );

  /// Stable identifier persisted in preferences.
  final String id;

  /// Human-readable name shown in the picker.
  final String name;

  final ReaderFontSource source;

  /// Flutter font-family name to put in a [TextStyle]; null for the default.
  final String? family;

  /// Asset keys (bundled) or file paths (device/imported) that make up the
  /// family — usually Regular/Bold/Italic/BoldItalic.
  final List<String> paths;

  /// Total size on disk, used to avoid eagerly previewing huge fonts.
  final int sizeBytes;

  bool get isDefault => source == ReaderFontSource.systemDefault;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'source': source.name,
    'family': family,
    'paths': paths,
    'sizeBytes': sizeBytes,
  };

  static ReaderFont? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final source = ReaderFontSource.values.asNameMap()[raw['source']];
    final id = raw['id'];
    final name = raw['name'];
    if (source == null || id is! String || name is! String) return null;
    return ReaderFont(
      id: id,
      name: name,
      source: source,
      family: raw['family'] is String ? raw['family'] as String : null,
      paths: [
        if (raw['paths'] case final List paths)
          for (final path in paths) '$path',
      ],
      sizeBytes: (raw['sizeBytes'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) => other is ReaderFont && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Why a user-supplied font file was rejected. The UI turns this into a
/// localized message.
enum InvalidFontReason {
  /// Not a `.ttf` / `.otf` file name.
  unsupportedType,

  /// The bytes don't start with a TrueType/OpenType signature.
  notAFont,

  /// The engine refused to load it.
  unloadable,
}

/// Thrown when a user-supplied file isn't a usable font.
class InvalidFontFileException implements Exception {
  const InvalidFontFileException(this.reason);
  final InvalidFontReason reason;
  @override
  String toString() => 'InvalidFontFileException(${reason.name})';
}

/// Turns a font file stem into a display name:
/// `NotoSerif` / `open_sans` → `Noto Serif` / `Open sans`.
String prettyFontName(String raw) {
  final spaced = raw
      .replaceAll(RegExp(r'[_]+'), ' ')
      .replaceAllMapped(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'), (_) => ' ')
      .trim();
  if (spaced.isEmpty) return raw;
  return spaced[0].toUpperCase() + spaced.substring(1);
}
