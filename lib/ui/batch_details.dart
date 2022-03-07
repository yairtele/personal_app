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
import 'package:flutter/material.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/ui/newreturn.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:navigation_app/utils/ui/working_indicator_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';
import 'return_request_details.dart';


class BatchDetails extends StatefulWidget {
  final Batch batch;
  const BatchDetails({Key key, @required this.batch}) : super(key: key);

  @override
  _BatchDetailsState createState() =>  _BatchDetailsState();

}
class _BatchDetailsState extends State<BatchDetails> {
  Future<ScreenData<Batch, List<ReturnRequest>>> _localData;

  @override
  void initState(){
    super.initState();
    _localData = ScreenData<Batch, List<ReturnRequest>>(dataGetter: _getReturnRequests).getScreenData(dataGetterParam: widget.batch);
  }


  @override
  Widget build(BuildContext context) {
    final batch = widget.batch;
    final title = batch.retailReference;
    final subTitle = batch.description;
    final observation = batch.observation;
    final appState = Provider.of<AppState>(context, listen: false);
    final _reference = TextEditingController(text: title);
    final _description = TextEditingController(text:subTitle);
    final _observation = TextEditingController(text:observation);

    return FutureBuilder<ScreenData<Batch, List<ReturnRequest>>>(
        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<ScreenData<Batch, List<ReturnRequest>>> snapshot) {

          Widget widget;
          if (snapshot.hasData) {
            final data = snapshot.data;
            final returns = data.data;
            widget = Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.grey,
                title: Text(
                  '$title',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                actions: [

                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () =>
                    appState.currentAction =
                        PageAction(
                            state: PageState.addPage, page: SettingsPageConfig),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () =>
                    appState.currentAction =
                        PageAction(state: PageState.addPage,
                            widget: NewReturnScreen(batch: this.widget.batch),
                            page: NewReturnPageConfig),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
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
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(15),
                      child: TextField(
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        maxLength: 30,
                        controller: _reference,
                        decoration: const InputDecoration(
                          hintText: 'Referencia Interna Lote',
                          helperText: 'Ej: LOT-35266',
                          label: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Text(
                                        'Referencia Interna Lote:',
                                        style: const TextStyle(fontSize: 18.0,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                          ),
                        ),
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
                        controller: _description,
                        decoration: const InputDecoration(
                          hintText: 'Descripcion',
                          helperText: 'Ej: Lote Fravega 4',
                          label: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Text(
                                        'Descripcion:', style: const TextStyle(
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
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(15),
                      child: TextField(
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        maxLength: 250,
                        controller: _observation,
                        decoration: const InputDecoration(
                          hintText: 'Observacion',
                          helperText: 'Ej: Contiene fallas',
                          label: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Text(
                                        'Observacion:', style: const TextStyle(
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
                      padding: EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [ ElevatedButton(
                            onPressed: () async {
                              try{
                                WorkingIndicatorDialog().show(context, text: 'Eliminando lote...');
                                await _updateBatch(batch,_reference.text,_description.text,_observation.text);
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
                            child: const Text('Guardar'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green[400],
                            )
                        ),
                          ElevatedButton(
                              onPressed: () =>
                              appState.currentAction =
                                  PageAction(state: PageState.addPage,
                                      page: DetailsPageConfig),
                              child: const Text('Enviar Lote'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                              )
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                try{
                                  WorkingIndicatorDialog().show(context, text: 'Eliminando lote...');
                                  await _deleteBatch(batch);
                                  _showSnackBar('Lote eliminado con éxito');
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

                              },
                              child: const Text('Borrar Lote'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                              )
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 500.0, // Change as you wish
                      width: 500.0, // Change as you wish
                      child: DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text('Solicitudes'),
                          ),
                        ],
                        rows: List<DataRow>.generate(
                          returns.length,
                              (int index) {
                            final returnRequest = returns[index];
                            final title = returnRequest.retailReference ?? returnRequest.description;
                            final subtitle = returnRequest.quantity != null ? 'Unidades: ${returnRequest.quantity}' : '';
                            return DataRow(
                              cells: <DataCell>[
                                DataCell(ListTile(isThreeLine: true,
                                  leading: const Icon(
                                    Icons.art_track_sharp, color: Colors.grey,),
                                  title: Text(
                                      title,
                                      style: const TextStyle(fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  subtitle: Text(subtitle),
                                ), onTap: () {
                                  appState.currentAction = PageAction(
                                      state: PageState.addWidget,
                                      widget: ReturnRequestDetails(
                                          returnRequest: returns[index]),
                                      page: DetailsReturnPageConfig);
                                })
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
          } else if (snapshot.hasError) {
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
          } else {
            widget = Center(
                child: Stack(
                    children: <Widget>[
                      Opacity(
                        opacity: 1,
                        child: CircularProgressIndicator(backgroundColor: Colors.grey),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Cargando...',style: TextStyle(color: Colors.grey,height: 4, fontSize: 9)),
                      )
                    ]
                )
            );
          }
          return widget;
        }
    );
  }

  String _getBatchTitle(Batch returns) {
    return returns.retailReference != '' ? returns.retailReference : returns.description;
  }
  String _getBatchSubTitle(Batch returns) {
    return returns.description != '' ? (returns.retailReference == '' ? '(sin referencia)' : returns.description) : '(Sin descripción)';
  }

  Future<List<ReturnRequest>> _getReturnRequests(Batch batch) async {
    final returnRequests = await BusinessServices.getReturnRequestsByBatchNumber(batchNumber: batch.batchNumber);
    return returnRequests;
  }

  Future<void> _deleteBatch(Batch batch) async {
    await BusinessServices.deleteBatchByUUID(batch.uuid);
  }
  Future<void> _updateBatch(Batch batch,String reference, String description,String observation) async {
    await BusinessServices.updateBatch(batch,reference,description,observation);
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

}





