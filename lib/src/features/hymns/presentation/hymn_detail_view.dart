import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../application/view_models/hymn_settings_view_model.dart';
import '../application/view_models/hymnal_view_models.dart';
import '../data/hymn_layout.dart';
import '../models/hymn.dart';
import '../models/hymnal.dart';
import 'hymn_display_settings.dart';
import 'hymn_print.dart';
import 'hymnal_about_sheet.dart';

/// One hymn, with its actions. Swipe left/right (or the arrows) to move
/// through the *current result list*, so a search narrows what you page
/// through.
class HymnDetailView extends ConsumerWidget {
  const HymnDetailView({
    super.key,
    required this.hymnal,
    required this.hymn,
    required this.showBackButton,
  });

  final Hymnal hymnal;
  final Hymn hymn;
  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final settings = ref.watch(hymnSettingsProvider);
    final results = ref.watch(hymnResultsProvider) ?? const <Hymn>[];
    final position = results.indexWhere((h) => h.number == hymn.number);
    final previous = position > 0 ? results[position - 1] : null;
    final next = position >= 0 && position < results.length - 1
        ? results[position + 1]
        : null;
    final isFavorite = ref
        .watch(hymnFavoritesProvider(hymnal.info.id))
        .contains(hymn.number);
    void open(Hymn? target) {
      if (target != null) {
        ref.read(openHymnNumberProvider.notifier).open(target.number);
      }
    }

    String plainText() => formatHymnAsText(
      hymn,
      hymnal.info,
      placement: settings.chorusPlacement,
      labels: HymnTextLabels(
        chorus: t.hymnChorusLabel,
        optionalChorus: t.hymnOptionalChorus,
        optionalVerse: t.hymnOptionalVerse,
      ),
    );

    return Column(
      children: [
        _ActionBar(
          showBackButton: showBackButton,
          isFavorite: isFavorite,
          onBack: () => ref.read(openHymnNumberProvider.notifier).close(),
          onPrevious: previous == null ? null : () => open(previous),
          onNext: next == null ? null : () => open(next),
          onFavorite: () => ref
              .read(hymnFavoritesProvider(hymnal.info.id).notifier)
              .toggle(hymn.number),
          onCopy: () async {
            await Clipboard.setData(ClipboardData(text: plainText()));
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(t.hymnCopied)));
            }
          },
          onShare: () => Share.share(plainText(), subject: hymn.title),
          onPrint: () => printHymn(
            hymn: hymn,
            book: hymnal.info,
            placement: settings.chorusPlacement,
            labels: HymnTextLabels(
              chorus: t.hymnChorusLabel,
              optionalChorus: t.hymnOptionalChorus,
              optionalVerse: t.hymnOptionalVerse,
            ),
          ),
          onDisplay: () => showHymnDisplaySettings(context),
          onAbout: () => showHymnalAboutSheet(context, hymnal.info),
        ),
        const Divider(height: 1),
        Expanded(
          child: GestureDetector(
            // Horizontal swipe pages through results; vertical drags still
            // scroll and long-press still selects text.
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -300) open(next);
              if (velocity > 300) open(previous);
            },
            child: SelectionArea(
              child: _HymnBody(
                hymnal: hymnal,
                hymn: hymn,
                settings: settings,
                lyricSize: settings.lyricSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HymnBody extends StatelessWidget {
  const _HymnBody({
    required this.hymnal,
    required this.hymn,
    required this.settings,
    required this.lyricSize,
  });

  final Hymnal hymnal;
  final Hymn hymn;
  final HymnSettings settings;
  final double lyricSize;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final lyricStyle = theme.textTheme.bodyLarge!.copyWith(
      fontSize: lyricSize,
      height: 1.45,
    );
    final blocks = layoutHymn(
      hymn,
      placement: settings.chorusPlacement,
      includeOptional: settings.showOptionalParts,
    );
    final details = [
      if (hymn.author.isNotEmpty) hymn.author,
      if (hymn.meter.isNotEmpty) hymn.meter,
      if (hymn.tuneName.isNotEmpty) hymn.tuneName,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${hymn.number}. ${hymn.title}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize:
                        (theme.textTheme.headlineSmall?.fontSize ?? 24) *
                        settings.fontScale.clamp(1.0, 1.6),
                  ),
                ),
                if (settings.showDetails && details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    details.join(' · '),
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                ],
                for (final note in hymn.notes) ...[
                  const SizedBox(height: 6),
                  Text(
                    note,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: muted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                for (final block in blocks)
                  _Block(
                    block: block,
                    style: lyricStyle,
                    muted: muted,
                    chorusLabel: t.hymnChorusLabel,
                    optionalChorusLabel: t.hymnOptionalChorus,
                    optionalVerseLabel: t.hymnOptionalVerse,
                  ),
                const SizedBox(height: 24),
                for (final line in hymnCreditLines(hymn, hymnal.info))
                  Text(
                    line,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.block,
    required this.style,
    required this.muted,
    required this.chorusLabel,
    required this.optionalChorusLabel,
    required this.optionalVerseLabel,
  });

  final HymnBlock block;
  final TextStyle style;
  final Color muted;
  final String chorusLabel;
  final String optionalChorusLabel;
  final String optionalVerseLabel;

  @override
  Widget build(BuildContext context) {
    final isChorus = block.kind == HymnBlockKind.chorus;
    final label = switch (block.kind) {
      HymnBlockKind.verse => '${block.verseNumber}',
      HymnBlockKind.chorus => chorusLabel,
      HymnBlockKind.optionalVerse => [
        optionalVerseLabel,
        ?block.label,
      ].join(' — '),
      HymnBlockKind.alternateChorus => block.label ?? optionalChorusLabel,
    };
    final textStyle = block.isOptional
        ? style.copyWith(color: muted)
        : isChorus
        ? style.copyWith(fontStyle: FontStyle.italic)
        : style;
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: muted,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 14,
        left: isChorus || block.isOptional ? 24 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 2),
          Text(block.lines.join('\n'), style: textStyle),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.showBackButton,
    required this.isFavorite,
    required this.onBack,
    required this.onPrevious,
    required this.onNext,
    required this.onFavorite,
    required this.onCopy,
    required this.onShare,
    required this.onPrint,
    required this.onDisplay,
    required this.onAbout,
  });

  final bool showBackButton;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onFavorite;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final VoidCallback onDisplay;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: const BackButtonIcon(),
              onPressed: onBack,
            ),
          IconButton(
            tooltip: t.hymnPrevious,
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          IconButton(
            tooltip: t.hymnNext,
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
          const Spacer(),
          IconButton(
            tooltip: isFavorite ? t.hymnRemoveFavorite : t.hymnAddFavorite,
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber.shade700 : null,
            ),
            onPressed: onFavorite,
          ),
          IconButton(
            tooltip: t.copyAction,
            icon: const Icon(Icons.copy_outlined),
            onPressed: onCopy,
          ),
          PopupMenuButton<VoidCallback>(
            tooltip: MaterialLocalizations.of(context).showMenuTooltip,
            onSelected: (action) => action(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: onShare,
                child: ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: Text(t.shareAction),
                ),
              ),
              PopupMenuItem(
                value: onPrint,
                child: ListTile(
                  leading: const Icon(Icons.print_outlined),
                  title: Text(t.hymnPrint),
                ),
              ),
              PopupMenuItem(
                value: onDisplay,
                child: ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: Text(t.hymnDisplaySettings),
                ),
              ),
              PopupMenuItem(
                value: onAbout,
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(t.hymnAboutBook),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
