import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/sync/application/auto_sync_scheduler.dart';
import 'package:basic_bible/src/services/app_database.dart';

class UserAnnotationRepository {
  UserAnnotationRepository(
    this._db, [
    this._syncTrigger = const NoOpNoteSyncTrigger(),
  ]);

  final AppDatabase _db;
  final NoteSyncTrigger _syncTrigger;

  Stream<List<UserAnnotation>> watchAnnotations() {
    return _db.watchAllUserAnnotations();
  }

  Future<List<UserAnnotation>> getAnnotations() {
    return _db.getAllUserAnnotations();
  }

  Future<UserAnnotation?> getAnnotationById(int id) {
    return _db.getUserAnnotationById(id);
  }

  Future<int> saveAnnotation(UserAnnotation annotation) async {
    final id = await _db.saveUserAnnotation(annotation);
    _syncTrigger.schedule();
    return id;
  }

  Future<void> deleteAnnotation(int id) async {
    await _db.deleteUserAnnotation(id);
    _syncTrigger.schedule();
  }
}
