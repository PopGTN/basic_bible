import 'package:basic_bible/src/features/hymns/data/hymn_search.dart';
import 'package:basic_bible/src/features/hymns/models/hymn.dart';
import 'package:basic_bible/src/features/hymns/models/hymn_search_index.dart';
import 'package:basic_bible/src/features/hymns/models/hymnal.dart';
import 'package:flutter_test/flutter_test.dart';

Hymnal _book(List<Hymn> hymns) => Hymnal(
  info: const HymnalInfo(id: 't', title: 'Test'),
  hymns: hymns,
  index: HymnSearchIndex(hymns),
);

final _hymns = [
  const Hymn(
    number: 1,
    title: 'Abba, Father! we approach Thee',
    author: 'James George Deck',
    verses: [
      ['Abba, Father! we approach Thee', "In our Saviour's precious name;"],
    ],
  ),
  const Hymn(
    number: 12,
    title: 'Rock of Ages! Cleft for me',
    author: 'Augustus Montague Toplady',
    verses: [
      ['Rock of Ages! Cleft for me,', 'Lo, I hide myself in Thee,'],
    ],
  ),
  const Hymn(
    number: 2,
    title: "'Tis the blessed hour of prayer",
    author: 'Frances Jane Crosby',
    verses: [
      ["'Tis the blessed hour of prayer", 'when our hearts lowly bend,'],
    ],
    chorus: ['Behold the Lamb of God'],
  ),
  const Hymn(
    number: 120,
    title: 'Lamb of God! our souls adore Thee',
    verses: [
      ['Lamb of God! our souls adore Thee', 'While upon Thy face we gaze;'],
    ],
  ),
  const Hymn(
    number: 30,
    title: 'Himno de alabanza',
    verses: [
      ['Canción de la mañana', 'Señor, a Ti'],
    ],
  ),
];

List<int> _numbers(
  String query, {
  HymnSortOrder sort = HymnSortOrder.number,
  Set<int>? favorites,
}) {
  final sorted = [..._hymns]..sort((a, b) => a.number.compareTo(b.number));
  return searchHymnal(
    _book(sorted),
    query,
    sort: sort,
    favorites: favorites,
  ).map((h) => h.number).toList();
}

void main() {
  test('normalizes punctuation, apostrophes and diacritics', () {
    expect(normalizeHymnText("'Tis o'er — Señor!"), 'tis oer senor');
    expect(normalizeHymnText('  Rock   of\tAges '), 'rock of ages');
  });

  test('empty query lists every hymn in the chosen order', () {
    expect(_numbers(''), [1, 2, 12, 30, 120]);
    expect(_numbers('', sort: HymnSortOrder.alphabetical), [
      1,
      30,
      120,
      12,
      2,
    ], reason: "'Tis sorts under T");
  });

  test('a number finds that hymn first, then numbers starting with it', () {
    expect(_numbers('12'), [12, 120]);
    expect(_numbers('#2'), [2]);
    expect(_numbers('999'), isEmpty);
  });

  test('words match by prefix and all words must match', () {
    expect(_numbers('rock age'), [12]);
    expect(_numbers('lamb god'), [120, 2], reason: 'title match beats chorus');
    expect(_numbers('lamb nonsense'), isEmpty);
  });

  test('quoted phrases must appear word for word', () {
    expect(_numbers('"lamb of god"'), [120, 2]);
    expect(_numbers('"god of lamb"'), isEmpty);
  });

  test('searches authors, apostrophes and accents', () {
    expect(_numbers('toplady'), [12]);
    expect(_numbers('tis blessed'), [2]);
    expect(_numbers('cancion senor'), [30]);
  });

  test('mid-word fallback for longer fragments', () {
    expect(_numbers('ppro'), [1]);
  });

  test('favorites filter applies to browse and search', () {
    expect(_numbers('', favorites: {12, 2}), [2, 12]);
    expect(_numbers('lamb', favorites: {2}), [2]);
  });

  test('searching 1,200 hymns stays fast', () {
    final big = [
      for (var i = 1; i <= 1200; i++)
        Hymn(
          number: i,
          title: 'Hymn number $i of praise',
          author: 'Author ${i % 50}',
          verses: [
            for (var v = 0; v < 5; v++)
              [
                'Verse $v line one about grace and glory $i',
                'and the love of God that never ends',
                'we sing the praises of the Lamb once slain',
                'until the morning breaks upon the hills',
              ],
          ],
        ),
    ];
    final book = _book(big);
    searchHymnal(book, 'warm up');
    final watch = Stopwatch()..start();
    for (final q in [
      'lamb slain',
      'grace glory 77',
      '"love of god"',
      'mor',
      '1',
    ]) {
      searchHymnal(book, q);
    }
    watch.stop();
    // 5 queries; generous bound so slow CI machines don't flake.
    expect(watch.elapsedMilliseconds, lessThan(250));
  });

  test('typing an exact number decides when to open that hymn', () {
    final sorted = [..._hymns]..sort((a, b) => a.number.compareTo(b.number));
    final book = _book(sorted); // numbers 1, 2, 12, 30, 120
    expect(hymnToAutoOpen(book, '30'), (number: 30, when: HymnAutoOpen.now));
    expect(hymnToAutoOpen(book, '#2'), (number: 2, when: HymnAutoOpen.now));
    expect(hymnToAutoOpen(book, '12'), (
      number: 12,
      when: HymnAutoOpen.afterPause,
    ), reason: '120 also starts with 12');
    expect(hymnToAutoOpen(book, '1'), (
      number: 1,
      when: HymnAutoOpen.afterPause,
    ));
    expect(hymnToAutoOpen(book, '120'), (number: 120, when: HymnAutoOpen.now));
    expect(hymnToAutoOpen(book, '3'), isNull, reason: 'no hymn 3');
    expect(hymnToAutoOpen(book, 'lamb'), isNull);
    expect(hymnToAutoOpen(book, '12 lamb'), isNull);
  });
}
