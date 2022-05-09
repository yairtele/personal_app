import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/business/new_return.dart';
import 'package:navigation_app/ui/batches.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import 'package:navigation_app/utils/ui/working_indicator_dialog.dart';

import '../app_state.dart';
import '../router/ui_pages.dart';
import 'newreturn.dart';


class NewBatch extends StatefulWidget {
  const NewBatch({Key? key}) : super(key: key);

  @override
  State<NewBatch> createState() => _NewBatchState();

}

/*
class NewBatch extends WaitableStatefulWidget<bool> {
  const NewBatch({Key? key, required Completer<bool> returnValueCompleter}) : super(key: key, returnValueCompleter: returnValueCompleter);

  @override
  State<NewBatch> createState() => _NewBatchState();

}
abstract class WaitableStatefulWidget<TReturnValue> extends StatefulWidget{
  const WaitableStatefulWidget({ Key? key, required this.returnValueCompleter }) : super(key: key);
  //Completer<TReturnValue>? _returnValueCompleter;
  final Completer<TReturnValue> returnValueCompleter;

}
*/
class _NewBatchState extends State<NewBatch> {
  TextEditingController referenceTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  TextEditingController observationTextController = TextEditingController();
  var _shouldRefreshParent = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    _shouldRefreshParent = false;
    return WillPopScope(
      onWillPop: () {
        appState.returnWith(_shouldRefreshParent);

        //we need to return a future
        return Future.value(false);
      },
      child: Scaffold(
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

                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.only(left: 15, right: 15),
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
                  margin: const EdgeInsets.only(top: 0),
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: TextField(
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      hintText: 'Descripcion',
                      helperText: 'Ej: Lote para auditar',
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
                  margin: const EdgeInsets.only(top: 0  ),
                  padding: const EdgeInsets.only(left: 15, right: 15),
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
                  margin: const EdgeInsets.only(top: 0),
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: ElevatedButton(
                      child: const Text('Crear lote'),
                      onPressed: () async {
                        try{
                          var uuid;
                          final cuitRetail = (await Cache.getUserInfo())!.idNumber;
                          final retailCompanyName = (await Cache.getCompanyName())!;
                          WorkingIndicatorDialog().show(context, text: 'Creando nuevo lote...');
                          final response = await _createBatch(referenceTextController.text, descriptionTextController.text,observationTextController.text);
                          //Obtengo datos del lote recien creado
                          for (var param in response.keys){
                            if (param == 'uid') {
                            uuid = response[param];
                            }
                          }
                          appState.waitCurrentAction(PageAction(state: PageState.addWidget,
                              widget: NewReturnScreen(batch: Batch(
                                uuid: uuid,
                                title: '${referenceTextController.text} - ${descriptionTextController.text}',
                                state:BatchStates.Draft,
                                retailReference: referenceTextController.text,
                                description: descriptionTextController.text,
                                cuitRetail: cuitRetail,
                                retailCompanyName: retailCompanyName,
                                observation:observationTextController.text,
                              )),
                              pageConfig: NewReturnPageConfig));
                          //appState.returnWith(true);
                          _shouldRefreshParent = true;
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _createBatch(String retailReference, String description, String observation) async {
    final cuitRetail = (await Cache.getUserInfo())!.idNumber;
    final retailCompanyName = (await Cache.getCompanyName())!;
    final response = await BusinessServices.createBatch(Batch(
        title: '$retailReference - $description',
        state:BatchStates.Draft,
        retailReference: retailReference,
        description: description,
        cuitRetail: cuitRetail,
        retailCompanyName: retailCompanyName,
        observation:observation,
    ));
    return response;
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}


