import 'dart:convert';

import 'package:basic_bible/src/features/hymns/data/hymnal_json_codec.dart';
import 'package:basic_bible/src/features/hymns/data/hymnal_repository.dart';
import 'package:basic_bible/src/features/hymns/data/hymnal_store.dart';
import 'package:basic_bible/src/features/hymns/models/content_repository.dart';
import 'package:basic_bible/src/features/hymns/models/hymnal.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Uint8List _legacy(List<int> ids) => Uint8List.fromList(
  utf8.encode(
    jsonEncode([
      for (final id in ids)
        {
          'id': id,
          'title': 'Hymn $id',
          'verses': [
            ['line $id'],
          ],
        },
    ]),
  ),
);

class _Bundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(_legacy([1, 2, 3]));
}

const _repo = ContentRepository(
  id: 'friends',
  url: 'https://example.org/index.json',
  name: 'Friends',
  takedownContact: 'mailto:takedown@example.org',
);

void main() {
  late HymnalRepository repository;
  late Uint8List served;

  setUp(() {
    served = _legacy([10, 11]);
    repository = HymnalRepository(
      store: InMemoryHymnalStore(),
      bundle: _Bundle(),
      client: MockClient((_) async => http.Response.bytes(served, 200)),
      bundled: const [
        BundledHymnal(
          id: 'bhb',
          assetPath: 'x',
          title: 'BHB',
          shortTitle: 'BHB',
        ),
      ],
    );
  });

  test('loads bundled books from assets', () async {
    final hymnal = await repository.load('bhb');
    expect(hymnal.info.id, 'bhb');
    expect(hymnal.info.sourceKind, HymnalSourceKind.bundled);
    expect(hymnal.hymns, hasLength(3));
    expect(
      identical(await repository.load('bhb'), hymnal),
      isTrue,
      reason: 'cached',
    );
  });

  test('imports a file, lists it and can delete it', () async {
    final info = await repository.importBytes(
      _legacy([5]),
      fileName: 'choice_hymns.json',
    );
    expect(info.id, 'local/choice-hymns');
    expect(info.title, 'choice hymns');
    expect((await repository.listHymnals()).map((i) => i.id), [
      'bhb',
      'local/choice-hymns',
    ]);
    expect((await repository.load(info.id)).byNumber(5), isNotNull);

    await repository.delete(info.id);
    expect((await repository.listHymnals()).map((i) => i.id), ['bhb']);
    await repository.delete('bhb');
    expect((await repository.listHymnals()).map((i) => i.id), [
      'bhb',
    ], reason: 'bundled stays');
  });

  test('rejects files that are not hymnals', () {
    expect(
      repository.importBytes(
        Uint8List.fromList(utf8.encode('{}')),
        fileName: 'x.json',
      ),
      throwsA(isA<HymnalFormatException>()),
    );
  });

  test('installs from a repository with checksum and namespaced id', () async {
    final entry = RepoHymnalEntry(
      id: 'songs',
      title: 'Songs',
      downloadUrl: 'https://example.org/songs.json',
      sha256: sha256.convert(served).toString(),
      rightsStatus: 'public_domain',
    );
    final info = await repository.installFromRepository(_repo, entry);
    expect(info.id, 'friends/songs');
    expect(info.repoId, 'friends');
    expect(info.takedownContact, 'mailto:takedown@example.org');
    final loaded = await repository.load('friends/songs');
    expect(loaded.info.sourceKind, HymnalSourceKind.repository);

    final removed = await repository.removeWithdrawn('friends', {'songs'});
    expect(removed, ['friends/songs']);
    expect((await repository.listHymnals()).map((i) => i.id), ['bhb']);
  });

  test('refuses entries whose rights do not allow distribution', () {
    const entry = RepoHymnalEntry(
      id: 'x',
      title: 'X',
      downloadUrl: 'https://example.org/x.json',
      rightsStatus: 'unclear',
    );
    expect(
      repository.installFromRepository(_repo, entry),
      throwsA(isA<HymnalFormatException>()),
    );
  });

  test(
    'import lets the user choose the name, and re-import replaces',
    () async {
      final prepared = await repository.prepareImport(
        _legacy([1, 2]),
        fileName: 'favoritehymns.json',
      );
      expect(
        prepared.info.title,
        'favoritehymns',
        reason: 'from the file name',
      );
      expect(prepared.info.hymnCount, 2);
      expect(prepared.replacesExisting, isFalse);
      expect(
        await repository.listHymnals(),
        hasLength(1),
        reason: 'not saved yet',
      );

      final info = await repository.completeImport(
        prepared,
        title: 'Favorite Hymns',
        shortTitle: 'FH',
      );
      expect(info.title, 'Favorite Hymns');
      final loaded = await repository.load(info.id);
      expect(loaded.info.title, 'Favorite Hymns');
      expect(loaded.info.displayShortTitle, 'FH');

      final again = await repository.prepareImport(
        _legacy([1, 2, 3]),
        fileName: 'favoritehymns.json',
      );
      expect(again.replacesExisting, isTrue);
    },
  );

  test('rename sticks, even for a v1 file that names itself', () async {
    final v1 = Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'format': 'hymnal',
          'schemaVersion': 1,
          'book': {'id': 'gh', 'title': 'Gospel Hymns', 'shortTitle': 'GH'},
          'hymns': [
            {
              'id': 1,
              'title': 'x',
              'verses': [
                ['x'],
              ],
            },
          ],
        }),
      ),
    );
    final prepared = await repository.prepareImport(v1, fileName: 'x.json');
    expect(prepared.info.title, 'Gospel Hymns', reason: "the book's own title");
    final info = await repository.completeImport(
      prepared,
      title: prepared.info.title,
    );
    await repository.load(info.id);

    await repository.rename(info.id, title: 'Our Gospel Hymns', shortTitle: '');
    final reloaded = await repository.load(info.id);
    expect(reloaded.info.title, 'Our Gospel Hymns');
    expect(reloaded.info.displayShortTitle, 'Our Gospel Hymns');
    expect((await repository.listHymnals()).last.title, 'Our Gospel Hymns');
    expect(
      () => repository.rename('bhb', title: 'Nope'),
      throwsA(isA<HymnalFormatException>()),
      reason: 'bundled books keep their names',
    );
  });

  test('the drift store round-trips through SQLite', () async {
    final store = DriftHymnalStore(NativeDatabase.memory());
    final content = Uint8List.fromList([1, 2, 3]);
    await store.save(
      StoredHymnal(
        info: const HymnalInfo(id: 'local/a', title: 'A', hymnCount: 3),
        content: content,
        sha256: 'abc',
      ),
    );
    expect((await store.listInfos()).single.title, 'A');
    final read = await store.read('local/a');
    expect(read!.content, content);
    expect(read.sha256, 'abc');
    await store.delete('local/a');
    expect(await store.listInfos(), isEmpty);
    await store.close();
  });
}
