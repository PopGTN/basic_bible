import 'package:flutter/material.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_bible/src/providers/bible_provider.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';

class ReferenceScreen extends ConsumerStatefulWidget {
  final List<String> references;
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
      appBar: AppBar(
        title: const Text('Cross-References'),
      ),
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
                final refString = widget.references[index];
                return ListTile(
                  title: Text(refString),
                  onTap: () {
                    final parsedRef = parseReferenceString(refString);
                    if (parsedRef != null) {
                      ref.read(currentReferenceProvider.notifier).setReference(parsedRef);
                      Navigator.of(context).pop(); // Go back to BibleViewerTab
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not parse reference: $refString')),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
