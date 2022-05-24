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
import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/ui/newreturn.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:navigation_app/ui/ui_helper.dart';
import 'package:navigation_app/utils/ui/working_indicator_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';
import 'return_request_details.dart';


class BatchDetails extends StatefulWidget {
  final Batch batch;
  const BatchDetails({Key? key, required this.batch}) : super(key: key);

  @override
  _BatchDetailsState createState() =>  _BatchDetailsState();

}

class _BatchDetailsState extends State<BatchDetails> {
  late Future<ScreenData<Batch, List<ReturnRequest>>> _localData;
  bool _shouldRefreshParent = false;
  var _reference;
  var _referenceModified = false;

  @override
  void initState(){
    super.initState();
    _localData = getScreenData();
  }

  Future<ScreenData<Batch, List<ReturnRequest>>> getScreenData() => ScreenData<Batch, List<ReturnRequest>>(dataGetter: _getReturnRequests).getScreenData(dataGetterParam: widget.batch);


  @override
  Widget build(BuildContext context) {
    var enabled_value = true;
    final batch = widget.batch;
    if(!_referenceModified) {
      final title = batch.retailReference;
      _reference = TextEditingController(text: title);
    }
    final subTitle = batch.description;
    final observation = batch.observation;
    final batchnumber = batch.batchNumber;
    final appState = Provider.of<AppState>(context, listen: false);

    final _description = TextEditingController(text:subTitle);
    final _observation = TextEditingController(text:observation);
    final _batchnumber = TextEditingController(text:batchnumber);
    if (batch.state!=BatchStates.Draft){
      enabled_value = false;
    }

    return WillPopScope(
      onWillPop: () {

        appState.returnWith(_shouldRefreshParent);
        _shouldRefreshParent = false;

        //we need to return a future
        return Future.value(false);
      },
      child: FutureBuilder<ScreenData<Batch, List<ReturnRequest>>>(
          future: _localData,
          builder: (BuildContext context, AsyncSnapshot<ScreenData<Batch, List<ReturnRequest>>> snapshot) {

            Widget widget;
            if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              final batch = this.widget.batch;
              final data = snapshot.data!;
              final returns = data.data!;
              final shouldShowStateColumn =batch.state != 'Draft';
              widget = Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: const Color(0xFF741526),//Colors.grey,
                  title: Text(
                    batch.retailReference ?? batch.batchNumber ?? '(Generando N° Lote...)',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                  ),
                  actions: [
                    /*
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () =>
                      appState.currentAction =
                          PageAction(
                              state: PageState.addPage, pageConfig: SettingsPageConfig),
                    ),
                    */
                    if (batch.state==BatchStates.Draft)
                    IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          appState.waitCurrentAction(PageAction(state: PageState.addWidget,
                              widget: NewReturnScreen(batch: this.widget.batch),
                              pageConfig: NewReturnPageConfig))
                              .then((shouldRefresh) {
                            if(shouldRefresh!) {
                              setState(() {
                                _localData = getScreenData();
                              });
                            }
                          });
                        }
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF741526)//Colors.grey,
                      ),
                      onPressed: () {
                        launch(
                            'https://newsan.athento.com/accounts/login/?next=/dashboard/');
                      }
                      , icon: Image.asset(
                      'assets/images/boton_athento.png',
                      height: 40.0, width: 40.0,),
                      label: Text(''),
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Container( //Nro Lote
                        margin: UIHelper.formFieldContainerMargin,
                        padding: UIHelper.formFieldContainerPadding,
                        child: TextField(
                          autofocus: false,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.send,
                          maxLength: 100,
                          controller: _batchnumber,
                          enabled: false,
                          decoration: const InputDecoration(
                            label: Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    WidgetSpan(
                                      child: Text(
                                          'N° Lote:',
                                          style: TextStyle(fontSize: 18.0,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container( //Referencia Interna - TextField
                                margin: UIHelper.formFieldContainerMargin,
                                padding: UIHelper.formFieldContainerPadding,
                            child: TextField(
                              autofocus: false,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.send,
                              maxLength: 30,
                              controller: _reference,
                              enabled: enabled_value,
                              onChanged: (_) {
                                _referenceModified = true;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Referencia Interna Lote',
                                helperText: 'Ej: L0035266',
                                label: Text.rich(
                                    TextSpan(
                                      children: <InlineSpan>[
                                        WidgetSpan(
                                          child: Text(
                                              'Referencia Interna Lote:',
                                              style: TextStyle(fontSize: 18.0,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    )
                                ),
                              ),
                            ),
                          )
                          ),
                          if (batch.state==BatchStates.Draft)
                            Container( //Referencia Interna - Boton Codigo Barras
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
                                if (Platform.isAndroid || Platform.isIOS) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  final barcode = await BarcodeScanner.scan();
                                  setState(() {
                                    _reference.text = barcode.rawContent;
                                    _referenceModified = true;
                                  });
                                }
                              },
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: UIHelper.formFieldContainerMargin,
                        padding: UIHelper.formFieldContainerPadding,
                        child: TextField(
                          autofocus: false,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.send,
                          maxLength: 50,
                          controller: _description,
                          enabled: enabled_value,
                          decoration: const InputDecoration(
                            hintText: 'Descripcion',
                            helperText: 'Ej: Lote de televisores SONY',
                            label: Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    WidgetSpan(
                                      child: Text(
                                          'Descripcion:', style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: UIHelper.formFieldContainerMargin,
                        padding: UIHelper.formFieldContainerPadding,
                        child: TextField(
                          autofocus: false,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.send,
                          maxLength: 250,
                          controller: _observation,
                          enabled: enabled_value,
                          decoration: const InputDecoration(
                            hintText: 'Observacion',
                            helperText: 'Ej: Contiene fallas',
                            label: Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    WidgetSpan(
                                      child: Text(
                                          'Observacion:', style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (batch.state==BatchStates.Draft)
                            ElevatedButton(
                              onPressed: () async {
                                try{
                                  WorkingIndicatorDialog().show(context, text: 'Actualizando lote...');
                                  await _updateBatch(batch,_reference.text,_description.text,_observation.text);
                                  _shouldRefreshParent = true;
                                  _showSnackBar('Lote actualizado con éxito');
                                }
                                on BusinessException catch (e){
                                  _showSnackBar(e.message);
                                }
                                on Exception catch (e){
                                  _showSnackBar('Ha ocurrido un error inesperado al actualizar el lote: $e');
                                }
                                finally{
                                  WorkingIndicatorDialog().dismiss();
                                }
                              },
                                child: Row(
                                    children: [
                                      const Icon(Icons.save),
                                      const Text('Guardar')
                                    ]
                                ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green[400]
                              )
                          ),
                            Padding(
                                padding: UIHelper.buttonPadding
                            ),
                            if (batch.state==BatchStates.Draft)
                            ElevatedButton(
                                onPressed: () async {
                                  try{
                                    WorkingIndicatorDialog().show(context, text: 'Enviando lote...');
                                    await _updateBatchState(batch);
                                    //appState.currentAction = PageAction(state: PageState.pop);
                                    _showSnackBar('Lote enviado con éxito');
                                    appState.returnWith(true);
                                  }
                                  on BusinessException catch (e){
                                    _showSnackBar(e.message);
                                  }
                                  on Exception catch (e){
                                    _showSnackBar('Ha ocurrido un error inesperado al enviar el lote: $e');
                                  }
                                  finally{
                                    WorkingIndicatorDialog().dismiss();
                                  }
                                },
                                child: Row(
                                    children: [
                                      const Icon(Icons.send),
                                      const Text('Enviar')
                                    ]
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blueAccent
                                )
                            ),
                            Padding(
                              padding: UIHelper.buttonPadding
                            ),
                            if (batch.state==BatchStates.Draft)
                            ElevatedButton(
                                onPressed: () async {
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: const Text('Alerta'),
                                      content: const Text('¿Seguro quiere eliminar este Lote?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => { Navigator.of(context).pop() },
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                            child: const Text('Borrar'),
                                            onPressed: () async {
                                              try {
                                                WorkingIndicatorDialog().show(
                                                    context,
                                                    text: 'Eliminando lote...');
                                                await _deleteBatch(batch);
                                                _showSnackBar('El lote ha sido eliminado exitosamente');
                                                appState.returnWith(true);
                                              }
                                              on BusinessException catch (e){
                                                _showSnackBar(e.message);
                                              }
                                              on Exception catch (e){
                                                _showSnackBar('Ha ocurrido un error inesperado eliminando el lote: $e');
                                              }
                                              finally{
                                                WorkingIndicatorDialog().dismiss();
                                              }
                                            }
                                        ),
                                      ],
                                    ),
                                  );

                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete),
                                    const Text('Eliminar')
                                  ]
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red
                                )
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 500.0, // Change as you wish
                        width: 500.0, // Change as you wish
                        child: DataTable(// Lista de solicitudes del lote

                          columns:  <DataColumn>[
                            const DataColumn(
                              label: Text('Solicitudes'),
                            ),
                            //if (shouldShowStateColumn)
                              //const DataColumn(label: Text('Estado'))
                          ],

                          rows: List<DataRow>.generate(
                            returns.length,
                                (int index) {
                              final returnRequest = returns[index];
                              final title = _getReturnTitle(returnRequest);
                              final subtitle = _getReturnSubTitle(returnRequest);
                              return DataRow(
                                //color: UIHelper.getAuditItemBackgroundColor(returnRequest.state!),
                                cells: <DataCell>[
                                   DataCell(ListTile(
                                    leading: Icon( Icons.art_track_sharp, color: UIHelper.getStateColor(returnRequest.state!)),//Colors.grey,),
                                    // leading: Container(width: 1, padding: const EdgeInsets.all(0), margin: const EdgeInsets.all(0)),
                                    title: Text(
                                        title,
                                        style: const TextStyle(fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    subtitle: Text(subtitle),
                                  ), onTap: () {
                                    appState.waitCurrentAction<bool>(PageAction(
                                        state: PageState.addWidget,
                                        widget: ReturnRequestDetails(batch: this.widget.batch,
                                            returnRequest: returns[index]),
                                        pageConfig: DetailsReturnPageConfig))
                                    .then((shouldRefresh) {
                                      if(shouldRefresh!){
                                        setState(() {
                                          _shouldRefreshParent = shouldRefresh;
                                          _localData = getScreenData();
                                        });
                                      }
                                    });
                                  }),
                                  //if (shouldShowStateColumn)
                                    //DataCell(Text(returns[index].state!))
                                ],
                              );
                            },
                          ),
                          //onTap: () {
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            else if (snapshot.hasError) {
              widget = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    )
                  ],
                ),
              );
            }
            else {
              widget = Scaffold(
                  backgroundColor: const Color(0xFF741526),//Colors.black,
                  body: Stack(
                      fit: StackFit.expand,
                      children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    /// Loader Animation Widget
                                    const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.grey),
                                    ),
                                    const Text('Cargando...',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            height: 8,
                                            fontSize: 14
                                        )
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(top: 30),
                                        child: Column(
                                            verticalDirection: VerticalDirection.up,
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Image.asset('assets/images/logo_negro.png',
                                                width: 90,
                                                height: 30,)
                                            ]
                                        )
                                    )
                                  ],
                                ),
                              ),
                            ]
                        )
                      ]
                  )
/*                widget = Center(
                    child: Stack(
                        children: <Widget>[
                          const Opacity(
                            opacity: 1,
                            child: CircularProgressIndicator(backgroundColor: Colors.grey),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Cargando...',style: TextStyle(color: Colors.grey,height: 4, fontSize: 9)),
                          )
                        ]
                    )*/
              );
            }
            return widget;
          }
      ),
    );

  }

  Future<List<ReturnRequest>> _getReturnRequests(Batch? batch) async {
    final returnRequests = await BusinessServices.getReturnRequestsByBatchUUID(batchUUID: batch!.uuid!);
    return returnRequests;
  }

  Future<void> _deleteBatch(Batch batch) async {
    await BusinessServices.deleteBatchByUUID(batch.uuid!);
  }
  Future<void> _updateBatch(Batch batch,String reference, String description,String observation) async {
    await BusinessServices.updateBatch(batch,reference,description,observation);
  }

  Future<void> _updateBatchState(Batch batch) async {
    await BusinessServices.sendBatchToAudit(batch);
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  String _getReturnTitle(ReturnRequest  returnRequest) {
    //return returnRequest.retailReference ?? returnRequest.description
    final returnRetailReference = returnRequest.retailReference ?? '';
    return returnRetailReference != '' ? returnRetailReference : (returnRequest.description ?? '(sin descripción)') ;
  }

  String _getReturnSubTitle(ReturnRequest returnRequest) {
    return returnRequest.quantity != null ? 'Unidades: ${returnRequest.quantity}' : '';
  }
}





