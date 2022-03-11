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
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:navigation_app/services/user_services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/dio.dart';

//import 'package:keycloak_flutter/keycloak_flutter.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState()  {
    super.initState();
    updateLocalFiles();
  }


  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    passwordTextController.text =  appState.password;
    emailTextController.text = appState.emailAddress;

    emailTextController.text = 'adrian.scotto.newsan';
    passwordTextController.text =  r'N$ju7ilo9#4791AS';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey,
        title: Image.asset('assets/images/logo_blanco.png',height:120 ,width:160,),
      ),
      body: SafeArea(
        child:  LayoutBuilder(builder: (context, constraints){
          return Center(
            child: Container(
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
                                decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    hintText: 'Email'),
                                onChanged: (email) => appState.emailAddress = email,
                                controller: emailTextController),
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
                                obscureText: true,
                                decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    hintText: 'Password'),
                                onChanged: (password) => appState.password = password,
                                controller: passwordTextController),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            child: const Text('Login', style: TextStyle(color: Colors.black),),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              side: const BorderSide(color: Colors.black),
                            ),
                            onPressed: () async {
                              try{
                                appState.emailAddress = emailTextController.text;
                                appState.password = passwordTextController.text;
                                await appState.login();
                              }
                              on InvalidLoginException catch(e){
                                _showSnackBar(e.message);

                              }
                              on Exception {
                                _showSnackBar('Ha ocurrido un error inesperado autenticando al usuario.');
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
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario o clave inválida' )),
    );
  }

  Future<void> updateLocalFiles() async {
    final localFolderPath = (await getApplicationDocumentsDirectory()).path;
    final productsFolderPath = Directory('$localFolderPath/products');

    const  filesFolderURL = 'https://socialpath.com.ar/bandeja/newsan';
    // Check if the product files folder exists in the local app folder. If not, create it
    if(!productsFolderPath.existsSync()){
      await productsFolderPath.create();
    }

    // Check if the product file exists in the local app products folder. If not, retrieve it
    //TODO: check if file needs update
    const productsFileName = 'products_db.csv';
    final productsFile = File('${productsFolderPath.path}/$productsFileName');
    if(!productsFile.existsSync()){
      //TODO: For now, copy the file from assets
      // Read file contents
      //final productsFileContents = await rootBundle.loadString('assets/products/$productsFileName');
      
      // Write file to local folder
      const productsFileURL = '$filesFolderURL/$productsFileName';

      final response = await Dio().download(productsFileURL, productsFile.path,
          onReceiveProgress: (value1, value2) {
          //  setState(() {
                final progress = value1 / value2;
          //  });
          }
      );
      //productsFile.writeAsStringSync(productsFileContents, mode: FileMode.write, encoding: Encoding.getByName('UTF-8'));
    }

    // Check if the sales file exists in the local app products folder. If not, retrieve it
    //TODO: check if file needs update

    const salesFileName = 'sales_db.csv';
    final salesFile = File('${productsFolderPath.path}/$salesFileName');
    if(!salesFile.existsSync()){
      //TODO: For now, copy the file from assets
      // Read file contents
      //final salesFileContents = await rootBundle.loadString('assets/products/$salesFileName');

      // Write file to local folder
      const salesFileURL = '$filesFolderURL/$salesFileName';

      final response = await Dio().download(salesFileURL, salesFile.path,
        onReceiveProgress: (value1, value2) {
        //  setState(() {
              final progress = value1 / value2;
        //  });
        }
      );
      //salesFile.writeAsStringSync(salesFileContents, mode: FileMode.write, encoding: Encoding.getByName('UTF-8'));
    }
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