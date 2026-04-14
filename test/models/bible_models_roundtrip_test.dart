import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserves rich USFX verse span metadata through json roundtrip', () {
    const span = BibleVerseSpan(
      text: 'beginning',
      kind: BibleVerseSpanKind.word,
      metadata: {
        'strongs': 'H7225',
        'lemma': 'reʾshit',
        'morph': 'Ncfsa',
        'quoteWho': 'Moses',
      },
    );

    final roundTrip = BibleVerseSpan.fromJson(span.toJson());

    expect(roundTrip.text, span.text);
    expect(roundTrip.kind, span.kind);
    expect(roundTrip.metadata, span.metadata);
  });

  test('preserves structured USFX footnotes and cross references', () {
    const reference = BibleCrossReference(
      label: 'JHN 1:1',
      target: 'JHN.1.1',
      marker: 'a',
      originRef: 'GEN 1:1',
      spanIndex: 2,
      charOffset: 14,
    );
    const footnote = BibleFootnote(
      text: 'Or the beginning of creation',
      marker: '*',
      label: '1:1',
      bodyText: 'Or the beginning of creation',
      quotedText: 'In the beginning',
      references: [reference],
      spanIndex: 1,
      charOffset: 9,
    );

    final footnoteRoundTrip = BibleFootnote.fromJson(footnote.toJson());
    final referenceRoundTrip = BibleCrossReference.fromJson(reference.toJson());

    expect(footnoteRoundTrip, footnote);
    expect(referenceRoundTrip, reference);
  });

  test('preserves intro and chapter document block metadata', () {
    const block = BibleDocumentBlock(
      kind: BibleDocumentBlockKind.introduction,
      text: 'Outline of Genesis',
      level: 2,
      metadata: {'sourceTag': 'io2', 'beforeVerse': '1'},
    );

    final roundTrip = BibleDocumentBlock.fromJson(block.toJson());

    expect(roundTrip, block);
  });
}
