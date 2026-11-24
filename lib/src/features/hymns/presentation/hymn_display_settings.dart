import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/view_models/hymn_settings_view_model.dart';
import '../data/hymn_layout.dart';

/// Opens [HymnDisplaySettingsPanel] as a bottom sheet from the hymn view.
Future<void> showHymnDisplaySettings(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      // A light scrim, so the hymn behind stays readable while adjusting.
      barrierColor: Colors.black12,
      builder: (_) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: HymnDisplaySettingsPanel(),
        ),
      ),
    );

/// Hymn display options. Shown both in the hymn view's sheet and in the
/// app Settings screen, so they're findable from either place.
class HymnDisplaySettingsPanel extends ConsumerWidget {
  const HymnDisplaySettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final settings = ref.watch(hymnSettingsProvider);
    final notifier = ref.read(hymnSettingsProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TextSizeControl(
          settings: settings,
          onChanged: (scale) =>
              notifier.update((s) => s.copyWith(fontScale: scale)),
        ),
        SwitchListTile(
          title: Text(t.hymnChorusEveryVerse),
          subtitle: Text(t.hymnChorusEveryVerseSubtitle),
          value: settings.chorusPlacement == ChorusPlacement.afterEveryVerse,
          onChanged: (on) => notifier.update(
            (s) => s.copyWith(
              chorusPlacement: on
                  ? ChorusPlacement.afterEveryVerse
                  : ChorusPlacement.afterFirstVerse,
            ),
          ),
        ),
        SwitchListTile(
          title: Text(t.hymnShowDetails),
          value: settings.showDetails,
          onChanged: (on) =>
              notifier.update((s) => s.copyWith(showDetails: on)),
        ),
        SwitchListTile(
          title: Text(t.hymnShowOptional),
          value: settings.showOptionalParts,
          onChanged: (on) =>
              notifier.update((s) => s.copyWith(showOptionalParts: on)),
        ),
      ],
    );
  }
}

/// Text size: smaller/larger buttons, a slider, the current size, and a
/// preview at exactly the size the hymn view will use.
class _TextSizeControl extends StatelessWidget {
  const _TextSizeControl({required this.settings, required this.onChanged});

  final HymnSettings settings;
  final ValueChanged<double> onChanged;

  static const _min = HymnSettings.minFontScale;
  static const _max = HymnSettings.maxFontScale;
  static const _step = HymnSettings.fontScaleStep;

  // Snap to the step so repeated taps don't drift (0.1 + 0.2 != 0.3).
  double _snap(double v) =>
      ((v / _step).round() * _step).clamp(_min, _max).toDouble();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final scale = settings.fontScale;
    final percent = '${(scale * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.hymnTextSize, style: theme.textTheme.titleMedium),
              ),
              Text(
                percent,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                tooltip: t.hymnTextSmaller,
                onPressed: scale > _min + 0.001
                    ? () => onChanged(_snap(scale - _step))
                    : null,
                icon: const Text('A', style: TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: Slider(
                  value: scale,
                  min: _min,
                  max: _max,
                  divisions: ((_max - _min) / _step).round(),
                  label: percent,
                  semanticFormatterCallback: (_) => percent,
                  onChanged: (v) => onChanged(_snap(v)),
                ),
              ),
              IconButton(
                tooltip: t.hymnTextLarger,
                onPressed: scale < _max - 0.001
                    ? () => onChanged(_snap(scale + _step))
                    : null,
                icon: const Text('A', style: TextStyle(fontSize: 28)),
              ),
            ],
          ),
          // Live preview at the real hymn size. Capped in height so very
          // large sizes don't push the other settings off screen.
          Container(
            constraints: const BoxConstraints(maxHeight: 170),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRect(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      // Public domain (John Newton, 1779).
                      'How sweet the name of Jesus sounds\n'
                      'In a believer\'s ear!',
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontSize: settings.lyricSize,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
