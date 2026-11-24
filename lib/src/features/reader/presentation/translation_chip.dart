import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The "🌐 KJV" pill naming the translation a reader shows. Reads
/// [currentTranslationProvider] from its own scope, so the same widget labels
/// the main reader (in the app bar) and the split-view pane.
class TranslationChip extends ConsumerWidget {
  const TranslationChip({super.key, required this.onPressed, this.tooltip});

  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final chip = Card(
      color: colors.secondary,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, color: colors.onSecondary),
              const SizedBox(width: 6),
              Text(
                ref.watch(currentTranslationProvider).toUpperCase(),
                style: TextStyle(color: colors.onSecondary),
              ),
            ],
          ),
        ),
      ),
    );
    return tooltip == null ? chip : Tooltip(message: tooltip, child: chip);
  }
}
