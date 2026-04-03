import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/services/app_database.dart';

class UserAnnotationRepository {
  UserAnnotationRepository(this._db);

  final AppDatabase _db;

  Stream<List<UserAnnotation>> watchAnnotations() {
    return _db.watchAllUserAnnotations();
  }

  Future<List<UserAnnotation>> getAnnotations() {
    return _db.getAllUserAnnotations();
  }

  Future<UserAnnotation?> getAnnotationById(int id) {
    return _db.getUserAnnotationById(id);
  }

  Future<int> saveAnnotation(UserAnnotation annotation) {
    return _db.saveUserAnnotation(annotation);
  }

  Future<void> deleteAnnotation(int id) {
    return _db.deleteUserAnnotation(id);
  }
}
