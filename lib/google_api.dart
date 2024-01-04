import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart' as sign_in;

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleDriveHelper {
  static sign_in.GoogleSignInAccount? _account;
  static GoogleAuthClient? _authenticatedClient;

  static Future<void> signIn() async {
    final googleSignIn =
        sign_in.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    _account = await googleSignIn.signIn();
    final authHeaders = await _account?.authHeaders;
    _authenticatedClient = GoogleAuthClient(authHeaders!);
  }
  
  static Future<void> downloadImage(
      String fileId, String destinationPath, String rename) async {
    if (_account == null || _authenticatedClient == null) {
      await signIn();
    }

    try {
      var driveApi = drive.DriveApi(_authenticatedClient!);
      // 確認目標夾子存在
      await Directory(destinationPath).create(recursive: true);

      // 下載檔案
      final drive.Media fileData = await driveApi.files.get(fileId,
          downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      final Stream<List<int>> stream = fileData.stream;
      final localFile = File('$destinationPath/$rename');
      final IOSink sink = localFile.openWrite();

      await for (final chunk in stream) {
        sink.add(chunk);
      }
      await sink.close();
    } finally {
      // 不要在這裡關閉 authenticatedClient
    }
  }
}
