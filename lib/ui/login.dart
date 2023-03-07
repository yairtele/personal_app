/*
 * Copyright (c) 2021 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
//import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/services/user_services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'package:dio/dio.dart';
import '../config/configuration.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController userTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Future<bool> _localData;
  bool _isObscure = true;
  var _progressText = 'Cargando...';
  final FocusNode _focusNodeUser = FocusNode();
  final FocusNode _focusNodePass = FocusNode();
  var _userColor = Configuration.customerSecondaryColor.withOpacity(0.3);
  var _passColor = Configuration.customerSecondaryColor.withOpacity(0.3);

  @override
  void initState() {
    super.initState();
    _localData = updateLocalFiles();
    _focusNodeUser.addListener(() {
      if(_focusNodeUser.hasFocus){
        setState(() {
          _userColor = Configuration.customerSecondaryColor.withOpacity(0.75);
        });
      }
      else{
        setState(() {
          _userColor = Configuration.customerSecondaryColor.withOpacity(0.3);
        });
      }
    });
    _focusNodePass.addListener(() {
      if(_focusNodePass.hasFocus){
        setState(() {
          _passColor = Configuration.customerSecondaryColor.withOpacity(0.75);
        });
      }
      else{
        setState(() {
          _passColor = Configuration.customerSecondaryColor.withOpacity(0.3);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return FutureBuilder<bool>(
        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            widget = Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Configuration.customerSecondaryColor,
                title: const Center(
                    child: Text(
                      'Marie y Yayo',
                      style: TextStyle(
                          fontFamily: 'ComicSans',
                          fontWeight: FontWeight.w700,
                          color: Configuration.customerPrimaryColor
                          ),
                    ))
              ),
              body: SafeArea(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Center(
                        child: Container(
                          /*decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/drawed_photo_bg.jpeg'),
                              fit: BoxFit.cover
                            )
                          ),*/
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [ // Children
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                            decoration: InputDecoration(
                                              border: UnderlineInputBorder(),
                                              hintText: 'User',
                                              filled: true,
                                              fillColor: _userColor
                                            ),
                                            onChanged: (user) =>
                                            appState.username = user,
                                            controller: userTextController,
                                            focusNode: _focusNodeUser
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          enableSuggestions: false,
                                          autocorrect: false,
                                          obscureText: _isObscure,
                                          decoration: InputDecoration(
                                              border: const UnderlineInputBorder(),
                                              hintText: 'Password',
                                              filled: true,
                                              fillColor: _passColor,
                                              suffixIcon: IconButton(
                                                  icon: Icon(
                                                      _isObscure? Icons.visibility : Icons.visibility_off
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isObscure = !_isObscure;
                                                    });
                                                  }
                                              ),
                                          ),
                                          onChanged: (password) =>
                                          appState.password = password,
                                          controller: passwordTextController,
                                          focusNode: _focusNodePass
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        child: const Text('Iniciar sesión',
                                          style: TextStyle(
                                              color: Configuration.customerPrimaryColor
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: Configuration.customerSecondaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                4.0),
                                          ),
                                          side: const BorderSide(
                                              color: Colors.black
                                          )
                                        ),
                                        onPressed: () async {
                                          try {
                                            appState.username =
                                                userTextController.text;
                                            appState.password =
                                                passwordTextController.text;
                                            await appState.login();
                                          }
                                          on InvalidLoginException catch (e) {
                                            _showErrorSnackBar(e.message);
                                          }
                                          on Exception {
                                            _showErrorSnackBar(
                                                'Ha ocurrido un error inesperado autenticando al usuario.');
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                    );
                  })
              ),
            );
          } else if (snapshot.hasError) {
            widget = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ],
              ),
            );
          } else {
            widget = Scaffold(
                backgroundColor: Configuration.customerPrimaryColor,
                body: Stack(
                    fit: StackFit.expand,
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /// Loader Animation Widget
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Configuration.customerSecondaryColor),
                                  ),
                                  Text(_progressText,
                                      style: TextStyle(
                                          color: Configuration.customerSecondaryColor,
                                          height: 8,
                                          fontSize: 14
                                      )
                                  )
                                ],
                              ),
                            ),
                          ]
                      )
                    ]
                )
            );
          }
          return widget;
        }
    );
  }

  void _showErrorSnackBar(String message) {
    _showSnackBar(message, Colors.red);
  }
  void _showSuccessfulSnackBar(String message) {
    _showSnackBar(message, Colors.green);
  }
  void _showSnackBar(String message, MaterialColor bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bgColor),
    );
  }

  Future<bool> updateLocalFiles() async {
    userTextController.text = (await Cache.getUserName()) ?? '';
    passwordTextController.text = (await Cache.getUserPassword()) ?? '';

    // Check and create (if necesary) local folders where the products and sales files will reside.
    final localFolderPath = (await getApplicationDocumentsDirectory()).path;

    final productsFolderPath = Directory('$localFolderPath/products');

    const filesFolderURL = 'https://socialpath.com.ar/bandeja/newsan';
    // Check if the product files folder exists in the local app folder. If not, create it
    if (!productsFolderPath.existsSync()) {
      await productsFolderPath.create();
    }

    // Check if the rules file exists in the local app products folder. If not, retrieve it
    const rulesFileName = Configuration.rulesFileName;
    const rulesFileURL = '$filesFolderURL/$rulesFileName';
    final rulesFile = File('${productsFolderPath.path}/$rulesFileName');
    if (!rulesFile.existsSync()) {
      // Write file to local folder

      final response = await Dio().download(rulesFileURL, rulesFile.path,
          onReceiveProgress: (value1, value2) {
            setState(() {
              _progressText = 'Descargando 1/1: ${(value1 / value2).toStringAsFixed(2)}';//YAYO: Modificó de 3/3 a 1/1
            });
          }
      );
    }
    else {
      // If rules file does exist, check if it is outdated and update it in such a case
      // Get last modified date
      final response = await http.head(Uri.parse(rulesFileURL));
      final lastModifiedHeader = response.headers[HttpHeaders.lastModifiedHeader];

      // If cached date is different than the file date, download the file and overwrite the old one
      final cachedLastModifiedDate = (await Cache.getRulesFileLastModifiedDate()) ?? '';
      if(cachedLastModifiedDate != lastModifiedHeader){
        final response = await Dio().download(rulesFileURL, rulesFile.path,
            onReceiveProgress: (value1, value2) {
              setState(() {
                _progressText = 'Actualizando maestro de productos: ${(value1 / value2).toStringAsFixed(2)}';
              });
            }
        );
        await Cache.saveRulesFileLastModifiedDate(lastModifiedHeader!);
      }
    }

    return true;
  }
}

/*
Future authenticate() async {

  // parameters here just for the sake of the question
  var uri = Uri.parse('https://keycloak-url/auth/realms/myrealm');
  var clientId = 'my_client_id';
  var scopes = List<String>.of(['openid', 'profile']);
  var port = 4200;
  var redirectUri = Uri.parse('http://localhost:4200');

  var issuer = await Issuer.discover(uri);
  var client = new Client(issuer, clientId);

  urlLauncher(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  var authenticator = new Authenticator(client,
      scopes: scopes,
      port: port,
      urlLancher: urlLauncher,
      redirectUri: redirectUri);

  var c = await authenticator.authorize();
  closeWebView();

  var token= await c.getTokenResponse();
  print(token);
  return token;
}
*/