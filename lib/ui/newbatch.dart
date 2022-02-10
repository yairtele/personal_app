import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/router/ui_pages.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';

import '../app_state.dart';

class NewBatch extends StatefulWidget {
  const NewBatch({Key key}) : super(key: key);

  @override
  State<NewBatch> createState() => _NewBatchState();
}

class _NewBatchState extends State<NewBatch> {
  TextEditingController referenceTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    referenceTextController.text= appState.reference;
    descriptionTextController.text = appState.description;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey,
        title: const Text(
          'Nuevo Lote',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      body: SafeArea(
         child: Form(
           key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Text('ID Lote Retail: '),
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(15),
                child: TextField(
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    hintText: 'Referencia Interna Lote',
                    helperText: 'Ej: 939482'
                  ),
                  onChanged: (reference) => appState.reference = reference,
                  controller: referenceTextController,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(15),
                child: TextField(
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      hintText: 'Descripcion',
                      helperText: 'Ej: Lote Fravega 4'
                  ),
                    onChanged: (description) => appState.description = description,
                    controller: descriptionTextController,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(15),
                child: ElevatedButton(
                    child: const Text('Enviar a Athento'),
                    onPressed: () async {
                    var userInfo = await Cache.getUserInfo();
                    _makePostRequest(appState.description,appState.reference,appState.emailAddress,appState.password,userInfo.idNumber,appState.companyName);
                  }
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(15),
                child: ElevatedButton(
                  onPressed: () => appState.currentAction =
                      PageAction(state: PageState.addPage, page: NewReturnPageConfig),
                    child: const Text('Crear'),
                  ),
              ),

            ],
          ),
       ),
      ),
    );
  }
}

void _makePostRequest(String description, String reference, String email,String pass,String cuit,String razonsocial) async {
  // set up Post request arguments
  String username = email;
  String password = pass;
  print(username);
  print(password);
  //Se agrega IF para cambiar credenciales de usuario dummy - borrar luego
  if (username =='juan'){
    username = 'diego.daiuto@socialpath.com.ar';
  }
  if (password =='pass'){
    password = 'hkjhg33j4kh5l2345kjh23lkj5h432l45kjh234lkjh543';
  }
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  print('BasicAuth:' + basicAuth);
  String content = 'application/json';

  //String connection = 'keep-alive';
  //String encod = 'gzip, deflate, br';
  // Uri url = 'https://newsan.athento.com/athento/site/automation/Athento.DocumentCreate/'
  Uri url = Uri.https('newsan.athento.com','/athento/site/automation/Athento.DocumentCreate/');
  var headers= <String, String>{'Authorization': basicAuth,'Content-Type':content};
 //uuid de AVON estático
  var json = '{"input": "5366d23d-07bb-4eb3-b34a-5943b0f5cccf","params": {"type": "lote_lif","audit": "Creado desde la aplicacion x","properties": {"dc:title":"$reference$description","lote_lif_descripcion_lote" : "$description","lote_lif_referencia_interna_lote" : "$reference","lote_lif_ndeg_lote" : "000000000002","lote_lif_cuit_cliente" : "$cuit","lote_lif_razon_social" : "$razonsocial","lote_lif_auditor" : "","lote_lif_backoffice" : "","lote_lif_generar_csv" : ""}}}';
// make PUT request
  Response response = await post(url, headers: headers, body: json);
// check the status code for the result
  int statusCode = response.statusCode;

  print('statusCode' + statusCode.toString());
// this API passes back the updated item with the id added
  String body = response.body;

  print('body: ' + body.toString());

}

