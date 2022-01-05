//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:navigation_app/router/ui_pages.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
bool EAN = false;
bool MOD = false;
class UploadBatch extends StatefulWidget {
  const UploadBatch({Key key}) : super(key: key);

  @override
  State<UploadBatch> createState() => _UploadBatch();
}

class _UploadBatch extends State<UploadBatch> {
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
          ],
        ),
      ),
    );
  }
}

