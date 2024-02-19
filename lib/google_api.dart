import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart' as sign_in;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;


class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleHelper {
  static sign_in.GoogleSignInAccount? _account;
  static GoogleAuthClient? _authenticatedClient;

  static Future<void> signIn() async {
    final googleSignIn = sign_in.GoogleSignIn.standard(
        scopes: [drive.DriveApi.driveScope, gmail.GmailApi.gmailReadonlyScope]);
    _account = await googleSignIn.signIn();
    final authHeaders = await _account?.authHeaders;
    _authenticatedClient = GoogleAuthClient(authHeaders!);
  }

  // 獲得 Google 帳戶
  static Future<String?> getAccount() async {
    if (_account == null || _authenticatedClient == null) {
      await signIn();
    }
    if (kDebugMode) {
      print("getAccount: ${_account?.email}");
    }
    return _account?.email;
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

  static Future<void> sendEmailWithAttachment1(String to ,String contract ,String id ,String state ,File attachment) async {
    if (_account == null || _authenticatedClient == null) {
      await signIn();
    }

    try {
      final gmail.GmailApi gmailApi = gmail.GmailApi(_authenticatedClient!);

      // 將檔案轉換為Base64
      List<int> attachmentBytes = await attachment.readAsBytes();
      String base64Attachment = base64Encode(attachmentBytes);

      // 建立郵件內容
      gmail.Message message = gmail.Message();
      message.raw = base64UrlEncode(utf8.encode('From: ${_account?.email}\r\n'
          'To: $to\r\n'
          'Subject: Blofood\r\n'
          'MIME-Version: 1.0\r\n'
          'Content-Type: multipart/mixed; boundary=foo\r\n\r\n'
          '--foo\r\n'
          'Content-Type: text/plain\r\n\r\n'
          '店家合約:'+contract+'\n'
          '訂單編號:'+id+'\n'
          '$state\r\n\r\n'
          '--foo\r\n'
          'Content-Type: image/jpeg\r\n'
          'Content-Transfer-Encoding: base64\r\n'
          'Content-Disposition: attachment; filename=${path.basename(attachment.path)}\r\n\r\n'
          '$base64Attachment\r\n\r\n'
          '--foo--'));

      // 寄送郵件
      await gmailApi.users.messages.send(message, 'me');
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  static Future<void> sendEmailWithAttachment2(String to ,String contract ,String id ,String state ,File attachment) async {
    if (_account == null || _authenticatedClient == null) {
      await signIn();
    }

    try {
      final gmail.GmailApi gmailApi = gmail.GmailApi(_authenticatedClient!);

      // 將檔案轉換為Base64
      List<int> attachmentBytes = await attachment.readAsBytes();
      String base64Attachment = base64Encode(attachmentBytes);

      // 建立郵件內容
      gmail.Message message = gmail.Message();
      message.raw = base64UrlEncode(utf8.encode('From: ${_account?.email}\r\n'
          'To: $to\r\n'
          'Subject: Blofood\r\n'
          'MIME-Version: 1.0\r\n'
          'Content-Type: multipart/mixed; boundary=foo\r\n\r\n'
          '--foo\r\n'
          'Content-Type: text/plain\r\n\r\n'
          '店家合約:'+contract+'\n'
          '訂單編號:'+id+'\n'
          '$state\r\n\r\n'
          '--foo\r\n'
          'Content-Type: image/jpeg\r\n'
          'Content-Transfer-Encoding: base64\r\n'
          'Content-Disposition: attachment; filename=${path.basename(attachment.path)}\r\n\r\n'
          '$base64Attachment\r\n\r\n'
          '--foo--'));

      // 寄送郵件
      await gmailApi.users.messages.send(message, 'me');
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  static Future<void> takePhotoAndSendEmail(String to1 ,String to2  ,String contract ,String id ,String state) async {
    // 使用image_picker套件拍照
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {
      // 寄送郵件
      await sendEmailWithAttachment1(to1,contract,id,state,File(image.path)); //店家
      await sendEmailWithAttachment2(to2,contract,id,state,File(image.path)); //顧客
    }
  }
}
