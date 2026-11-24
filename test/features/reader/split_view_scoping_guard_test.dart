// Guards split view (#84) against a silent bug: a provider derived from the
// pane's own state (translation, location, selection) but missing from
// `_derivedReaderProviders` in split_view_view_models.dart makes the pane show
// the MAIN reader's data (riverpod 3.0.3 does not re-scope providers the
// parent already created). Riverpod forces such providers to declare
// `dependencies:`, so this reads those declarations from the source.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Overridden directly in `splitPaneOverrides`.
const _paneRoots = {
  'currentTranslationProvider',
  'currentReferenceProvider',
  'visibleReaderReferenceProvider',
  'selectedVersesProvider',
  'highlightPaletteExpandedProvider',
};

/// Derived, but deliberately not scoped to the pane.
const _rootOnly = {
  'readerLinkOpenerProvider', // deep links always open in the main reader
  'bibleSearchResultsProvider', // a family: riverpod scopes those itself
  'splitPaneContainerProvider', // split view's own machinery
  'splitViewEnabledProvider',
};

final _providerDef = RegExp(r'^final (\w+Provider)\s*=', multiLine: true);
final _dependencies = RegExp(r'dependencies:\s*\[([^\]]*)\]');
final _name = RegExp(r'\w+Provider');

void main() {
  test('every provider derived from pane state is scoped to the pane', () {
    // provider -> the providers its `dependencies:` names.
    final dependsOn = <String, Set<String>>{};
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      final defs = _providerDef.allMatches(source).toList();
      for (var i = 0; i < defs.length; i++) {
        final end = i + 1 < defs.length ? defs[i + 1].start : source.length;
        final body = source.substring(defs[i].end, end);
        final deps = _dependencies.firstMatch(body);
        if (deps == null) continue;
        dependsOn[defs[i].group(1)!] = {
          for (final m in _name.allMatches(deps.group(1)!)) m.group(0)!,
        };
      }
    }

    final derived = <String>{};
    for (var grew = true; grew;) {
      grew = false;
      dependsOn.forEach((provider, deps) {
        if (!_paneRoots.contains(provider) &&
            deps.any((d) => _paneRoots.contains(d) || derived.contains(d))) {
          grew = derived.add(provider) || grew;
        }
      });
    }

    final splitSource = File(
      'lib/src/features/reader/application/view_models/split_view_view_models.dart',
    ).readAsStringSync();
    final listStart = splitSource.indexOf(
      '[',
      splitSource.indexOf('_derivedReaderProviders = '),
    );
    expect(listStart, isNot(-1), reason: '_derivedReaderProviders not found');
    final listed = {
      for (final m in _name.allMatches(
        splitSource.substring(listStart, splitSource.indexOf('];', listStart)),
      ))
        m.group(0)!,
    };

    expect(
      derived.difference(_rootOnly).difference(listed),
      isEmpty,
      reason:
          'Add these to _derivedReaderProviders (or to _rootOnly here if they '
          'must stay global), or the split-view pane shows the main reader\'s '
          'data.',
    );
    expect(derived, containsAll(listed), reason: 'stale entries in the list');
  });
}
