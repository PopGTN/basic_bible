import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/library/presentation/versions_screen_actions.dart';
import 'package:basic_bible/src/features/library/presentation/versions_screen_widgets.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VersionsScreen extends ConsumerStatefulWidget {
  const VersionsScreen({super.key});

  @override
  ConsumerState<VersionsScreen> createState() => _VersionsScreenState();
}

class _VersionsScreenState extends ConsumerState<VersionsScreen>
    with VersionsScreenActions {
  String? _selectedLanguage;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
      _selectedLanguage = null;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final translationsAsync = ref.watch(availableTranslationsProvider);
    final currentTranslationId = ref.watch(currentTranslationProvider);
    final loadingIds = ref.watch(translationDownloadsProvider);

    return Scaffold(
      appBar: _isSearching ? _buildSearchBar(t) : _buildNormalBar(t),
      body: translationsAsync.when(
        data: (translations) =>
            _buildList(context, translations, currentTranslationId, loadingIds),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(t.unableToLoadTranslations(error.toString())),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App bar builders
  // ---------------------------------------------------------------------------

  AppBar _buildSearchBar(AppLocalizations t) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _stopSearch,
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: t.searchTranslationsHint,
          border: InputBorder.none,
        ),
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

  AppBar _buildNormalBar(AppLocalizations t) {
    return AppBar(
      leading: const AppBackButton(),
      title: Text(t.versionsTitle),
      actions: [
        IconButton(
          onPressed: _startSearch,
          icon: const Icon(Icons.search),
          tooltip: t.searchTranslationsTooltip,
        ),
        PopupMenuButton<_MenuAction>(
          onSelected: (action) {
            switch (action) {
              case _MenuAction.importBibleFile:
                importBibleFile(context);
              case _MenuAction.clearTranslationCache:
                clearTranslationCache(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _MenuAction.importBibleFile,
              child: Row(
                children: [
                  const Icon(Icons.upload_file),
                  const SizedBox(width: 8),
                  Text(t.importBibleFileAction),
                ],
              ),
            ),
            PopupMenuItem(
              value: _MenuAction.clearTranslationCache,
              child: Row(
                children: [
                  const Icon(Icons.cleaning_services_outlined),
                  const SizedBox(width: 8),
                  Text(t.clearTranslationCacheAction),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // List builder
  // ---------------------------------------------------------------------------

  Widget _buildList(
    BuildContext context,
    List<BibleTranslation> translations,
    String currentTranslationId,
    Set<String> loadingIds,
  ) {
    final languages = _uniqueLanguages(translations);

    var filtered = _selectedLanguage == null
        ? translations
        : translations
              .where((tr) => tr.effectiveLanguageName == _selectedLanguage)
              .toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (tr) =>
                tr.id.toLowerCase().contains(q) ||
                tr.name.toLowerCase().contains(q),
          )
          .toList();
    }

    final downloaded =
        filtered
            .where(
              (tr) =>
                  tr.availability == BibleTranslationAvailability.bundled ||
                  tr.availability == BibleTranslationAvailability.downloaded ||
                  tr.availability == BibleTranslationAvailability.imported,
            )
            .toList()
          ..sort(_translationComparator);

    final available =
        filtered
            .where(
              (tr) =>
                  tr.availability ==
                      BibleTranslationAvailability.downloadable ||
                  tr.availability == BibleTranslationAvailability.session,
            )
            .toList()
          ..sort(_translationComparator);

    return ListView(
      children: [
        if (!_isSearching)
          LanguageFilterRow(
            languages: languages,
            selected: _selectedLanguage,
            onSelected: (lang) => setState(() => _selectedLanguage = lang),
          ),
        if (downloaded.isNotEmpty) ...[
          TranslationSectionHeader(
            label: AppLocalizations.of(context)!.downloadedSectionHeader,
          ),
          for (final tr in downloaded)
            TranslationTile(
              translation: tr,
              isSelected: tr.id == currentTranslationId,
              isLoading: loadingIds.contains(tr.id),
              onTap: () => selectTranslation(
                context,
                tr.id,
                persist: tr.sourceType != BibleSourceType.session,
              ),
              onOpenForSession:
                  tr.availability == BibleTranslationAvailability.downloadable
                  ? () => openTranslationForSession(context, tr)
                  : null,
              onRemoveDownloaded:
                  tr.sourceType == BibleSourceType.download && tr.isLocal
                  ? () => removeDownloadedTranslation(
                      context,
                      translation: tr,
                      currentTranslationId: currentTranslationId,
                      allTranslations: translations,
                    )
                  : null,
              onDeleteImported: tr.sourceType == BibleSourceType.import
                  ? () => deleteImportedTranslation(
                      context,
                      translation: tr,
                      currentTranslationId: currentTranslationId,
                      allTranslations: translations,
                    )
                  : null,
            ),
        ],
        if (available.isNotEmpty) ...[
          TranslationSectionHeader(
            label: AppLocalizations.of(context)!.availableSectionHeader,
          ),
          for (final tr in available)
            TranslationTile(
              translation: tr,
              isSelected: tr.id == currentTranslationId,
              isLoading: loadingIds.contains(tr.id),
              onTap: tr.availability == BibleTranslationAvailability.session
                  ? () => selectTranslation(context, tr.id, persist: false)
                  : null,
              onOpenForSession:
                  tr.availability == BibleTranslationAvailability.downloadable
                  ? () => openTranslationForSession(context, tr)
                  : null,
              onDownload:
                  tr.availability == BibleTranslationAvailability.downloadable
                  ? () => downloadTranslation(context, tr)
                  : null,
              onRemoveDownloaded: null,
              onDeleteImported: null,
            ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<String> _uniqueLanguages(List<BibleTranslation> translations) {
    final seen = <String>{};
    final result = <String>[];
    for (final t in translations) {
      if (seen.add(t.effectiveLanguageName))
        result.add(t.effectiveLanguageName);
    }
    result.sort();
    return result;
  }

  int _translationComparator(BibleTranslation a, BibleTranslation b) {
    final lang = a.effectiveLanguageName.compareTo(b.effectiveLanguageName);
    if (lang != 0) return lang;
    final order = a.displayOrder.compareTo(b.displayOrder);
    if (order != 0) return order;
    return a.name.compareTo(b.name);
  }
}

enum _MenuAction { importBibleFile, clearTranslationCache }
