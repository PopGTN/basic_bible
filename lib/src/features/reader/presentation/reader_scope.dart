import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps the builder of a screen or sheet that a reader opens, so it keeps
/// that reader's provider scope.
///
/// Routes are built under the navigator, outside the reader's own subtree. In
/// split view (#84) the second reader runs in its own scope (its own
/// translation and location), so a note editor, reference picker or verse
/// sheet it opens would otherwise act on the main reader. Pass the context
/// that opens the route; harmless for the main reader.
WidgetBuilder inReaderScope(BuildContext context, WidgetBuilder builder) {
  final container = ProviderScope.containerOf(context, listen: false);
  return (_) => UncontrolledProviderScope(
    container: container,
    child: Builder(builder: builder),
  );
}
