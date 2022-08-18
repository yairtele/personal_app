import 'dart:async';
import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/ui/ui_helper.dart';
import 'package:provider/provider.dart';
import 'package:navigation_app/utils/ui/working_indicator_dialog.dart';

import '../app_state.dart';
import '../config/configuration.dart';
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
          backgroundColor: Configuration.customerPrimaryColor,
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
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: UIHelper.formFieldContainerMargin,
                        padding: UIHelper.formFieldContainerPadding,
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
                                          'Referencia Interna Lote:',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                            ),
                          ),
                          onChanged: (reference) => appState.reference = reference,
                          controller: referenceTextController,
                        ),
                      ),
                    ),
                    if(Platform.isAndroid)
                      Container(
                        width: 45,
                        margin: UIHelper.formFieldContainerMargin,
                        padding: const EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(left: 0, right: 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Icon(FontAwesomeIcons.barcode),
                          onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                final barcode = await BarcodeScanner.scan();
                                if (barcode.type.value == 0)
                                  setState(() {
                                    referenceTextController.text = barcode.rawContent;
                                  });
                          },
                        ),
                      )
                  ],
                ),

                Container(
                  margin: UIHelper.formFieldContainerMargin,
                  padding: UIHelper.formFieldContainerPadding,
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
                                    'Descripcion:',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
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
                  margin: UIHelper.formFieldContainerMargin,
                  padding: UIHelper.formFieldContainerPadding,
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
                                    'Observacion:',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                      ),
                    ),
                    onChanged: (observation) => appState.observation = observation,
                    controller: observationTextController,
                  ),
                ),
                Padding(
                  //margin: const EdgeInsets.only(top: 0),
                  padding: EdgeInsets.only(top: 16.0),//const EdgeInsets.fromLTRB(95,25,95,0),//const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                      child: Row(
                          children: [
                            //const Icon(Icons.add_box_outlined),
                            const Text('Crear')
                          ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
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
                          _shouldRefreshParent = true;
                          _showSuccessfulSnackBar('Nuevo lote creado con éxito');
                        }
                        on BusinessException catch (e){
                          _showErrorSnackBar(e.message);
                        }
                        on Exception catch (e){
                          _showErrorSnackBar('Ha ocurrido un error inesperado guardardo el nuevo lote: $e');
                        }
                        finally{
                          WorkingIndicatorDialog().dismiss();
                        }
                      }
                  ),
                ]
                ))
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
}