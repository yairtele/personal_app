//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:navigation_app/router/ui_pages.dart';
import 'package:provider/provider.dart';

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

