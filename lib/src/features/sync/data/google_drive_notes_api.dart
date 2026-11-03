import 'dart:convert';

import 'package:http/http.dart' as http;

class DriveStorageUsage {
  const DriveStorageUsage({
    required this.appDataBytes,
    required this.totalDriveBytes,
    required this.quotaBytes,
  });

  final int appDataBytes;
  final int totalDriveBytes;
  final int quotaBytes;
}

/// One note file as seen in a Drive listing — enough metadata to plan a sync
/// without downloading content.
class DriveNoteFile {
  const DriveNoteFile({
    required this.fileId,
    required this.uuid,
    required this.updatedAtMillis,
    this.isDeleted,
  });

  final String fileId;

  /// Note uuid, parsed from the file name `<uuid>.json`.
  final String uuid;

  /// The note's `updatedAt` stamped into the file's appProperties at upload
  /// time. Null for files written by app versions that didn't stamp it —
  /// those must be downloaded to compare.
  final int? updatedAtMillis;

  /// Whether the file holds a tombstone, from appProperties. Null for files
  /// written before this was stamped — those must be downloaded to know.
  final bool? isDeleted;
}

/// Interface so the sync repository can be unit-tested against a fake Drive.
abstract class DriveNotesApi {
  Future<List<DriveNoteFile>> listNoteFiles(String accessToken);
  Future<String> downloadNoteContent(String accessToken, String fileId);
  Future<DriveStorageUsage> getStorageUsage(String accessToken);
  Future<void> uploadNote({
    required String accessToken,
    required String uuid,
    required String jsonContent,
    required int updatedAtMillis,
    required bool isDeleted,
    String? existingFileId,
  });

  /// Updates only a file's appProperties (no content upload) — used to stamp
  /// legacy files so they never need downloading again.
  Future<void> updateNoteProperties({
    required String accessToken,
    required String fileId,
    required int updatedAtMillis,
    required bool isDeleted,
  });
}

/// Thin REST wrapper over the Drive v3 files API scoped to the hidden
/// appDataFolder. Hand-rolled http, consistent with the rest of the app —
/// the generated googleapis package would add megabytes for four calls.
class GoogleDriveNotesApi implements DriveNotesApi {
  GoogleDriveNotesApi(this._client);

  final http.Client _client;

  static const _filesHost = 'www.googleapis.com';

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  Never _fail(http.Response response, String action) {
    throw Exception(
      'Google Drive $action failed '
      '(HTTP ${response.statusCode}): ${response.body}',
    );
  }

  int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  @override
  Future<List<DriveNoteFile>> listNoteFiles(String accessToken) async {
    final files = <DriveNoteFile>[];
    String? pageToken;
    do {
      final response = await _client.get(
        Uri.https(_filesHost, '/drive/v3/files', {
          'spaces': 'appDataFolder',
          'fields': 'nextPageToken,files(id,name,appProperties)',
          'pageSize': '1000',
          if (pageToken != null) 'pageToken': pageToken,
        }),
        headers: _auth(accessToken),
      );
      if (response.statusCode != 200) _fail(response, 'listing');
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      for (final raw in (json['files'] as List<dynamic>? ?? const [])) {
        final file = raw as Map<String, dynamic>;
        final name = file['name'] as String? ?? '';
        if (!name.endsWith('.json')) continue; // not one of our note files
        final props = file['appProperties'] as Map<String, dynamic>?;
        files.add(
          DriveNoteFile(
            fileId: file['id'] as String,
            uuid: name.substring(0, name.length - '.json'.length),
            updatedAtMillis: int.tryParse(props?['updatedAt'] as String? ?? ''),
            isDeleted: switch (props?['deleted']) {
              '1' => true,
              '0' => false,
              _ => null,
            },
          ),
        );
      }
      pageToken = json['nextPageToken'] as String?;
    } while (pageToken != null);
    return files;
  }

  @override
  Future<DriveStorageUsage> getStorageUsage(String accessToken) async {
    final response = await _client.get(
      Uri.https(_filesHost, '/drive/v3/about', {
        'fields': 'storageQuota(usage,usageInDrive,usageInDriveAppData,limit)',
      }),
      headers: _auth(accessToken),
    );
    if (response.statusCode != 200) _fail(response, 'storage usage');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final quota = json['storageQuota'] as Map<String, dynamic>? ?? const {};
    return DriveStorageUsage(
      appDataBytes: _asInt(quota['usageInDriveAppData']),
      totalDriveBytes: _asInt(quota['usageInDrive'] ?? quota['usage']),
      quotaBytes: _asInt(quota['limit']),
    );
  }

  @override
  Future<String> downloadNoteContent(String accessToken, String fileId) async {
    final response = await _client.get(
      Uri.https(_filesHost, '/drive/v3/files/$fileId', {'alt': 'media'}),
      headers: _auth(accessToken),
    );
    if (response.statusCode != 200) _fail(response, 'download');
    return utf8.decode(response.bodyBytes);
  }

  @override
  Future<void> uploadNote({
    required String accessToken,
    required String uuid,
    required String jsonContent,
    required int updatedAtMillis,
    required bool isDeleted,
    String? existingFileId,
  }) async {
    final isUpdate = existingFileId != null;
    final metadata = <String, dynamic>{
      if (!isUpdate) 'name': '$uuid.json',
      if (!isUpdate) 'parents': ['appDataFolder'],
      'appProperties': _appProperties(updatedAtMillis, isDeleted),
    };

    const boundary = 'basic_bible_note_sync';
    final body = utf8.encode(
      '--$boundary\r\n'
      'Content-Type: application/json; charset=UTF-8\r\n\r\n'
      '${jsonEncode(metadata)}\r\n'
      '--$boundary\r\n'
      'Content-Type: application/json\r\n\r\n'
      '$jsonContent\r\n'
      '--$boundary--',
    );
    final uri = Uri.https(
      _filesHost,
      isUpdate
          ? '/upload/drive/v3/files/$existingFileId'
          : '/upload/drive/v3/files',
      {'uploadType': 'multipart'},
    );
    final request = http.Request(isUpdate ? 'PATCH' : 'POST', uri)
      ..headers.addAll({
        ..._auth(accessToken),
        'Content-Type': 'multipart/related; boundary=$boundary',
      })
      ..bodyBytes = body;

    final response = await http.Response.fromStream(
      await _client.send(request),
    );
    if (response.statusCode != 200) _fail(response, 'upload');
  }

  @override
  Future<void> updateNoteProperties({
    required String accessToken,
    required String fileId,
    required int updatedAtMillis,
    required bool isDeleted,
  }) async {
    final response = await _client.patch(
      Uri.https(_filesHost, '/drive/v3/files/$fileId', {'fields': 'id'}),
      headers: {
        ..._auth(accessToken),
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'appProperties': _appProperties(updatedAtMillis, isDeleted),
      }),
    );
    if (response.statusCode != 200) _fail(response, 'metadata update');
  }

  static Map<String, String> _appProperties(
    int updatedAtMillis,
    bool isDeleted,
  ) => {'updatedAt': '$updatedAtMillis', 'deleted': isDeleted ? '1' : '0'};
}
