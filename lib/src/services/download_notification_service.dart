import 'package:flutter/foundation.dart';
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
  Future<void> showFinished(String translationId, String name, {required bool success});
}

final downloadNotificationsProvider = Provider<DownloadNotifications>((ref) {
  // flutter_local_notifications 20.x has no web implementation.
  return kIsWeb ? const _NoDownloadNotifications() : LocalDownloadNotifications();
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
  Future<void> showFinished(String translationId, String name, {required bool success}) async {}
}

class LocalDownloadNotifications implements DownloadNotifications {
  LocalDownloadNotifications({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<bool>? _ready;

  static const _channelId = 'translation_downloads';
  static const _channelName = 'Bible downloads';
  static const _channelDescription = 'Progress of Bible translation downloads';

  /// Initialises once and asks for permission on first use (Android 13+,
  /// Apple platforms) rather than at app start. Never throws: a missing
  /// permission or plugin just means no notification.
  Future<bool> _ensureReady() => _ready ??= () async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
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
          linux: LinuxInitializationSettings(defaultActionName: 'Open'),
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
    final percent = fraction == null ? 0 : (fraction * 100).round();
    final body = installing
        ? 'Installing…'
        : fraction == null
        ? 'Starting…'
        : '$percent%';
    try {
      await _plugin.show(
        id: _idFor(translationId),
        title: 'Downloading $name',
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
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
  Future<void> showFinished(String translationId, String name, {required bool success}) async {
    if (!await _ensureReady()) return;
    try {
      await _plugin.show(
        id: _idFor(translationId),
        title: success ? '$name downloaded' : 'Download failed',
        body: success ? 'Ready to read offline.' : 'Could not download $name.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
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
