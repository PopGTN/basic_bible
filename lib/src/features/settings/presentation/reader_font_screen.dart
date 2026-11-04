import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/settings/application/view_models/reader_font_view_models.dart';
import 'package:basic_bible/src/features/settings/data/device_font_scanner.dart';
import 'package:basic_bible/src/features/settings/data/reader_font_repository.dart';
import 'package:basic_bible/src/features/settings/models/reader_font.dart';
import 'package:basic_bible/src/platform/runtime_support.dart';
import 'package:basic_bible/src/services/font_size_service.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page for choosing the font used for Bible text: the default, fonts that
/// ship with the app, fonts the user imports, and fonts installed on the
/// device.
///
/// Performance notes (a phone can list a few hundred system fonts):
/// - Every font row has the same fixed height (prototype extent + forced
///   strut), so a row's font finishing loading never changes the scroll
///   extent. Variable heights here caused scroll-offset corrections and
///   "RenderViewport exceeded its maximum number of layout cycles".
/// - The slivers are flat (no SliverMainAxisGroup) for the same reason.
/// - Row previews load only once scrolling stops, so scrolling itself does no
///   font work; the rows then visible are loaded as one batch (see
///   [ReaderFontLoader.loadForPreview]), and rows that scrolled away are
///   skipped (see [_FontTile]).
/// - Typing in the search box only rebuilds the installed-fonts list.
/// The name to show for [font]; the default's name is localized.
String readerFontDisplayName(ReaderFont font, AppLocalizations l10n) =>
    font.isDefault ? l10n.readerFontSystemDefault : font.name;

String _errorText(ReaderFontError error, AppLocalizations l10n) {
  final name = error.fontName ?? '';
  return switch (error.kind) {
    ReaderFontErrorKind.loadFailed => l10n.readerFontLoadFailed(name),
    ReaderFontErrorKind.unsupportedType => l10n.readerFontUnsupportedType,
    ReaderFontErrorKind.notAFont => l10n.readerFontNotAFont,
    ReaderFontErrorKind.unloadable => l10n.readerFontUnloadable,
    ReaderFontErrorKind.importFailed => l10n.readerFontImportFailed,
    ReaderFontErrorKind.deleteFailed => l10n.readerFontDeleteFailed(name),
  };
}

class ReaderFontScreen extends ConsumerStatefulWidget {
  const ReaderFontScreen({super.key});

  @override
  ConsumerState<ReaderFontScreen> createState() => _ReaderFontScreenState();
}

class _ReaderFontScreenState extends ConsumerState<ReaderFontScreen> {
  final _query = ValueNotifier<String>('');

  /// True while the list is being scrolled; rows wait for it to settle before
  /// loading their previews.
  final _scrolling = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _query.dispose();
    _scrolling.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification) {
      _scrolling.value = true;
    } else if (notification is ScrollEndNotification) {
      _scrolling.value = false;
    }
    return false;
  }

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  /// Shows the controller's current error, or [fallback] if it has none.
  void _toastError(String fallback) {
    final error = ref.read(readerFontProvider).error;
    _toast(error == null ? fallback : _errorText(error, _l10n));
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _select(ReaderFont font) async {
    final ok = await ref.read(readerFontProvider.notifier).select(font);
    if (!ok && mounted) {
      _toastError(_l10n.readerFontLoadFailed(font.name));
    }
  }

  Future<void> _import() async {
    final controller = ref.read(readerFontProvider.notifier);
    try {
      // Android's picker maps extensions to MIME types, and fonts often have
      // none — so don't filter on mobile; the file's contents are validated.
      final file = await openFile(
        acceptedTypeGroups: isMobileRuntime
            ? const []
            : [
                XTypeGroup(
                  label: _l10n.readerFontFileTypeLabel,
                  extensions: const ['ttf', 'otf'],
                ),
              ],
      );
      if (file == null) return;
      final font = await controller.import(
        fileName: file.name,
        bytes: await file.readAsBytes(),
      );
      if (!mounted) return;
      if (font == null) {
        _toastError(_l10n.readerFontImportFailed);
        return;
      }
      await _select(font);
      if (mounted) _toast(_l10n.readerFontImported(font.name));
    } catch (e) {
      // The file picker or reading the picked file failed.
      debugPrint('ReaderFontScreen: import failed: $e');
      if (mounted) _toast(_l10n.readerFontImportFailed);
    }
  }

  Future<void> _confirmDelete(ReaderFont font) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.readerFontRemoveTitle(font.name)),
        content: Text(_l10n.readerFontRemoveDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_l10n.removeAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(readerFontProvider.notifier).deleteImported(font);
    if (mounted && ref.read(readerFontProvider).error != null) {
      _toastError(_l10n.readerFontDeleteFailed(font.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readerFontProvider);
    final selectedId = state.selected.id;
    final l10n = _l10n;

    // See [_withoutFallbackFonts]: keeps the re-layout after each batch of
    // previews from searching the system fonts for every text style.
    return Theme(
      data: _withoutFallbackFonts(Theme.of(context)),
      child: Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text(l10n.readerFontTitle),
        ),
        body: _ScrollActivity(
          scrolling: _scrolling,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: CustomScrollView(
              // Build (and so preview) rows well past the bottom edge while
              // the list is at rest, so scrolling down reaches rows whose
              // fonts are already loaded instead of loading on arrival.
              cacheExtent: 1200,
              slivers: [
                SliverToBoxAdapter(child: _PreviewCard(font: state.selected)),
                // Always 4px tall so showing/hiding progress never shifts the list.
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 4,
                    child: state.busy ? const LinearProgressIndicator() : null,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SectionHeader(l10n.readerFontSectionDefault),
                ),
                _fontList(
                  count: 1,
                  tile: (_) => _FontTile(
                    key: const ValueKey('default'),
                    font: ReaderFont.systemDefault,
                    selected: state.selected.isDefault,
                    onTap: () => _select(ReaderFont.systemDefault),
                  ),
                ),
                ..._bundledSection(selectedId),
                if (ReaderFontRepository.supportsFontFiles)
                  ..._importedSection(state),
                SliverToBoxAdapter(
                  child: _SectionHeader(l10n.readerFontSectionInstalled),
                ),
                ..._deviceSection(selectedId),
                const SliverSafeArea(
                  top: false,
                  sliver: SliverToBoxAdapter(child: SizedBox(height: 32)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _bundledSection(String selectedId) {
    final fonts = ref.watch(bundledReaderFontsProvider).value ?? const [];
    if (fonts.isEmpty) return const [];
    return [
      SliverToBoxAdapter(child: _SectionHeader(_l10n.readerFontSectionBundled)),
      _fontList(
        count: fonts.length,
        tile: (i) => _FontTile(
          key: ValueKey(fonts[i].id),
          font: fonts[i],
          selected: fonts[i].id == selectedId,
          preview: true,
          onTap: () => _select(fonts[i]),
        ),
      ),
    ];
  }

  List<Widget> _importedSection(ReaderFontState state) {
    return [
      SliverToBoxAdapter(
        child: _SectionHeader(_l10n.readerFontSectionImported),
      ),
      _fontList(
        count: state.imported.length,
        tile: (i) {
          final font = state.imported[i];
          return _FontTile(
            key: ValueKey(font.id),
            font: font,
            selected: font.id == state.selected.id,
            preview: true,
            onTap: () => _select(font),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: _l10n.readerFontRemoveTooltip,
              onPressed: () => _confirmDelete(font),
            ),
          );
        },
      ),
      SliverToBoxAdapter(
        child: ListTile(
          leading: const Icon(Icons.file_upload_outlined),
          title: Text(_l10n.readerFontImportAction),
          subtitle: Text(_l10n.readerFontImportHint),
          enabled: !state.busy,
          onTap: _import,
        ),
      ),
    ];
  }

  List<Widget> _deviceSection(String selectedId) {
    if (!DeviceFontScanner.isSupported) {
      return [
        SliverToBoxAdapter(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(_l10n.readerFontScanUnsupported),
            subtitle: Text(_l10n.readerFontScanUnsupportedHint),
          ),
        ),
      ];
    }
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: _l10n.readerFontSearchHint,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            textInputAction: TextInputAction.search,
            onChanged: (value) => _query.value = value.trim(),
          ),
        ),
      ),
      _DeviceFontList(
        query: _query,
        tileBuilder: (font) => _FontTile(
          key: ValueKey(font.id),
          font: font,
          selected: font.id == selectedId,
          preview: true,
          onTap: () => _select(font),
        ),
      ),
    ];
  }
}

/// The installed-fonts list. Its own widget so typing in the search box
/// rebuilds only this sliver, not the whole page.
class _DeviceFontList extends ConsumerWidget {
  const _DeviceFontList({required this.query, required this.tileBuilder});

  final ValueListenable<String> query;
  final _FontTile Function(ReaderFont font) tileBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fonts = ref.watch(deviceReaderFontsProvider);
    final all = fonts.value;
    if (all == null) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return ValueListenableBuilder<String>(
      valueListenable: query,
      builder: (context, rawQuery, _) {
        final q = rawQuery.toLowerCase();
        final matches = q.isEmpty
            ? all
            : [
                for (final f in all)
                  if (f.searchKey.contains(q)) f,
              ];
        if (matches.isEmpty) {
          final l10n = AppLocalizations.of(context)!;
          return SliverToBoxAdapter(
            child: ListTile(
              title: Text(
                q.isEmpty
                    ? l10n.readerFontNoInstalled
                    : l10n.readerFontNoMatches(rawQuery),
              ),
            ),
          );
        }
        return _fontList(
          count: matches.length,
          tile: (i) => tileBuilder(matches[i].font),
        );
      },
    );
  }
}

/// Hands the page's "is the list scrolling" flag to the rows. The notifier
/// itself never changes, so dependents never rebuild; rows listen to it.
class _ScrollActivity extends InheritedWidget {
  const _ScrollActivity({required this.scrolling, required super.child});

  final ValueListenable<bool> scrolling;

  static ValueListenable<bool>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ScrollActivity>()?.scrolling;

  @override
  bool updateShouldNotify(_ScrollActivity old) => old.scrolling != scrolling;
}

/// The theme without its fallback font families.
///
/// Registering a font (every batch of previews) clears the engine's font
/// lookup cache, so on the next frame every text style on screen resolves its
/// families again. Families that aren't loaded into the app — on Linux the
/// theme's Roboto plus five fallbacks (Ubuntu, Cantarell, DejaVu Sans, …) —
/// are looked up through fontconfig, which is slow with thousands of fonts
/// installed: measured ~250 ms per batch. Without the fallback list each
/// style needs one lookup; characters a font lacks still fall back per glyph.
ThemeData _withoutFallbackFonts(ThemeData theme) {
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamilyFallback: const <String>[]),
    primaryTextTheme: theme.primaryTextTheme.apply(
      fontFamilyFallback: const <String>[],
    ),
  );
}

/// A fixed-extent list of font rows. The prototype gives every row the same
/// height (and still respects the user's text scale).
Widget _fontList({
  required int count,
  required _FontTile Function(int index) tile,
}) {
  return SliverPrototypeExtentList.builder(
    prototypeItem: const _FontTilePrototype(),
    itemCount: count,
    itemBuilder: (context, i) => tile(i),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Sample text in the currently selected font at the reader's font size.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.font});

  final ReaderFont font;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ValueListenableBuilder<double>(
          valueListenable: FontSizeService.instance.notifier,
          builder: (context, size, _) {
            final l10n = AppLocalizations.of(context)!;
            final style = theme.textTheme.bodyLarge?.copyWith(
              fontFamily: font.family,
              fontSize: size,
              height: 1.5,
            );
            // Forced strut: line height depends only on the size, not on the
            // font's own metrics, so switching fonts doesn't resize the card
            // (and shift every list row below it).
            final strut = StrutStyle(
              fontSize: size,
              height: 1.5,
              forceStrutHeight: true,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  readerFontDisplayName(font, l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.readerFontPreviewSample,
                  style: style,
                  strutStyle: strut,
                ),
                const SizedBox(height: 6),
                Text(
                  'ἐν ἀρχῇ ἦν ὁ λόγος · בְּרֵאשִׁית בָּרָא',
                  style: style,
                  strutStyle: strut,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Measures the row height for [SliverPrototypeExtentList]; laid out once,
/// never painted. Must match [_FontTile]'s structure.
class _FontTilePrototype extends StatelessWidget {
  const _FontTilePrototype();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Text content is irrelevant: only the row's height is measured.
      title: Text('Font', maxLines: 1, strutStyle: _FontTile.strut(context)),
      trailing: const IconButton(onPressed: null, icon: Icon(Icons.circle)),
    );
  }
}

class _FontTile extends ConsumerStatefulWidget {
  const _FontTile({
    super.key,
    required this.font,
    required this.selected,
    required this.onTap,
    this.preview = false,
    this.trailing,
  });

  final ReaderFont font;
  final bool selected;
  final VoidCallback onTap;

  /// Draw the name in the font itself, when the repository allows it (size
  /// limit and preview memory budget).
  final bool preview;
  final Widget? trailing;

  /// Fixed line height for the title, independent of the font's metrics.
  static StrutStyle strut(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium;
    return StrutStyle(
      fontSize: style?.fontSize ?? 16,
      height: style?.height ?? 1.5,
      forceStrutHeight: true,
    );
  }

  @override
  ConsumerState<_FontTile> createState() => _FontTileState();
}

class _FontTileState extends ConsumerState<_FontTile> {
  bool _ready = false;
  bool _loadScheduled = false;
  ValueListenable<bool>? _scrolling;

  @override
  void initState() {
    super.initState();
    // Already-loaded fonts render in their own font on the first frame.
    _ready = _hasPreview(widget.font);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scrolling = _ScrollActivity.maybeOf(context);
    if (scrolling != _scrolling) {
      _scrolling?.removeListener(_onScrollActivity);
      _scrolling = scrolling;
    }
    _scheduleLoad();
  }

  @override
  void didUpdateWidget(_FontTile old) {
    super.didUpdateWidget(old);
    if (old.font != widget.font || old.preview != widget.preview) {
      _ready = _hasPreview(widget.font);
      _scheduleLoad();
    }
  }

  @override
  void dispose() {
    _scrolling?.removeListener(_onScrollActivity);
    super.dispose();
  }

  bool _hasPreview(ReaderFont font) =>
      widget.preview && ref.read(readerFontLoaderProvider).hasPreview(font);

  bool _wants(ReaderFont font) => mounted && widget.font == font;

  /// Loads the preview after the current frame, but never while the list is
  /// scrolling: rows that only fly past never touch the disk, and the rows
  /// visible when scrolling stops are loaded together as one batch.
  void _scheduleLoad() {
    if (_ready || _loadScheduled || !widget.preview) return;
    if (!ref.read(readerFontLoaderProvider).canPreview(widget.font)) return;
    _loadScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) => _loadWhenIdle());
  }

  void _loadWhenIdle() {
    if (!mounted) return;
    final scrolling = _scrolling;
    if (scrolling != null && scrolling.value) {
      scrolling.removeListener(_onScrollActivity);
      scrolling.addListener(_onScrollActivity);
      return;
    }
    _loadScheduled = false;
    _load();
  }

  void _onScrollActivity() {
    if (_scrolling?.value ?? false) return;
    _scrolling?.removeListener(_onScrollActivity);
    _loadWhenIdle();
  }

  Future<void> _load() async {
    final font = widget.font;
    final ok = await ref
        .read(readerFontLoaderProvider)
        .loadForPreview(font, stillWanted: () => _wants(font));
    if (ok && _wants(font) && !_ready) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        readerFontDisplayName(widget.font, AppLocalizations.of(context)!),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        strutStyle: _FontTile.strut(context),
        style: _ready
            ? theme.textTheme.titleMedium?.copyWith(
                fontFamily: widget.font.family,
                // The theme's fallback families (on Linux: Ubuntu, Cantarell,
                // DejaVu Sans, …) aren't loaded fonts, so resolving them goes
                // through fontconfig for every previewed row — the main cost
                // when thousands of fonts are installed. The row only needs
                // its own font.
                fontFamilyFallback: const <String>[],
              )
            : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.selected)
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ?widget.trailing,
        ],
      ),
      selected: widget.selected,
      onTap: widget.onTap,
    );
  }
}
