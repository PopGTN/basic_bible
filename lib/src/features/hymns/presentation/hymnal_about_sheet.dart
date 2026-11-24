import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../data/content_reporting.dart';
import '../models/hymnal.dart';
import 'report_options.dart';

/// Book details, copyright and permission text, where it came from, and a
/// way to report a copyright concern.
Future<void> showHymnalAboutSheet(BuildContext context, HymnalInfo info) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (context, controller) =>
            _AboutContent(info: info, controller: controller),
      ),
    );

class _AboutContent extends StatelessWidget {
  const _AboutContent({required this.info, required this.controller});

  final HymnalInfo info;
  final ScrollController controller;

  /// Placeholder values from an unfinished build are never shown.
  static String? _shown(String? value) =>
      value == null || value.contains('TODO_') ? null : value;

  String _source(AppLocalizations t) => switch (info.sourceKind) {
    HymnalSourceKind.bundled => t.hymnalSourceBundled,
    HymnalSourceKind.imported => t.hymnalSourceImported,
    HymnalSourceKind.repository => t.hymnalSourceRepository(
      info.repoUrl ?? info.repoId ?? '',
    ),
  };

  Future<void> _report(BuildContext context) {
    // Books from someone else's repository go to that repository's own
    // contact; everything else to the app (email or GitHub issue).
    final ownerContact = info.sourceKind == HymnalSourceKind.repository
        ? _shown(info.takedownContact)
        : null;
    return sendContentReport(
      context,
      subject: 'Copyright concern: ${info.title}',
      body: contentReportBody(
        bookTitle: info.title,
        bookId: info.id,
        source: info.repoUrl ?? info.sourceKind.name,
        publisher: _shown(info.publisher),
      ),
      ownerContact: ownerContact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final rows = <(String, String?)>[
      (
        t.hymnalPublisher,
        [
          _shown(info.publisher),
          _shown(info.publisherAddress),
        ].nonNulls.join(', '),
      ),
      (
        t.hymnalEdition,
        [_shown(info.edition), info.year?.toString()].nonNulls.join(' · '),
      ),
      (t.hymnalIsbn, _shown(info.isbn)),
      (t.hymnalCopyright, _shown(info.copyright)),
      (t.hymnalPermission, _shown(info.permissionNotice)),
      (t.hymnalSource, _source(t)),
      (t.hymnCountLabel, '${info.hymnCount}'),
    ].where((row) => row.$2 != null && row.$2!.isNotEmpty);

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        Text(info.title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        for (final (label, value) in rows) ...[
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SelectableText(value!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
        ],
        if (info.sourceKind != HymnalSourceKind.bundled) ...[
          const SizedBox(height: 4),
          Text(
            t.hymnalThirdPartyNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          icon: const Icon(Icons.flag_outlined),
          label: Text(t.hymnReportConcern),
          onPressed: () => _report(context),
        ),
      ],
    );
  }
}
