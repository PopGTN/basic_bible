import 'package:flutter_riverpod/legacy.dart';

/// ViewModel for the selected tab inside the authenticated home shell.
final homeTabIndexProvider = StateProvider<int>((ref) => 0);
