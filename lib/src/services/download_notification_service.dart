import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/settings/application/view_models/language_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// System notifications for translation downloads (#55).
///
/// One notification per translation: a progress bar while bytes arrive
/// (indeterminate while the file is parsed/installed), then "downloaded" or
/// "failed". Behind an interface so the wiring is testable without the
/// platform plugin.
abstract class DownloadNotifications {
  /// [fraction] 0..1 or null (indeterminate); [installing] once all bytes
  /// are in.
  Future<void> showProgress(
    String translationId,
    String name,
    double? fraction, {
    bool installing = false,
  });
  Future<void> showFinished(
    String translationId,
    String name, {
    required bool success,
  });
}

final downloadNotificationsProvider = Provider<DownloadNotifications>((ref) {
  // flutter_local_notifications 20.x has no web implementation.
  if (kIsWeb) return const _NoDownloadNotifications();
  // Read the language at show time so a change in Settings applies to the
  // next notification without rebuilding this provider.
  return LocalDownloadNotifications(
    strings: () => _stringsFor(ref.read(languageProvider)),
  );
});

class _NoDownloadNotifications implements DownloadNotifications {
  const _NoDownloadNotifications();

  @override
  Future<void> showProgress(
    String translationId,
    String name,
    double? fraction, {
    bool installing = false,
  }) async {}

  @override
  Future<void> showFinished(
    String translationId,
    String name, {
    required bool success,
  }) async {}
}

class LocalDownloadNotifications implements DownloadNotifications {
  LocalDownloadNotifications({
    FlutterLocalNotificationsPlugin? plugin,
    AppLocalizations Function()? strings,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _strings = strings ?? (() => _stringsFor('en'));

  final FlutterLocalNotificationsPlugin _plugin;
  final AppLocalizations Function() _strings;
  Future<bool>? _ready;

  static const _channelId = 'translation_downloads';

  /// Initialises once and asks for permission on first use (Android 13+,
  /// Apple platforms) rather than at app start. Never throws: a missing
  /// permission or plugin just means no notification.
  Future<bool> _ensureReady() => _ready ??= () async {
    try {
      await _plugin.initialize(
        settings: InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/launcher_icon'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          linux: LinuxInitializationSettings(
            defaultActionName: _strings().openAction,
          ),
          windows: WindowsInitializationSettings(
            appName: 'Basic Bible',
            appUserModelId: 'ca.joshuamc.basic_bible',
            guid: '6f1d0a35-6b1f-4d43-9f3e-2a7c0b5d9e41',
          ),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true);
      await _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true);
      return true;
    } catch (error) {
      debugPrint('[DownloadNotifications] unavailable: $error');
      return false;
    }
  }();

  /// Stable per-translation id so updates replace the same notification.
  static int _idFor(String translationId) =>
      translationId.codeUnits.fold(17, (h, c) => (h * 31 + c) & 0x7fffffff);

  @override
  Future<void> showProgress(
    String translationId,
    String name,
    double? fraction, {
    bool installing = false,
  }) async {
    if (!await _ensureReady()) return;
    final t = _strings();
    final percent = fraction == null ? 0 : (fraction * 100).round();
    final body = installing
        ? t.downloadNotificationInstalling
        : fraction == null
        ? t.downloadNotificationStarting
        : '$percent%';
    try {
      await _plugin.show(
        id: _idFor(translationId),
        title: t.downloadNotificationProgressTitle(name),
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            t.downloadNotificationChannelName,
            channelDescription: t.downloadNotificationChannelDescription,
            importance: Importance.low,
            priority: Priority.low,
            onlyAlertOnce: true,
            ongoing: true,
            autoCancel: false,
            showProgress: true,
            maxProgress: 100,
            progress: percent,
            indeterminate: fraction == null,
          ),
          iOS: const DarwinNotificationDetails(presentSound: false),
          macOS: const DarwinNotificationDetails(presentSound: false),
        ),
      );
    } catch (error) {
      debugPrint('[DownloadNotifications] show failed: $error');
    }
  }

  @override
  Future<void> showFinished(
    String translationId,
    String name, {
    required bool success,
  }) async {
    if (!await _ensureReady()) return;
    final t = _strings();
    try {
      await _plugin.show(
        id: _idFor(translationId),
        title: success
            ? t.downloadNotificationDoneTitle(name)
            : t.downloadNotificationFailedTitle,
        body: success
            ? t.downloadNotificationDoneBody
            : t.downloadNotificationFailedBody(name),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            t.downloadNotificationChannelName,
            channelDescription: t.downloadNotificationChannelDescription,
            importance: Importance.low,
            priority: Priority.low,
          ),
          iOS: DarwinNotificationDetails(presentSound: false),
          macOS: DarwinNotificationDetails(presentSound: false),
        ),
      );
    } catch (error) {
      debugPrint('[DownloadNotifications] show failed: $error');
    }
  }
}

/// Strings for [languageCode], falling back to English for a language the
/// app has no translation for.
AppLocalizations _stringsFor(String languageCode) {
  final locale = Locale(languageCode);
  return AppLocalizations.delegate.isSupported(locale)
      ? lookupAppLocalizations(locale)
      : lookupAppLocalizations(const Locale('en'));
}
