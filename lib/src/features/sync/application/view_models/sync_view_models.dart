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
  SyncController(this._auth, this._repository, this._prefs)
    : super(const SyncState()) {
    _restore();
  }

  static const _lastSyncKey = 'notesLastSyncedAt';

  final GoogleAuthService _auth;
  final NotesSyncRepository _repository;
  final SharedPreferences _prefs;

  Future<void> _restore() async {
    final lastRaw = _prefs.getString(_lastSyncKey);
    final last = lastRaw == null ? null : DateTime.tryParse(lastRaw);
    if (last != null && mounted) {
      state = state.copyWith(lastSyncedAt: last);
    }
    if (!_auth.isSupported || !_auth.isConfigured) return;
    try {
      final account = await _auth.restoreExistingSignIn();
      if (account != null && mounted) {
        state = state.copyWith(account: account);
        await triggerSync();
      }
    } catch (_) {
      // Silent restore is best-effort; the user can sign in manually.
    }
  }

  Future<void> signIn() async {
    if (state.isSyncing) return;
    try {
      final account = await _auth.signIn();
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
    if (!mounted) return;
    state = state.copyWith(
      clearAccount: true,
      clearError: true,
      phase: SyncPhase.idle,
    );
  }

  Future<void> triggerSync() async {
    if (!state.isSignedIn || state.isSyncing) return;
    state = state.copyWith(phase: SyncPhase.syncing, clearError: true);
    try {
      await _repository.syncOnce();
      final now = DateTime.now();
      await _prefs.setString(_lastSyncKey, now.toIso8601String());
      if (!mounted) return;
      state = state.copyWith(phase: SyncPhase.idle, lastSyncedAt: now);
    } on GoogleSignInRequiredException catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        clearAccount: true,
        phase: SyncPhase.error,
        errorMessage: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        phase: SyncPhase.error,
        errorMessage: 'Sync failed: $e',
      );
    }
  }
}

final syncControllerProvider = StateNotifierProvider<SyncController, SyncState>(
  (ref) {
    return SyncController(
      ref.watch(googleAuthServiceProvider),
      ref.watch(notesSyncRepositoryProvider),
      ref.read(sharedPreferencesProvider),
    );
  },
);
