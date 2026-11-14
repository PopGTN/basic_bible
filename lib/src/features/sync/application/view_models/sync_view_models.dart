import 'package:basic_bible/src/features/sync/application/auto_sync_scheduler.dart';
import 'package:basic_bible/src/features/sync/data/google_auth_service.dart';
import 'package:basic_bible/src/features/sync/data/google_drive_notes_api.dart';
import 'package:basic_bible/src/features/sync/data/notes_sync_repository.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return createGoogleAuthService();
});

final driveNotesApiProvider = Provider<DriveNotesApi>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return GoogleDriveNotesApi(client);
});

final notesSyncRepositoryProvider = Provider<NotesSyncRepository>((ref) {
  return NotesSyncRepository(
    db: ref.watch(appDatabaseProvider),
    auth: ref.watch(googleAuthServiceProvider),
    api: ref.watch(driveNotesApiProvider),
  );
});

enum SyncPhase { idle, syncing, error }

enum SyncMode { automatic, manual }

class SyncModeController extends StateNotifier<SyncMode> {
  SyncModeController(this._prefs) : super(_readFromPrefs(_prefs));

  static const _syncModeKey = 'sync_mode';

  final SharedPreferences _prefs;

  static SyncMode _readFromPrefs(SharedPreferences prefs) {
    switch (prefs.getString(_syncModeKey)) {
      case 'manual':
        return SyncMode.manual;
      case 'automatic':
      default:
        return SyncMode.automatic;
    }
  }

  Future<void> setMode(SyncMode mode) async {
    state = mode;
    await _prefs.setString(_syncModeKey, mode.name);
  }
}

class SyncState {
  const SyncState({
    this.account,
    this.phase = SyncPhase.idle,
    this.errorMessage,
    this.lastSyncedAt,
  });

  final GoogleAccount? account;
  final SyncPhase phase;
  final String? errorMessage;
  final DateTime? lastSyncedAt;

  bool get isSignedIn => account != null;
  bool get isSyncing => phase == SyncPhase.syncing;

  SyncState copyWith({
    GoogleAccount? account,
    bool clearAccount = false,
    SyncPhase? phase,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastSyncedAt,
  }) {
    return SyncState(
      account: clearAccount ? null : (account ?? this.account),
      phase: phase ?? this.phase,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

class SyncController extends StateNotifier<SyncState> {
  SyncController(
    this._auth,
    this._repository,
    this._prefs, {
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now,
       super(const SyncState()) {
    _restore();
  }

  static const _lastSyncKey = 'notesLastSyncedAt';
  static const _signedInKey = 'googleSyncSignedIn';
  static const _dirtyKey = 'notesSyncDirty';

  /// Auto syncs (resume / network restored) are skipped when the last
  /// successful sync is this recent and nothing changed locally since.
  static const autoSyncMinInterval = Duration(minutes: 5);
  static const _initialBackoff = Duration(minutes: 1);
  static const _maxBackoff = Duration(minutes: 30);

  final GoogleAuthService _auth;
  final NotesSyncRepository _repository;
  final SharedPreferences _prefs;
  final DateTime Function() _now;

  bool _pendingResync = false;
  Duration? _backoff;
  DateTime? _nextAutoAttemptAt;

  bool get _hasLocalChanges => _prefs.getBool(_dirtyKey) ?? true;

  Future<void> _restore() async {
    final lastRaw = _prefs.getString(_lastSyncKey);
    final last = lastRaw == null ? null : DateTime.tryParse(lastRaw);
    if (last != null && mounted) {
      state = state.copyWith(lastSyncedAt: last);
    }
    // Never touch the auth stack for users who haven't opted into sync:
    // on Android a lightweight-auth attempt can surface a credential sheet
    // and wakes Play Services on every cold start.
    // Installs that signed in before this flag existed have a last-sync
    // timestamp instead.
    final wasSignedIn =
        _prefs.getBool(_signedInKey) ?? _prefs.containsKey(_lastSyncKey);
    if (!wasSignedIn) return;
    if (!_auth.isSupported || !_auth.isConfigured) return;
    try {
      final account = await _auth.restoreExistingSignIn();
      if (!mounted) return;
      if (account == null) {
        await _prefs.setBool(_signedInKey, false);
        return;
      }
      state = state.copyWith(account: account);
      await requestAutoSync();
    } catch (_) {
      // Silent restore is best-effort; the user can sign in manually.
    }
  }

  /// Records that notes changed locally so the next auto sync isn't
  /// throttled away.
  void markLocalChange() {
    if (_prefs.getBool(_dirtyKey) == true) return;
    _prefs.setBool(_dirtyKey, true);
  }

  Future<void> signIn() async {
    if (state.isSyncing) return;
    try {
      final account = await _auth.signIn();
      await _prefs.setBool(_signedInKey, true);
      if (!mounted) return;
      state = state.copyWith(account: account, clearError: true);
      await triggerSync();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        phase: SyncPhase.error,
        errorMessage: 'Sign-in failed: $e',
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _prefs.setBool(_signedInKey, false);
    _resetBackoff();
    if (!mounted) return;
    state = state.copyWith(
      clearAccount: true,
      clearError: true,
      phase: SyncPhase.idle,
    );
  }

  /// Entry point for automatic triggers (note edits, resume, network
  /// restored). Applies the min-interval throttle and failure backoff so
  /// frequent app switching or flaky networks don't keep the radio awake.
  Future<void> requestAutoSync() async {
    if (!state.isSignedIn) return;
    final now = _now();
    final nextAttempt = _nextAutoAttemptAt;
    if (nextAttempt != null && now.isBefore(nextAttempt)) return;
    final last = state.lastSyncedAt;
    if (!_hasLocalChanges &&
        last != null &&
        now.difference(last) < autoSyncMinInterval) {
      return;
    }
    await triggerSync();
  }

  /// Runs a sync now (also used by "Sync now"; bypasses throttling). If a
  /// sync is already running, one more pass runs right after it so changes
  /// made mid-sync aren't left behind.
  Future<void> triggerSync() async {
    if (!state.isSignedIn) return;
    if (state.isSyncing) {
      _pendingResync = true;
      return;
    }
    state = state.copyWith(phase: SyncPhase.syncing, clearError: true);
    do {
      _pendingResync = false;
      final ok = await _runOnePass();
      if (!ok || !mounted) return;
    } while (_pendingResync);
    state = state.copyWith(phase: SyncPhase.idle);
  }

  /// Returns false when the pass failed (state already set to error).
  Future<bool> _runOnePass() async {
    // Clear before reading local notes: edits made during the pass set it
    // again and are picked up by the next sync.
    await _prefs.setBool(_dirtyKey, false);
    try {
      await _repository.syncOnce();
      final now = _now();
      await _prefs.setString(_lastSyncKey, now.toIso8601String());
      _resetBackoff();
      if (mounted) state = state.copyWith(lastSyncedAt: now);
      return true;
    } on GoogleSignInRequiredException catch (e) {
      await _prefs.setBool(_dirtyKey, true);
      await _prefs.setBool(_signedInKey, false);
      if (mounted) {
        state = state.copyWith(
          clearAccount: true,
          phase: SyncPhase.error,
          errorMessage: e.message,
        );
      }
      return false;
    } catch (e) {
      await _prefs.setBool(_dirtyKey, true);
      _registerFailure();
      if (mounted) {
        state = state.copyWith(
          phase: SyncPhase.error,
          errorMessage: 'Sync failed: $e',
        );
      }
      return false;
    }
  }

  void _registerFailure() {
    final previous = _backoff;
    final next = previous == null ? _initialBackoff : previous * 2;
    _backoff = next > _maxBackoff ? _maxBackoff : next;
    _nextAutoAttemptAt = _now().add(_backoff!);
  }

  void _resetBackoff() {
    _backoff = null;
    _nextAutoAttemptAt = null;
  }
}

final syncModeProvider = StateNotifierProvider<SyncModeController, SyncMode>(
  (ref) => SyncModeController(ref.read(sharedPreferencesProvider)),
);

final syncControllerProvider = StateNotifierProvider<SyncController, SyncState>(
  (ref) {
    return SyncController(
      ref.watch(googleAuthServiceProvider),
      ref.watch(notesSyncRepositoryProvider),
      ref.read(sharedPreferencesProvider),
    );
  },
);

/// Single, app-wide debounced auto-sync trigger. Mode and throttling are
/// checked when it fires, so switching modes never rebuilds dependents.
final autoSyncSchedulerProvider = Provider<AutoSyncScheduler>((ref) {
  final scheduler = AutoSyncScheduler(
    trigger: () async {
      if (ref.read(syncModeProvider) == SyncMode.manual) return;
      await ref.read(syncControllerProvider.notifier).requestAutoSync();
    },
  );
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

/// Handed to the annotation repository: every local note write marks the
/// sync state dirty and schedules a debounced auto sync.
final noteChangeSyncTriggerProvider = Provider<NoteSyncTrigger>((ref) {
  return _NoteChangeSyncTrigger(ref);
});

class _NoteChangeSyncTrigger implements NoteSyncTrigger {
  _NoteChangeSyncTrigger(this._ref);

  final Ref _ref;

  @override
  void schedule() {
    _ref.read(syncControllerProvider.notifier).markLocalChange();
    _ref.read(autoSyncSchedulerProvider).schedule();
  }
}
