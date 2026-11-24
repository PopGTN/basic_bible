// Builds the bundled hymnal assets from raw legacy JSON.
//
//   dart run tool/hymnals/build_hymnal.dart bhb [nbhb ...]
//
// For each book id it reads `tool/hymnals/<id>.meta.json` (the `book` block
// plus source/output paths) and `<id>.overrides.json` (hand-reviewed
// per-hymn patches), applies the automatic clean-ups below, validates the
// result, and writes:
//   - assets/hymnals/<id>.json.gz   the shipped asset (schema "hymnal" v1)
//   - build/hymnals/<id>.json       pretty copy for review (not shipped)
//   - build/hymnals/<id>.report.txt anything that still needs a human look
//
// Automatic clean-ups (see `_autoClean`):
//   - "header" verses: a first verse like ["Charitie Bancroft", "11.10.11.10."]
//     with the meter used as the title is moved into author/meter.
//   - editor notes inside lyrics: "OPTIONAL: …", "[optional chorus]",
//     "[Chorus for tune …]", "[** … **]" become optionalVerses /
//     alternateChoruses / notes instead of lyric lines.
//
// Never edit the generated asset by hand — change the overrides and rebuild.
import 'dart:convert';
import 'dart:io';

final _toolDir = File.fromUri(Platform.script).parent;

final _meterLike = RegExp(
  r"^((\d+(\.\d+)*\.?(\s*(D|d)\.?)?)|([CLSP]\.?\s?M\.?(\s?D\.?)?)|(\d+\.\d+.*'s)|.*\bwith (chorus|refrain)\b.*|irregular\.?|P\.M\.)$",
  caseSensitive: false,
);
final _optionalVerse = RegExp(
  r'^\s*OPTIONAL:\s*(.+?)\s*$',
  caseSensitive: false,
);
final _optionalChorus = RegExp(
  r'^\s*\[\s*(optional chorus.*?)\s*\]\s*$',
  caseSensitive: false,
);
final _bracketNote = RegExp(r'^\s*\[\s*\**\s*(.+?)\s*\**\s*\]\s*$');
final _suspicious = RegExp(
  r'^\s*[\[(].*[\])]\s*$|\(c\)|OPTIONAL|\(\d+x\b|[\[(]repeat',
  caseSensitive: false,
);

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run tool/hymnals/build_hymnal.dart <id> [...]');
    exit(64);
  }
  var failed = false;
  for (final id in args) {
    failed = !_build(id) || failed;
  }
  if (failed) exit(1);
}

bool _build(String id) {
  final metaFile = File('${_toolDir.path}/$id.meta.json');
  final meta = jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>;
  var sourceFile = File('${_toolDir.path}/${meta['source']}');
  var isDraft = false;
  if (!sourceFile.existsSync() && meta['draftSource'] != null) {
    isDraft = true;
    stdout.writeln(
      '[$id] ${meta['source']} not found — building from DRAFT '
      '${meta['draftSource']} (not for release).',
    );
    sourceFile = File('${_toolDir.path}/${meta['draftSource']}');
  }
  if (!sourceFile.existsSync()) {
    stderr.writeln('[$id] no source file; skipped.');
    return false;
  }
  final overridesFile = File('${_toolDir.path}/$id.overrides.json');
  final overrides = overridesFile.existsSync()
      ? jsonDecode(overridesFile.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};

  final raw = jsonDecode(sourceFile.readAsStringSync());
  final rawHymns = raw is List ? raw : (raw as Map)['hymns'] as List;
  final report = <String>[];
  final hymns = <Map<String, dynamic>>[];
  final seen = <int>{};

  for (final entry in rawHymns) {
    final hymn = _normalize(Map<String, dynamic>.from(entry as Map));
    final hid = hymn['id'] as int;
    _autoClean(hymn, report);
    final patch = overrides['$hid'];
    if (patch is Map<String, dynamic>) _applyOverride(hymn, patch, report);
    _applyRightsRules(hymn, meta['rightsRules']);
    _finish(hymn);
    if (!seen.add(hid)) report.add('#$hid ERROR duplicate id');
    _validate(hymn, report);
    hymns.add(hymn);
  }
  for (final key in overrides.keys) {
    if (key.startsWith('_')) continue;
    if (!seen.contains(int.tryParse(key))) {
      report.add('override "$key" does not match any hymn');
    }
  }
  hymns.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

  final book = Map<String, dynamic>.from(meta['book'] as Map);
  final doc = <String, dynamic>{
    'format': 'hymnal',
    'schemaVersion': 1,
    'book': book,
    'hymns': hymns,
  };

  List<Object?> idsWith(String status) => hymns
      .where((h) => h['rightsStatus'] == status)
      .map((h) => h['id'])
      .toList();
  final unclear = idsWith('unclear');
  if (unclear.isNotEmpty) {
    report.add(
      'rights to confirm with publisher (${unclear.length}): '
      '${unclear.join(', ')}',
    );
  }
  final thirdParty = idsWith('third_party');
  if (thirdParty.isNotEmpty) {
    report.add(
      'owned by third parties — app permission needed from the '
      'owner, or written confirmation that the publisher\'s licence covers '
      'the app (${thirdParty.length}): ${thirdParty.join(', ')}',
    );
  }
  final todos = book.entries
      .where((e) => e.value is String && (e.value as String).contains('TODO_'))
      .map((e) => e.key)
      .toList();
  if (todos.isNotEmpty) {
    report.add('book fields still TODO: ${todos.join(', ')}');
  }

  // Drafts never land in assets/, so they can't ship by accident.
  final output = isDraft
      ? File('${_toolDir.path}/../../build/hymnals/$id.draft.json.gz')
      : File('${_toolDir.path}/${meta['output']}');
  output.parent.createSync(recursive: true);
  final bytes = GZipCodec(level: 9).encode(utf8.encode(jsonEncode(doc)));
  output.writeAsBytesSync(bytes);

  final reviewDir = Directory('${_toolDir.path}/../../build/hymnals')
    ..createSync(recursive: true);
  File(
    '${reviewDir.path}/$id.json',
  ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(doc));
  File(
    '${reviewDir.path}/$id.report.txt',
  ).writeAsStringSync('${report.join('\n')}\n');

  final errors = report.where((l) => l.contains('ERROR')).length;
  stdout.writeln(
    '[$id] ${hymns.length} hymns → ${output.path} '
    '(${bytes.length} bytes gz). ${report.length} report lines, '
    '$errors errors. Review: build/hymnals/$id.report.txt',
  );
  return errors == 0;
}

Map<String, dynamic> _normalize(Map<String, dynamic> h) {
  List<String> lines(Object? v) => [
    for (final l in (v as List? ?? const [])) l.toString(),
  ];
  return <String, dynamic>{
    'id': h['id'] is int ? h['id'] : int.parse('${h['id']}'),
    'title': '${h['title'] ?? ''}'.trim(),
    'author': '${h['author'] ?? ''}'.trim(),
    'meter': '${h['meter'] ?? ''}'.trim(),
    'tuneName': '${h['tuneName'] ?? ''}'.trim(),
    'verses': [for (final v in (h['verses'] as List? ?? const [])) lines(v)],
    'chorus': lines(h['chorus']),
    'addedChorus': lines(h['addedChorus']),
    'notes': <String>[...lines(h['notes'])],
    'optionalVerses': <Map<String, dynamic>>[
      for (final p in (h['optionalVerses'] as List? ?? const []))
        Map<String, dynamic>.from(p as Map),
    ],
    'alternateChoruses': <Map<String, dynamic>>[
      for (final p in (h['alternateChoruses'] as List? ?? const []))
        Map<String, dynamic>.from(p as Map),
    ],
    if (h['copyright'] != null) 'copyright': h['copyright'],
    if (h['rightsStatus'] != null) 'rightsStatus': h['rightsStatus'],
  };
}

void _autoClean(Map<String, dynamic> h, List<String> report) {
  final id = h['id'];
  final verses = h['verses'] as List<List<String>>;

  // Header verse: [author, meter] as the first verse, with either the meter
  // or the author copied into the title. The author line may carry the
  // hymn's copyright notice glued on ("Stuart Townend© 1995 Thankyou…").
  final title = h['title'] as String;
  final first = verses.isEmpty ? const <String>[] : verses.first;
  if (verses.length > 1 &&
      first.isNotEmpty &&
      first.length <= 2 &&
      _meterLike.hasMatch(first.last.trim()) &&
      (_meterLike.hasMatch(title) || title.trim() == first.first.trim())) {
    final header = verses.removeAt(0);
    for (final line in header) {
      final clean = line.trim();
      if (_meterLike.hasMatch(clean)) {
        if ((h['meter'] as String).isEmpty) h['meter'] = clean;
      } else if ((h['author'] as String).isEmpty) {
        final mark = clean.indexOf('©');
        if (mark >= 0) {
          // "Copyright © 1952 …" has no author before the ©.
          final before = clean.substring(0, mark).trim();
          final noAuthor = RegExp(
            r'^(copyright)?$',
            caseSensitive: false,
          ).hasMatch(before);
          h['author'] = noAuthor ? '' : before;
          h['copyright'] ??= noAuthor ? clean : clean.substring(mark).trim();
        } else {
          h['author'] = clean;
        }
      }
    }
    if ((h['meter'] as String).isEmpty && _meterLike.hasMatch(title)) {
      h['meter'] = title;
    }
    verses.first[0] = _uncapFirstWord(verses.first.first);
    h['title'] = verses.first.first;
    report.add(
      '#$id fixed header verse → author "${h['author']}", '
      'meter "${h['meter']}", title "${h['title']}"'
      '${h['copyright'] == null ? '' : ', copyright moved out of author'}',
    );
  }

  // Printed-style capitals on every hymn's opening word.
  if (verses.isNotEmpty && verses.first.isNotEmpty) {
    verses.first[0] = _uncapFirstWord(verses.first.first);
  }
  h['title'] = _uncapFirstWord(h['title'] as String);

  // Editor notes inside verses.
  for (var vi = 0; vi < verses.length; vi++) {
    final verse = verses[vi];
    for (var li = 0; li < verse.length; li++) {
      final optV = _optionalVerse.firstMatch(verse[li]);
      final optC = _optionalChorus.firstMatch(verse[li]);
      if (optV == null && optC == null) continue;
      final tail = verse.sublist(li + 1);
      verses[vi] = verse.sublist(0, li);
      if (optV != null) {
        (h['optionalVerses'] as List).add({
          'label': optV.group(1),
          'lines': tail,
        });
      } else {
        (h['alternateChoruses'] as List).add({
          'label': _sentenceCase(optC!.group(1)!),
          'lines': tail,
        });
      }
      report.add('#$id moved "${verse[li].trim()}" out of verse ${vi + 1}');
      break;
    }
  }

  // Bracketed note heading the chorus.
  final chorus = h['chorus'] as List<String>;
  if (chorus.isNotEmpty) {
    final note = _bracketNote.firstMatch(chorus.first);
    if (note != null) {
      final text = note.group(1)!;
      chorus.removeAt(0);
      if (RegExp(r'\bchorus\b', caseSensitive: false).hasMatch(text) &&
          !RegExp(r'\bonly\b', caseSensitive: false).hasMatch(text)) {
        (h['alternateChoruses'] as List).add({
          'label': text,
          'lines': List<String>.of(chorus),
        });
        chorus.clear();
      } else {
        (h['notes'] as List).add(text);
      }
      report.add('#$id chorus note "$text" moved out of the lyrics');
    }
  }
}

void _applyOverride(
  Map<String, dynamic> h,
  Map<String, dynamic> patch,
  List<String> report,
) {
  final id = h['id'];
  for (final key in const ['title', 'author', 'meter', 'tuneName']) {
    if (patch[key] is String) h[key] = patch[key];
  }
  final verses = h['verses'] as List<List<String>>;
  final verseOverrides = patch['verses'];
  if (verseOverrides is Map) {
    verseOverrides.forEach((k, v) {
      final i = int.parse('$k');
      final lines = [for (final l in v as List) '$l'];
      if (i < verses.length) {
        verses[i] = lines;
      } else {
        verses.add(lines);
      }
    });
  }
  if (patch['chorus'] is List) {
    h['chorus'] = [for (final l in patch['chorus'] as List) '$l'];
  }
  final replacements = patch['replaceText'];
  if (replacements is List) {
    List<String> apply(List<String> lines) {
      var text = lines.join('\n');
      for (final pair in replacements) {
        final find = '${(pair as List)[0]}';
        if (!text.contains(find)) continue;
        text = text.replaceAll(find, '${pair[1]}');
      }
      return text
          .split('\n')
          .map((l) => l.trimRight())
          .where((l) => l.trim().isNotEmpty)
          .toList();
    }

    final before = jsonEncode([verses, h['chorus']]);
    for (var i = 0; i < verses.length; i++) {
      verses[i] = apply(verses[i]);
    }
    h['chorus'] = apply(h['chorus'] as List<String>);
    if (before == jsonEncode([verses, h['chorus']])) {
      report.add('#$id ERROR replaceText matched nothing');
    }
  }
  if (patch['notes'] is List) {
    (h['notes'] as List<String>).addAll(<String>[
      for (final n in patch['notes'] as List) '$n',
    ]);
  }
  for (final key in const ['optionalVerses', 'alternateChoruses']) {
    if (patch[key] is List) {
      (h[key] as List).addAll([
        for (final p in patch[key] as List) Map<String, dynamic>.from(p as Map),
      ]);
    }
  }
  if (patch['copyright'] is String) h['copyright'] = patch['copyright'];
  if (patch['rightsStatus'] is String) {
    h['rightsStatus'] = patch['rightsStatus'];
  }
}

/// Book-wide rights rules from `<id>.meta.json` (`rightsRules`), for whole
/// groups of hymns: `authorContains` / `copyrightContains` select hymns,
/// `rightsStatus` / `copyright` are applied unless an override already set
/// them. Overrides win, so one hymn can still be handled differently.
void _applyRightsRules(Map<String, dynamic> h, Object? rules) {
  if (rules is! List) return;
  for (final rule in rules.whereType<Map>()) {
    final author = rule['authorContains'] as String?;
    final copyrightNeedle = rule['copyrightContains'] as String?;
    final matches =
        (author != null && (h['author'] as String).contains(author)) ||
        (copyrightNeedle != null &&
            ((h['copyright'] as String?) ?? '').contains(copyrightNeedle));
    if (!matches) continue;
    if (rule['rightsStatus'] is String) {
      h['rightsStatus'] ??= rule['rightsStatus'];
    }
    if (rule['copyright'] is String) h['copyright'] ??= rule['copyright'];
  }
}

/// Tidies the title and drops empty optional keys so the asset stays small.
void _finish(Map<String, dynamic> h) {
  h['title'] = (h['title'] as String)
      .trim()
      .replaceAll(RegExp(r'^["“]|["”]$'), '')
      .replaceAll(RegExp(r'[,;:]+$'), '')
      .trim();
  for (final key in const [
    'notes',
    'optionalVerses',
    'alternateChoruses',
    'addedChorus',
  ]) {
    if ((h[key] as List).isEmpty) h.remove(key);
  }
  if (!h.containsKey('addedChorus')) h['addedChorus'] = <String>[];
}

void _validate(Map<String, dynamic> h, List<String> report) {
  final id = h['id'];
  if ((h['title'] as String).isEmpty) report.add('#$id ERROR empty title');
  final verses = h['verses'] as List<List<String>>;
  final chorus = h['chorus'] as List<String>;
  if (verses.isEmpty && chorus.isEmpty) report.add('#$id ERROR no lyrics');
  for (var i = 0; i < verses.length; i++) {
    if (verses[i].isEmpty) report.add('#$id ERROR verse ${i + 1} is empty');
  }
  final all = [...verses.expand((v) => v), ...chorus];
  for (final line in all) {
    if (_suspicious.hasMatch(line)) {
      report.add('#$id check line: "$line"');
    }
  }
  if (_meterLike.hasMatch(h['title'] as String)) {
    report.add('#$id title looks like a meter: "${h['title']}"');
  }
}

/// The printed book capitalizes a hymn's first word ("HOW deep the
/// Father's love", "I DO not know", "A LITTLE while"); "How deep…" reads
/// and searches better.
/// After "O ", divine names ("O LORD my God") keep their capitals.
String _uncapFirstWord(String line) {
  final match = RegExp(
    r"^([“‘'\x22]?(?:[AIO] )?)([A-Z][A-Z’']+)(\b.*)$",
  ).firstMatch(line);
  if (match == null) return line;
  final word = match.group(2)!;
  final lead = match.group(1)!;
  // "O LORD my God" is a real small-caps divine name; at the very start of
  // a hymn ("GOD moves…", "LORD, e'en to death…") it's just printed caps.
  if (lead.endsWith('O ') && const {'LORD', 'GOD', 'JEHOVAH'}.contains(word)) {
    return line;
  }
  // After a leading "I "/"O " the word is mid-sentence: all lower case.
  final fixed = lead.endsWith(' ')
      ? word.toLowerCase()
      : '${word[0]}${word.substring(1).toLowerCase()}';
  return '$lead$fixed${match.group(3)}';
}

String _sentenceCase(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
