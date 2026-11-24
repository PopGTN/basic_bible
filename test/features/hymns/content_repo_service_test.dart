import 'dart:convert';

import 'package:basic_bible/src/features/hymns/data/content_repo_service.dart';
import 'package:basic_bible/src/features/hymns/models/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _index({List<String> withdrawn = const []}) => {
  'format': 'basic-bible-repo',
  'schemaVersion': 1,
  'repo': {
    'id': 'friends',
    'name': 'Friends Hymns',
    'takedownContact': 'mailto:t@example.org',
  },
  'hymnals': [
    {
      'id': 'a',
      'title': 'Book A',
      'downloadUrl': 'https://example.org/a.json',
      'rightsStatus': 'public_domain',
    },
    {
      'id': 'b',
      'title': 'Book B',
      'downloadUrl': 'https://example.org/b.json',
      'rightsStatus': 'unclear',
    },
  ],
  'withdrawn': withdrawn,
};

void main() {
  late SharedPreferences prefs;
  var body = jsonEncode(_index());
  var online = true;
  final client = MockClient((request) async {
    if (!online) throw http.ClientException('offline');
    return http.Response(body, 200);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    body = jsonEncode(_index());
    online = true;
  });

  test(
    'the official repository is always listed and cannot be removed',
    () async {
      final service = ContentRepoService(prefs, client: client);
      expect(service.loadRepositories().single.isOfficial, isTrue);
      await service.removeRepository(ContentRepoService.officialRepoId);
      expect(service.loadRepositories().single.isOfficial, isTrue);
      await service.setEnabled(ContentRepoService.officialRepoId, false);
      expect(service.loadRepositories().single.enabled, isFalse);
    },
  );

  test('adds a third-party repository from its index', () async {
    final service = ContentRepoService(prefs, client: client);
    final index = await service.probe('https://example.org/index.json');
    expect(index.hymnals.map((h) => h.id), ['a', 'b']);
    expect(index.hymnals.map((h) => h.isDownloadable), [true, false]);

    final repo = await service.addRepository(
      'https://example.org/index.json',
      index,
    );
    expect(repo.id, 'friends');
    expect(repo.takedownContact, 'mailto:t@example.org');
    expect(service.loadRepositories().map((r) => r.id), [
      'official',
      'friends',
    ]);
    expect(
      () => service.addRepository('https://example.org/index.json', index),
      throwsA(isA<ContentRepoException>()),
    );

    await service.removeRepository('friends');
    expect(service.loadRepositories().map((r) => r.id), ['official']);
  });

  test('refuses insecure and non-index addresses', () async {
    final service = ContentRepoService(prefs, client: client);
    await expectLater(
      service.probe('http://example.org/index.json'),
      throwsA(isA<ContentRepoException>()),
    );
    await expectLater(
      service.probe('not a url'),
      throwsA(isA<ContentRepoException>()),
    );
    body = jsonEncode({'translations': []});
    await expectLater(
      service.probe('https://example.org/x.json'),
      throwsA(isA<ContentRepoException>()),
    );
    body = jsonEncode(_index());
    expect(
      (await service.probe('http://localhost:8080/index.json')).name,
      'Friends Hymns',
    );
  });

  test('withdrawn ids are hidden from the listing', () {
    final index = RepoIndex.fromJson(_index(withdrawn: ['a']));
    expect(index.hymnals.map((h) => h.id), ['b']);
    expect(index.withdrawn, {'a'});
  });

  test('serves the last good index when offline', () async {
    final service = ContentRepoService(prefs, client: client);
    const repo = ContentRepository(
      id: 'f',
      url: 'https://example.org/index.json',
      name: 'F',
    );
    expect((await service.fetchIndex(repo)).hymnals, hasLength(2));
    online = false;
    final fresh = ContentRepoService(prefs, client: client);
    expect((await fresh.fetchIndex(repo)).name, 'Friends Hymns');
  });
}
