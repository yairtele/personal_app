import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';

import '../config/configuration.dart';

var _loginStatus = false;
var _googleUser = null;
const _folderType = 'application/vnd.google-apps.folder';

bool getLoginStatus(){
  return _loginStatus;
}

final googleSignIn = GoogleSignIn.standard(scopes: [
  drive.DriveApi.driveScope//ReadonlyScope
]);

Future<bool> signIn() async {
  final googleUser = await googleSignIn.signIn();

  try {
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final loginUser = await FirebaseAuth.instance.signInWithCredential(credential);

      assert(loginUser.user?.uid == FirebaseAuth.instance.currentUser?.uid);
      //print('Sign in');
      _googleUser = googleUser;
      _loginStatus = true;
      return true;
    }
    return false;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<void> signOut() async {

  await FirebaseAuth.instance.signOut();
  await googleSignIn.signOut();
  _loginStatus = false;
  _googleUser = null;
  //print("Sign out");
}

Future<bool> uploadTo(BuildContext context, XFile xfile) async {
  try {
    final driveApi = await _getDriveApi(context);
    if (driveApi == null) {
      return false;
    }
    // Not allow a user to do something else
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(seconds: 2),
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, animation, secondaryAnimation) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final folderId = await _getFolderId(driveApi, Configuration.photosFolderName);

    //Create media here
    final media = drive.Media(castStream(xfile.openRead()), await xfile.length());

    //Set up file info
    final driveFile = drive.File();
    driveFile.name = xfile.path.split('/').last.replaceAll('scaled_', '');//el replace es custom, hay varias que lo tienen
    driveFile.modifiedTime = DateTime.now().toUtc();
    driveFile.parents = [folderId!];

    //Upload
    //type 'Base64Encoder' is not a subtype of type 'StreamTransformer<Uint8List, String>' of 'streamTransformer'
    final response = await driveApi.files.create(driveFile, uploadMedia: media);
    print('response: $response');

    //simulate a slow process
    await Future.delayed(const Duration(seconds: 2));
  } catch(_){
    return false;
  } finally {
    // Remove a dialog
    Navigator.pop(context);
  }

  return true;
}

Stream<List<int>> castStream(Stream<Uint8List> sourceStream) {
  return sourceStream.transform(StreamTransformer<Uint8List, List<int>>.fromHandlers(
    handleData: (Uint8List data, EventSink<List<int>> sink) {
      sink.add(data.toList());
    },
  ));
}

Future<drive.FileList?> allFileList(context) async {
  final driveApi = await _getDriveApi(context);
  if (driveApi == null) {
    return null;
  }

  final folderId = await _getFolderId(driveApi, Configuration.photosFolderName);
  //TODO: Order photos by name (name is the date so it would be ordered by date)
  final response = driveApi.files.list(
    spaces: 'drive',
    q: "'$folderId' in parents",
  );

  return response;
}

Future<String?> _getFolderId(drive.DriveApi driveApi, String folderName) async {
  try {
    final found = await driveApi.files.list(
      q: "mimeType = '$_folderType' and name = '$folderName'",
      $fields: 'files(id, name)',
    );
    final files = found.files;
    if (files == null) {
      return null;
    }

    if (files.isNotEmpty) {
      return files.first.id;
    }
  } catch (e) {
    print(e);
  }
  return null;
}

Future<drive.DriveApi?> _getDriveApi(context) async {
  final googleUser = _googleUser;

  if (googleUser != null) {
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final loginUser = await FirebaseAuth.instance.signInWithCredential(credential);

    assert(loginUser.user?.uid == FirebaseAuth.instance.currentUser?.uid);
  }

  final headers = await googleUser?.authHeaders;
  if (headers == null) {
    await showMessage(context, 'Sign-in first', 'Error');
    return null;
  }

  final client = GoogleAuthClient(headers);
  final driveApi = drive.DriveApi(client);
  return driveApi;
}

Future<void> showMessage(BuildContext context, String msg, String title) async {
  final alert =  AlertDialog(
    title: Text(title),
    content: Text(msg),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('OK'),
      ),
    ],
  );
  await showDialog(
    context: context,
    builder: (BuildContext context) => alert,
  );
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}