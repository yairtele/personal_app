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
import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/ui/screen_data.dart';
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
    final title = _getBatchTitle(batch);
    final subTitle = _getBatchSubTitle(batch);
    final observation = batch.observation;
    final appState = Provider.of<AppState>(context, listen: false);
    final _reference = TextEditingController(text: title);
    final _description = TextEditingController(text:subTitle);
    final _observation = TextEditingController(text:observation);
    const int numItems = 10;
    List<bool> selected = List<bool>.generate(numItems, (int index) => false);

    return FutureBuilder<ScreenData<Batch, List<ReturnRequest>>>(
        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<ScreenData<Batch, List<ReturnRequest>>> snapshot) {
          final data = snapshot.data;
          final batches = data.data;

          Widget widget;
          if (snapshot.hasData) {
            final data = snapshot.data;

            widget = Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.grey,
                title: Text(
                  '$title',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                actions: [
                  Text(
                    '\nBienvenido, ${data.userInfo.firstName}!\nCUIT: ${data.userInfo.idNumber}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => appState.currentAction =
                        PageAction(state: PageState.addPage, page: SettingsPageConfig),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => appState.currentAction =
                        PageAction(state: PageState.addPage, page: NewReturnPageConfig),
                  ),
                  RaisedButton.icon(onPressed:(){
                    launch('https://newsan.athento.com/accounts/login/?next=/dashboard/');
                  }
                    ,icon: Image.network('https://pbs.twimg.com/profile_images/1721100976/boton-market_sombra24_400x400.png'),
                    label: Text(''),
                    color: Colors.grey,
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
                              helperText: 'Ej: 939482'
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
                              helperText: 'Ej: Lote Fravega 4'
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
                              helperText: 'Ej: Con Fallas'
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [  ElevatedButton(
                            onPressed: () => appState.currentAction =
                                PageAction(state: PageState.addPage, page: DetailsPageConfig),
                            child: const Text('Guardar'),
                          ),
                            ElevatedButton(
                              onPressed: () => appState.currentAction =
                                  PageAction(state: PageState.addPage, page: DetailsPageConfig),
                              child: const Text('Enviar Lote'),
                            ),
                            ElevatedButton(
                              onPressed: () => appState.currentAction =
                                  PageAction(state: PageState.addPage, page: DetailsPageConfig),
                              child: const Text('Borrar Lote'),
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
                                 numItems,
                                     (int index) => DataRow(
                                       cells: <DataCell>[DataCell(Text('Solicitud $index'),onTap: () {
                                         appState.currentAction = PageAction(
                                             state: PageState.addWidget,
                                             widget: ReturnRequestDetails(returnRequest: batches[index]),
                                             page: DetailsReturnPageConfig);})],
                                       selected: selected[index],
                                ),
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
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Aguarde un momento por favor...'),
                      )
                    ]
                )
            );
          }
          return widget;
        }
    );
  }

  String _getBatchTitle(Batch batch) {
    return batch.retailReference != '' ? batch.retailReference : batch.description;
  }
  String _getBatchSubTitle(Batch batch) {
    return batch.description != '' ? (batch.retailReference == '' ? '(sin referencia)' : batch.description) : '(Sin descripción)';
  }

  Future<List<ReturnRequest>> _getReturnRequests(Batch batch) {
    final returnRequests = [
      ReturnRequest(retailReference: 'Solicitud 1'),
      ReturnRequest(retailReference: 'Solicitud 2'),
      ReturnRequest(retailReference: 'Solicitud 3'),
      ReturnRequest(retailReference: 'Solicitud 4'),
      ReturnRequest(retailReference: 'Solicitud 5'),
      ReturnRequest(retailReference: 'Solicitud 6'),
    ];

    final returnValue = Future.delayed(const Duration(milliseconds: 100), () => returnRequests);
    return returnValue;
  }
}





