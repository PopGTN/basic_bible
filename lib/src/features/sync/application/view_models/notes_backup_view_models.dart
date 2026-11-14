import 'package:basic_bible/src/features/sync/data/notes_backup_service.dart';
import 'package:basic_bible/src/services/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notesBackupServiceProvider = Provider<NotesBackupService>((ref) {
  return NotesBackupService(ref.watch(appDatabaseProvider));
});
