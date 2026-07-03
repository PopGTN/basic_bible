import 'package:bible_parser_flutter/bible_parser_flutter.dart'
    show VerseSpan, VerseSpanKind;

// The app previously duplicated the parser's rich-content models under
// Bible-prefixed names, which meant every parser change had to be mirrored
// by hand (and silently broke rendering when it wasn't). The names are now
// aliases for the parser's classes — one source of truth. JSON serialization
// lives on the parser classes and is byte-identical to the old format, so
// cached translations stay valid.
typedef BibleVerseSpanKind = VerseSpanKind;
typedef BibleVerseSpan = VerseSpan;
