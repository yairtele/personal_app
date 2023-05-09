import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/configuration.dart';

var _loginStatus = false;
var _googleUser = null;
const _folderType = 'application/vnd.google-apps.folder';

bool getLoginStatus(){
  return _loginStatus;
}

final googleSignIn = GoogleSignIn.standard(scopes: [
  drive.DriveApi.driveReadonlyScope
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

/*Future<Object> getFile(context, String fileId) async {
  final driveApi = await _getDriveApi(context);//for this point, driveApi should not be null

  final fileObject = (await driveApi!.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia));

  return fileObject;
}*/

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