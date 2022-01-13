//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:navigation_app/router/ui_pages.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import '../app_state.dart';
bool EAN = false;
bool MOD = false;
PickedFile imageFile;
String _ruta ;
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
              child: const TextField(
                autofocus: true,
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
                            : FileImage(File(imageFile.path)),
                        fit: BoxFit.cover)),
              ),

            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
              ),
            onTap: () async {
              final tmpFile = await getImage(1);
              setState(() {
                imageFile = tmpFile;
                print('Path: ' + imageFile.path.toString());
              });
            }),
          ],
        ),
      ),
    );
  }
}

Future getImage(int type) async {
  final pickedImage = await ImagePicker().getImage(
      source: type == 1 ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50);
  return pickedImage;
}
