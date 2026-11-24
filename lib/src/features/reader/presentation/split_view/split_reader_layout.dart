import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/library/presentation/versions_screen.dart';
import 'package:basic_bible/src/features/reader/application/view_models/split_view_view_models.dart';
import 'package:basic_bible/src/features/reader/presentation/reader_scope.dart';
import 'package:basic_bible/src/features/reader/presentation/translation_chip.dart';
import 'package:basic_bible/src/platform/runtime_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Where the side-by-side divider is, in global x; null when the panes are
/// stacked or split view is off. Lets the app bar line the second pane's
/// translation chip up with it.
final splitDividerXProvider = StateProvider<double?>((ref) => null);

/// Wraps the main reader and, when split view is on (#84), adds a second
/// reader: side by side when there's room, stacked on narrow screens.
///
/// [secondary] is the same reader widget as [primary], so both panes have
/// every reader feature; it runs in [splitPaneContainerProvider]'s scope with
/// its own translation, location and selection.
class SplitReaderLayout extends ConsumerWidget {
  const SplitReaderLayout({
    super.key,
    required this.primary,
    required this.secondary,
  });

  /// The main reader. Give it a GlobalKey so turning split view on/off moves
  /// it instead of rebuilding it from scratch.
  final Widget primary;
  final Widget secondary;

  /// Below this width each pane would be too narrow to read side by side.
  static const double sideBySideMinWidth = 700;

  /// Whether split view is offered on a screen this size: in landscape, or
  /// when wide enough to read side by side (tablets, desktop). A phone held
  /// upright gets neither the button nor split view; rotating it upright hides
  /// split view (it stays on, and reappears in landscape). This is the only
  /// place deciding it.
  static bool isAvailable(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    return screen.width > screen.height || screen.width >= sideBySideMinWidth;
  }

  /// Split view is on and this screen allows it.
  static bool isShowing(BuildContext context, WidgetRef ref) =>
      ref.watch(splitViewEnabledProvider) && isAvailable(context);

  /// In split view on a computer (Windows/macOS/Linux app), screens a reader
  /// opens (reference picker, note editor, verse sheets) open inside that
  /// reader's half, so the other reader stays in view. On phones, tablets and
  /// the web they open full page, as without split view. Either way they act
  /// on the reader that opened them ([inReaderScope]).
  static bool get panesHaveOwnNavigators => isDesktopRuntime;

  static Widget _inOwnNavigator(Widget reader) =>
      panesHaveOwnNavigators ? _PaneNavigator(child: reader) : reader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Upright phone: hide split view but leave it on, so turning back to
    // landscape shows both readers again just as they were.
    if (!isShowing(context, ref)) return primary;
    final paneScope = ref.watch(splitPaneContainerProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= sideBySideMinWidth;
        final pane = Expanded(
          child: UncontrolledProviderScope(
            container: paneScope,
            child: _inOwnNavigator(secondary),
          ),
        );
        final main = Expanded(child: _inOwnNavigator(primary));
        // The app bar's own translation chip is the rightmost, so the main
        // reader goes on the right side by side (as in YouVersion), and on
        // top when stacked.
        return Flex(
          direction: sideBySide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: sideBySide
              // Not const: a new width must rebuild it so it re-reports.
              ? [
                  pane,
                  _ReportedDivider(layoutWidth: constraints.maxWidth),
                  main,
                ]
              : [main, const Divider(height: 1), pane],
        );
      },
    );
  }
}

/// The side-by-side divider, reporting its position to
/// [splitDividerXProvider] after each layout.
class _ReportedDivider extends ConsumerStatefulWidget {
  const _ReportedDivider({required this.layoutWidth});

  /// Only here so a resize rebuilds this (and so re-reports the position).
  final double layoutWidth;

  @override
  ConsumerState<_ReportedDivider> createState() => _ReportedDividerState();
}

class _ReportedDividerState extends ConsumerState<_ReportedDivider> {
  // Read up front, not lazily: if the divider is removed before its first
  // post-frame callback, a lazy read would first happen in dispose(), where
  // `ref` may no longer be used.
  late final StateController<double?> _x;

  @override
  void initState() {
    super.initState();
    _x = ref.read(splitDividerXProvider.notifier);
  }

  @override
  void dispose() {
    // Not during the tree update that removed us.
    Future.microtask(() {
      if (_x.mounted) _x.state = null;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check mounted first: findRenderObject asserts on a disposed element.
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final x = box.localToGlobal(Offset.zero).dx;
      if (_x.state != x) _x.state = x;
    });
    return const VerticalDivider(width: 1);
  }
}

/// A split-view reader's own navigator (see
/// [SplitReaderLayout.panesHaveOwnNavigators]).
class _PaneNavigator extends StatefulWidget {
  const _PaneNavigator({required this.child});

  final Widget child;

  @override
  State<_PaneNavigator> createState() => _PaneNavigatorState();
}

class _PaneNavigatorState extends State<_PaneNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  // The route below is built once; this hands it each new [widget.child]
  // (e.g. isSmallDevice changing on a window resize).
  late final _child = ValueNotifier<Widget>(widget.child);

  @override
  void didUpdateWidget(_PaneNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _child.value = widget.child;
  }

  @override
  void dispose() {
    _child.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (context) => Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ValueListenableBuilder(
              valueListenable: _child,
              builder: (context, child, _) => child,
            ),
          ),
        ),
      ),
    );
  }
}

/// The second pane's translation chip for the app bar; nothing while split
/// view is off. Side by side it sits just left of the divider, above its pane
/// (as [alignToDivider], in the app bar's `flexibleSpace`); stacked it sits
/// among the actions. Opens the same Versions screen,
/// but in the pane's scope, so choosing, downloading or deleting a
/// translation there acts on the pane.
class SplitPaneTranslationChip extends ConsumerWidget {
  const SplitPaneTranslationChip({super.key, this.alignToDivider = false});

  final bool alignToDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dividerX = ref.watch(splitDividerXProvider);
    if (!SplitReaderLayout.isShowing(context, ref) ||
        alignToDivider != (dividerX != null)) {
      return const SizedBox.shrink();
    }
    final paneScope = ref.watch(splitPaneContainerProvider);
    final chip = UncontrolledProviderScope(
      container: paneScope,
      child: TranslationChip(
        tooltip: AppLocalizations.of(context)!.paneTranslationTooltip,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => UncontrolledProviderScope(
              container: paneScope,
              child: const VersionsScreen(),
            ),
          ),
        ),
      ),
    );
    if (dividerX == null) return chip;
    // The app bar spans the screen from its left edge, so the divider's
    // global x is its x here too.
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.bottomRight,
        child: SizedBox(
          height: kToolbarHeight,
          child: Padding(
            padding: EdgeInsets.only(
              right: (constraints.maxWidth - dividerX + 8).clamp(
                0.0,
                constraints.maxWidth,
              ),
            ),
            child: Center(widthFactor: 1, child: chip),
          ),
        ),
      ),
    );
  }
}
