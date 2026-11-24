import 'dart:convert';

import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hymn_layout.dart';

/// Display preferences for the hymn view, saved on device.
class HymnSettings extends Equatable {
  const HymnSettings({
    this.chorusPlacement = ChorusPlacement.afterFirstVerse,
    this.fontScale = 1.0,
    this.showDetails = true,
    this.showOptionalParts = true,
  });

  final ChorusPlacement chorusPlacement;

  /// Multiplies the base lyric size; clamped to [minFontScale]–[maxFontScale].
  final double fontScale;

  /// Author, meter and tune under the title.
  final bool showDetails;

  /// Optional verses and alternate choruses.
  final bool showOptionalParts;

  static const minFontScale = 0.8;
  static const maxFontScale = 2.4;

  HymnSettings copyWith({
    ChorusPlacement? chorusPlacement,
    double? fontScale,
    bool? showDetails,
    bool? showOptionalParts,
  }) => HymnSettings(
    chorusPlacement: chorusPlacement ?? this.chorusPlacement,
    fontScale: (fontScale ?? this.fontScale).clamp(minFontScale, maxFontScale),
    showDetails: showDetails ?? this.showDetails,
    showOptionalParts: showOptionalParts ?? this.showOptionalParts,
  );

  Map<String, dynamic> toJson() => {
    'chorusPlacement': chorusPlacement.name,
    'fontScale': fontScale,
    'showDetails': showDetails,
    'showOptionalParts': showOptionalParts,
  };

  factory HymnSettings.fromJson(Map<String, dynamic> json) => HymnSettings(
    chorusPlacement: ChorusPlacement.values.firstWhere(
      (p) => p.name == json['chorusPlacement'],
      orElse: () => ChorusPlacement.afterFirstVerse,
    ),
    fontScale: ((json['fontScale'] as num?)?.toDouble() ?? 1.0).clamp(
      minFontScale,
      maxFontScale,
    ),
    showDetails: json['showDetails'] != false,
    showOptionalParts: json['showOptionalParts'] != false,
  );

  @override
  List<Object?> get props => [
    chorusPlacement,
    fontScale,
    showDetails,
    showOptionalParts,
  ];
}

final hymnSettingsProvider =
    NotifierProvider<HymnSettingsNotifier, HymnSettings>(
      HymnSettingsNotifier.new,
    );

class HymnSettingsNotifier extends Notifier<HymnSettings> {
  static const _key = 'hymn_settings_v1';

  @override
  HymnSettings build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_key);
    if (raw == null) return const HymnSettings();
    try {
      return HymnSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const HymnSettings();
    }
  }

  void update(HymnSettings Function(HymnSettings current) change) {
    state = change(state);
    ref
        .read(sharedPreferencesProvider)
        .setString(_key, jsonEncode(state.toJson()));
  }
}
