import 'dart:convert';

import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //Text('ID Lote Retail: '),
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(15),
                child: const TextField(
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: 'ID Lote Retail',
                    helperText: 'Ej: 939482'
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(15),
                child: const TextField(
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  maxLength: 50,
                  decoration: InputDecoration(
                      hintText: 'Descripcion',
                      helperText: 'Ej: Lote Fravega 4'
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(15),
                child: ElevatedButton(
                  onPressed: () => _makePostRequest(),
                  child: const Text('Enviar a Athento'),
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
    );
  }
}

void _makePostRequest() async {
// set up Post request arguments
  String username = 'luiz';
  String password = '123';
  String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  // Uri url = 'https://newsan.athento.com/athento/site/automation/Athento.DocumentCreate/';
  var queryParameters;
  Uri url = Uri.https('newsan.athento.com','/athento/site/automation/Athento.DocumentCreate');
  var headers= <String, String>{'authorization': basicAuth};
 //uuid de AVON estático
  var json = '{"input": "2ddd5db0-b28b-4fc9-b1e5-357a5d0b43e2","params": {"type": "lote_lif","audit": "Creado desde la aplicacion x","properties": {"dc:title":"Title example","lote_lif_descripcion_lote" : "Massa morbi magnis pede suspendisse in platea fames.","lote_lif_referencia_interna_lote" : "Morbi class cum praesent a.","lote_lif_ndeg_lote" : "000000000001","lote_lif_cuit_cliente" : "Porta lorem amet sed consectetuer.","lote_lif_razon_social" : "Curae felis massa egestas velit risus ligula accumsan porta potenti lacus dolor nullam porta parturient.","lote_lif_auditor" : "","lote_lif_backoffice" : ""}}}';
// make PUT request
  Response response = await post(url, headers: headers, body: json);
// check the status code for the result
  int statusCode = response.statusCode;

  print('statusCode' + statusCode.toString());
// this API passes back the updated item with the id added
  String body = response.body;

  print('body: ' + body.toString());

}

