import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/view_models/hymnal_view_models.dart';
import '../models/hymnal.dart';

/// Quick book switcher opened from the Hymns tab title.
Future<void> showHymnalPicker(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const _HymnalPicker(),
    );

class _HymnalPicker extends ConsumerWidget {
  const _HymnalPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final books = ref.watch(hymnalListProvider).value ?? const <HymnalInfo>[];
    final selected =
        ref.watch(currentHymnalProvider).value?.info.id ??
        ref.watch(selectedHymnalIdProvider);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final book in books)
              ListTile(
                leading: Icon(
                  book.id == selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(book.title),
                subtitle: Text(hymnalSourceLabel(t, book)),
                onTap: () {
                  ref.read(selectedHymnalIdProvider.notifier).select(book.id);
                  Navigator.of(context).pop();
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.library_add_outlined),
              title: Text(t.hymnalManageBooks),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/home/hymns/library');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// "Included with the app" / "Imported" / "Downloaded", plus hymn count.
String hymnalSourceLabel(AppLocalizations t, HymnalInfo info) {
  final source = switch (info.sourceKind) {
    HymnalSourceKind.bundled => t.hymnalSourceBundledShort,
    HymnalSourceKind.imported => t.hymnalSourceImportedShort,
    HymnalSourceKind.repository => t.hymnalSourceRepositoryShort,
  };
  return info.hymnCount > 0
      ? '$source · ${t.hymnCount(info.hymnCount)}'
      : source;
}
