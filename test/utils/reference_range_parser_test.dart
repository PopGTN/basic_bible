import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_range_parser.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _labels(List<BibleReferenceRange> ranges) => [
  for (final r in ranges) r.toString(),
];

void main() {
  group('parseReferenceRangeList', () {
    test('keeps every passage in a semicolon list (#35/#75)', () {
      expect(_labels(parseReferenceRangeList('Ps 33:6; Is 45:18; Heb 11:3')), [
        'PSA 33:6',
        'ISA 45:18',
        'HEB 11:3',
      ]);
    });

    test('parses verse ranges instead of dropping the verse', () {
      expect(_labels(parseReferenceRangeList('Mat 5:3-5')), ['MAT 5:3-5']);
      expect(_labels(parseReferenceRangeList('Mat 5:3–5.')), ['MAT 5:3-5']);
    });

    test('carries book and chapter forward', () {
      expect(_labels(parseReferenceRangeList('Ps 33:6; 104:30, 32-33')), [
        'PSA 33:6',
        'PSA 104:30',
        'PSA 104:32-33',
      ]);
    });

    test('handles cross-chapter ranges', () {
      expect(_labels(parseReferenceRangeList('Gen 1:31-2:3')), [
        'GEN 1:31-2:3',
      ]);
    });

    test('whole chapters and single-chapter books', () {
      expect(_labels(parseReferenceRangeList('Ps 23')), ['PSA 23']);
      expect(_labels(parseReferenceRangeList('Jude 3')), ['JUD 1:3']);
    });

    test('numbered books with and without a space', () {
      expect(_labels(parseReferenceRangeList('1 Cor 13:4; 1Ch 11:11')), [
        '1CO 13:4',
        '1CH 11:11',
      ]);
    });

    test('skips junk without losing the rest', () {
      expect(_labels(parseReferenceRangeList('See Xyz 1:1; Joh 3:16')), [
        'JHN 3:16',
      ]);
      expect(parseReferenceRangeList(''), isEmpty);
    });
  });

  group('parseStructuredReferenceRanges', () {
    test('OSIS ranges and multiple targets', () {
      expect(
        _labels(parseStructuredReferenceRanges('Matt.5.3-Matt.5.5 Luke.6.20')),
        ['MAT 5:3-5', 'LUK 6:20'],
      );
    });

    test('target wins over label only when it parses', () {
      expect(
        _labels(parseReferenceRanges(target: 'GEN.1.1', label: 'Ps 23')),
        ['GEN 1:1'],
      );
      expect(
        _labels(parseReferenceRanges(target: '???', label: 'Ps 23:1')),
        ['PSA 23:1'],
      );
    });
  });

  test('BibleReferenceRange.contains', () {
    final range = parseReferenceRangeList('Gen 1:31-2:3').single;
    expect(range.contains(1, 30), isFalse);
    expect(range.contains(1, 31), isTrue);
    expect(range.contains(2, 1), isTrue);
    expect(range.contains(2, 4), isFalse);
  });

  test('resolveBookIdFromName rejects ambiguous prefixes', () {
    expect(resolveBookIdFromName('Jo'), isNull);
    expect(resolveBookIdFromName('Ps'), 'PSA');
    expect(resolveBookIdFromName('Song of Songs'), 'SNG');
  });
}
