// Guards the notes-screen search behavior, which mirrors VersionsScreen (the
// translation selector): tapping the search icon swaps the whole app bar for
// one whose title *is* the search field, instead of a field appearing below
// a static app bar. Replicates the exact state machine in _NotesScreenState
// (_isSearching / _startSearch / _stopSearch) since it's private and can't
// be imported from another library file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  AppBar _buildNormalAppBar() {
    return AppBar(
      title: const Text('Notes'),
      actions: [
        IconButton(
          onPressed: _startSearch,
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _stopSearch,
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
      ),
      actions: [
        if (_searchQuery.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
        body: Text('query:$_searchQuery'),
      ),
    );
  }
}

void main() {
  testWidgets(
    'search icon swaps the app bar to a focused search field, back arrow '
    'restores the normal bar and clears the query',
    (tester) async {
      await tester.pumpWidget(const _Harness());

      expect(find.text('Notes'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.testTextInput.isVisible, isTrue);
      // No clear button until there's a query.
      expect(find.byIcon(Icons.clear), findsNothing);

      await tester.enterText(find.byType(TextField), 'grace');
      await tester.pump();
      expect(find.text('query:grace'), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      expect(find.text('query:'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget, reason: 'clear only resets text, not the bar');

      // Back arrow restores the normal app bar entirely.
      await tester.enterText(find.byType(TextField), 'grace');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('query:'), findsOneWidget);

      // Reopening starts with a clean, focused field again.
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.testTextInput.isVisible, isTrue);
      expect(find.text('query:'), findsOneWidget);
    },
  );
}
