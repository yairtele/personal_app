import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import 'package:navigation_app/utils/ui/working_indicator_dialog.dart';

import '../app_state.dart';

class NewBatch extends StatefulWidget {
  const NewBatch({Key? key}) : super(key: key);

  @override
  State<NewBatch> createState() => _NewBatchState();
}

class _NewBatchState extends State<NewBatch> {
  TextEditingController referenceTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  TextEditingController observationTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    referenceTextController.text= appState.reference;
    descriptionTextController.text = appState.description;
    observationTextController.text = appState.observation;

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
          child: ListView(
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
                    helperText: 'Ej: LOT-35266',
                    label: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                  'Referencia Interna Lote:',style: const TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                    ),
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
                    helperText: 'Ej: Lote Fravega 4',
                    label: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                  'Descripcion:',style: const TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                    ),
                  ),
                    onChanged: (description) => appState.description = description,
                    controller: descriptionTextController,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(15),
                child: TextField(
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  maxLength: 250,
                  decoration: const InputDecoration(
                    hintText: 'Observacion',
                    helperText: 'Ej: Contiene Fallas',
                    label: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                  'Observacion:',style: const TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                    ),
                  ),
                  onChanged: (observation) => appState.observation = observation,
                  controller: observationTextController,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(15),
                child: ElevatedButton(
                    child: const Text('Crear lote'),
                    onPressed: () async {
                      try{
                        WorkingIndicatorDialog().show(context, text: 'Creando nuevo lote...');
                        await _createBatch(referenceTextController.text, descriptionTextController.text,observationTextController.text);
                        _showSnackBar('Nuevo batch creado con éxito');
                      }
                      on BusinessException catch (e){
                        _showSnackBar(e.message);
                      }
                      on Exception catch (e){
                        _showSnackBar('Ha ocurrido un error inesperado guardardo el nuevo lote: $e');
                      }
                      finally{
                        WorkingIndicatorDialog().dismiss();
                      }

                    //_makePostRequest(appState.description,appState.reference,appState.emailAddress,appState.password,userInfo.idNumber,appState.companyName);
                  }
                ),
              ),
              //TODO: Descomentar accion de Siguiente y realizar bien la navegacion
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(15),
                child: ElevatedButton(onPressed: () {  },
                  //onPressed: () =>
                  //appState.currentAction = PageAction(state: PageState.addPage, page: NewReturnPageConfig),
                    child: const Text('Siguiente'),
                  ),
              ),

            ],
          ),
       ),
      ),
    );
  }

  Future<void> _createBatch(String retailReference, String description, String observation) async {
    final cuitRetail = (await Cache.getUserInfo())!.idNumber;
    final retailCompanyName = (await Cache.getCompanyName())!;
    BusinessServices.createBatch(Batch(
        title: '$retailReference - $description',
        retailReference: retailReference,
        description: description,
        cuitRetail: cuitRetail,
        retailCompanyName: retailCompanyName,
        observation:observation,
    ));
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}


