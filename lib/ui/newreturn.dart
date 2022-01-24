//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:navigation_app/router/ui_pages.dart';
import 'package:provider/provider.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';

import '../app_state.dart';
bool EAN = false;
bool MOD = false;
//PickedFile imageFile;
FilePickerResult imageFile;
String _ruta ;
var _controller = TextEditingController();
//final ImagePicker _picker = ImagePicker();
var _barcodeReader = FlutterBarcodeSdk();

var type;
class NewReturn extends StatefulWidget {
  const NewReturn({Key key}) : super(key: key);

  @override
  State<NewReturn> createState() => _NewReturn();
}

class _NewReturn extends State<NewReturn> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey,
        title: const Text(
          'Nuevo Ingreso',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //Text('ID Lote Retail: '),
            CheckboxListTile(
              title: Text('EAN'),
              value: EAN,
              onChanged: (newValue) {
                setState(() {
                  EAN = newValue;
                  MOD = false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
            ),
            CheckboxListTile(
              title: Text('MOD'),
              value: MOD,
              onChanged: (newValue2) {
                setState(() {
                  MOD = newValue2;
                  EAN = false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(15),
              child: TextField(
                autofocus: true,
                controller: _controller,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.send,
                maxLength: 30,
                decoration: InputDecoration(
                    hintText: 'EAN/MOD',
                    helperText: 'Ej: 939482'
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(15),
              child: ElevatedButton(
                onPressed: () {  },
                child: const Text('Buscar'),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(15),
              child: ElevatedButton(
                onPressed: () => appState.currentAction =
                    PageAction(state: PageState.replaceAll, page: ListItemsPageConfig),
                child: const Text('Confirmar'),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageFile == null
                            ? AssetImage('assets/images/logo_blanco.png')
                            : FileImage(File(imageFile.files.single.path)),
                        fit: BoxFit.cover)),
              ),

            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
              ),
            onTap: () async {
              final userAgent = html.window.navigator.userAgent.toString().toLowerCase();
              RegExp regExp = new RegExp(r'Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini');
              if (regExp.hasMatch(userAgent)) {
                final tmpFile = await FilePicker.platform.pickFiles(); //await getImage(1);
                setState(() async {
                  imageFile = tmpFile;
                  var fileBytes = imageFile.files.first.bytes;
                  //print('Path: ' + imageFile.files.single.path);
                  await _barcodeReader.init();
                  //metodo no soportado en Flutter web, buscar otra libreria
                  List<BarcodeResult> results = await _barcodeReader.decodeFileBytes(fileBytes);
                  print('Barcode: ' + results[0].toString());
                  _controller.text = results[0].toString();
                });
              } else {
                final barcode = await BarcodeScanner.scan();
                _controller.text = barcode.rawContent;
              }
            }
            ),
          ],
        ),
      ),
    );
  }
}
/*
Future getImage(int type) async {
  final pickedImage = await ImagePicker().getImage(
      source: type == 1 ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50);
  return pickedImage;
}
*/