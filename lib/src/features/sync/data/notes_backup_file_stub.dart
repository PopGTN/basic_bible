import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';

Future<bool> writeNotesBackupFile({
  required List<UserAnnotation> notes,
  required String fileName,
}) {
  throw UnsupportedError('Notes export is not supported on this platform.');
}

Future<List<UserAnnotation>?> readNotesBackupFile() {
  throw UnsupportedError('Notes import is not supported on this platform.');
}
