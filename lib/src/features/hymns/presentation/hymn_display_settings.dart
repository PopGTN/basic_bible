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
        ListTile(
          title: Text(t.hymnTextSize),
          subtitle: Slider(
            value: settings.fontScale,
            min: HymnSettings.minFontScale,
            max: HymnSettings.maxFontScale,
            divisions: 16,
            label: '${(settings.fontScale * 100).round()}%',
            onChanged: (value) =>
                notifier.update((s) => s.copyWith(fontScale: value)),
          ),
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
