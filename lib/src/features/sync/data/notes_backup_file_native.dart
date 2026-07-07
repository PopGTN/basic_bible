import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../platform/runtime_support.dart';
import 'notes_backup_sqlite.dart';

const _typeGroup = XTypeGroup(
  label: 'Notes backup (SQLite)',
  extensions: ['sqlite', 'db'],
);

Future<bool> writeNotesBackupFile({
  required List<UserAnnotation> notes,
  required String fileName,
}) async {
  if (isMobileRuntime) {
    final tempDir = await getTemporaryDirectory();
    final path = p.join(tempDir.path, fileName);
    buildNotesBackupDatabase(path, notes);
    await Share.shareXFiles([XFile(path)], subject: 'Bible notes backup');
    return true;
  }

  final location = await getSaveLocation(
    suggestedName: fileName,
    acceptedTypeGroups: [_typeGroup],
  );
  if (location == null) return false;
  buildNotesBackupDatabase(location.path, notes);
  return true;
}

Future<List<UserAnnotation>?> readNotesBackupFile() async {
  final picked = await openFile(acceptedTypeGroups: [_typeGroup]);
  if (picked == null) return null;
  return parseNotesBackupDatabase(picked.path);
}
