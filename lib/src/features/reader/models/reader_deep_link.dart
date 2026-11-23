import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:equatable/equatable.dart';

/// URL scheme registered on Android and iOS (#40).
const String kReaderLinkScheme = 'basicbible';

/// A link that opens the reader at a book/chapter (and optionally a verse),
/// optionally in a specific translation (#40).
///
/// Accepted forms (book = ID like `JHN` or a name/abbreviation like `John`):
///   basicbible://bible/JHN/3/16?translation=kjv
///   /bible/John/3            (web path, or what Android/iOS hand Flutter)
///   /JHN/3/16                (custom-scheme link after the OS drops the host)
///   /bible/JHN.3.16          (single dotted segment)
/// `t=` is accepted as a short form of `translation=`.
class ReaderDeepLink extends Equatable {
  const ReaderDeepLink({required this.reference, this.translationId});

  final BibleReference reference;
  final String? translationId;

  /// Canonical shareable link, e.g. for Markdown notes.
  Uri toUri() => Uri(
    scheme: kReaderLinkScheme,
    host: 'bible',
    pathSegments: [
      reference.bookId,
      '${reference.chapter}',
      if (reference.verse != null) '${reference.verse}',
    ],
    queryParameters: translationId == null
        ? null
        : {'translation': translationId},
  );

  /// Parses [uri], or returns null when it isn't a reader link. Only paths
  /// whose first segment is a real book and second a chapter number qualify,
  /// so app routes such as `/home/notes` never match.
  static ReaderDeepLink? tryParse(Uri uri) {
    var segments = [
      // A full custom-scheme URI keeps "bible" as the host.
      if (uri.scheme == kReaderLinkScheme && uri.host.isNotEmpty) uri.host,
      ...uri.pathSegments.where((s) => s.isNotEmpty),
    ].map(Uri.decodeComponent).toList();

    if (segments.isNotEmpty &&
        const {'bible', 'read'}.contains(segments.first.toLowerCase())) {
      segments = segments.sublist(1);
    }
    if (segments.length == 1 && segments.single.contains('.')) {
      segments = segments.single.split('.');
    }
    if (segments.length < 2 || segments.length > 3) return null;

    final bookId = resolveBookIdFromName(segments[0]);
    final chapter = int.tryParse(segments[1]);
    final verse = segments.length == 3 ? int.tryParse(segments[2]) : null;
    if (bookId == null || chapter == null || chapter < 1) return null;
    if (segments.length == 3 && (verse == null || verse < 1)) return null;

    final translation =
        (uri.queryParameters['translation'] ?? uri.queryParameters['t'])
            ?.trim()
            .toLowerCase();
    return ReaderDeepLink(
      reference: BibleReference(bookId: bookId, chapter: chapter, verse: verse),
      translationId: translation == null || translation.isEmpty
          ? null
          : translation,
    );
  }

  @override
  List<Object?> get props => [reference, translationId];
}
