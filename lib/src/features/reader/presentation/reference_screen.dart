import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:flutter/material.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';

class ReferenceScreen extends ConsumerStatefulWidget {
  final List<BibleCrossReference> references;
  final BibleReference currentReference;

  const ReferenceScreen({
    super.key,
    required this.references,
    required this.currentReference,
  });

  @override
  ConsumerState<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends ConsumerState<ReferenceScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cross-References')),
      body: widget.references.isEmpty
          ? Center(
              child: Text(
                'No cross-references available for this verse.',
                style: theme.textTheme.bodyLarge,
              ),
            )
          : ListView.builder(
              itemCount: widget.references.length,
              itemBuilder: (context, index) {
                final reference = widget.references[index];
                return ListTile(
                  title: Text(reference.label),
                  subtitle: reference.target != null
                      ? Text(reference.target!)
                      : null,
                  onTap: () {
                    final parsedRef = parseAnyReference(
                      target: reference.target,
                      label: reference.label,
                    );
                    if (parsedRef != null) {
                      ref
                          .read(currentReferenceProvider.notifier)
                          .setReference(parsedRef);
                      Navigator.of(context).pop(); // Go back to BibleViewerTab
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Could not parse reference: ${reference.label}',
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
