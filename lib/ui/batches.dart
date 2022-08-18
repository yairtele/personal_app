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
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/ui/batch_details.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:navigation_app/ui/ui_helper.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_state.dart';
import '../config/configuration.dart';
import '../router/ui_pages.dart';

class Batches extends StatefulWidget{
  const Batches({Key? key}) : super(key: key);

  @override
  _BatchesState createState() => _BatchesState();
}

class _BatchesState extends State<Batches> {

  late Future<ScreenData<dynamic, List<Batch>>> _localData;
  @override
  void initState(){
    super.initState();
    _localData =  _getScreenData();
  }

  Future<ScreenData<dynamic, List<Batch>>> _getScreenData() => ScreenData<dynamic, List<Batch>>(dataGetter: _getBatchData).getScreenData();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return FutureBuilder<ScreenData<void, List<Batch>>>(

            future: _localData,
            builder: (BuildContext context, AsyncSnapshot<ScreenData<dynamic, List<Batch>>> snapshot) {

              Widget widget;
              if (snapshot.connectionState == ConnectionState.done &&  snapshot.hasData) {
                final data = snapshot.data!;
                final userInfo = data.userInfo;
                final batches = data.data!;
                final draftBatches = batches.where((batch) =>
                batch.state == BatchStates.Draft).toList();
                final auditedBatches = batches.where((batch) =>
                batch.state != BatchStates.Draft).toList();
                widget = Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    backgroundColor: Configuration.customerPrimaryColor,
                    title: const Text(
                      '',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    actions: [
                      Center(
                          child: Text(
                            'Bienvenido, ${userInfo.firstName}!\nCUIT: ${data
                                .userInfo.idNumber}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          )),
                      IconButton(
                        icon: const Icon(Icons.logout),
                          onPressed: () {
                            showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                              title: const Text('Alerta'),
                              content: const Text('¿Está seguro que quiere Cerrar Sesión?'),
                              actions: <Widget>[
                              TextButton(
                                  onPressed: () => { Navigator.of(context).pop() },
                                  child: const Text('No'),
                              ),
                              TextButton(
                              child: const Text('Si'),
                              onPressed: () async {
                                  await appState.logout();
                              }),
                            ]),
                            );
                          }
                      ),
                      IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () =>
                              appState.waitCurrentAction<bool>(
                                  PageAction(state: PageState.addPage,
                                      pageConfig: NewBatchPageConfig)
                              ).then((shouldRefresh) {
                                if (shouldRefresh!) {
                                  setState(() {
                                    _localData = _getScreenData();
                                  });
                                }
                              })
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: Configuration.customerPrimaryColor
                        ),
                        onPressed: () {
                          launch(
                              Configuration.athentoAPIBaseURL + '/accounts/login/?next=/dashboard/');
                        }
                        ,
                        icon: Image.asset(
                          'assets/images/boton_athento.png',
                          height: 40.0, width: 40.0,),
                        label: const Text(''),
                      ),
                    ],
                  ),
                  body: SafeArea(
                    child: RefreshIndicator(child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          DataTable(
                            dataRowHeight: 55,
                            columns: <DataColumn>[
                            const DataColumn(
                              label: Text('Lotes en Draft',
                                  style: TextStyle(fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ],
                            rows: List<DataRow>.generate (
                              //batches.where((state) => 'Draft').length,
                              draftBatches.length,
                                  (int index) =>
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(
                                          ListTile(
                                            //isThreeLine: true,
                                            leading: const Icon(
                                                FontAwesomeIcons.archive,
                                                color: Configuration.customerSecondaryColor),
                                            title: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,//y
                                              crossAxisAlignment: CrossAxisAlignment.start,//x
                                                children:[
                                              Text(draftBatches[index].batchNumber != null?
                                              '${draftBatches[index].batchNumber}' : 'Generando Nº Lote...',
                                                style: const TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                              Text('${_getBatchSubTitle(
                                                  draftBatches[index])}',
                                                  style: const TextStyle(
                                                      fontSize: 12.0,
                                                      color: Colors.grey))
                                            ]),
                                          ),
                                          onTap: () {
                                            appState.waitCurrentAction<bool>(
                                                PageAction(
                                                    state: PageState.addWidget,
                                                    widget: BatchDetails(
                                                        batch: draftBatches[index]),
                                                    pageConfig: DetailsPageConfig)
                                            ).then((shouldRefresh) {
                                              if (shouldRefresh!) { //TODO:  Manejar el resultado de la pantalla Batch Details
                                                setState(() {
                                                  _localData = _getScreenData();
                                                });
                                              }
                                            });
                                          }
                                      )
                                    ],
                                  ),
                            ),
                          ),
                          if(draftBatches.length == 0)
                            const Text('No hay lotes en draft para mostrar'),
                          Container( // Change as you wish
                              child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                          child: DataTable(
                            dataRowHeight: 55,
                            columns: <DataColumn>[
                            const DataColumn(
                              label: Text('Lotes en Auditoria',
                                  style: TextStyle(fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                  )
                              ),
                            ),
                          ],
                            rows:
                            List<DataRow>.generate (
                              auditedBatches.length,
                                  (int index) =>
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(ListTile(
                                        leading: Icon(
                                            FontAwesomeIcons.archive,
                                            color: UIHelper.getStateColor(auditedBatches[index].state!)),//Colors.blue),
                                        title: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,//y
                                            crossAxisAlignment: CrossAxisAlignment.start,//x
                                            children:[
                                              Text(auditedBatches[index].batchNumber != null?
                                              '${auditedBatches[index].batchNumber}' : 'Generando Nº Lote...',
                                                  style: const TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black)),
                                              Text('${_getBatchSubTitle(
                                                  auditedBatches[index])}',
                                                  style: const TextStyle(
                                                      fontSize: 12.0,
                                                      color: Colors.grey))
                                            ]),
                                      ),
                                          onTap: () {
                                            appState.waitCurrentAction<bool>(
                                                PageAction(
                                                    state: PageState.addWidget,
                                                    widget: BatchDetails(
                                                        batch: auditedBatches[index]),
                                                    pageConfig: DetailsPageConfig))
                                                .then((shouldRefresh) {
                                              if (shouldRefresh! == true) {
                                                setState(() {
                                                  _localData = _getScreenData();
                                                });
                                              }
                                            });
                                          }),
                                    ],
                                  ),
                               ),
                              ),
                             ),
                          ),
                          if(auditedBatches.length == 0)
                            const Text('No hay lotes en auditoría para mostrar'),
                        ],
                      ),
                    ),
                        onRefresh: _refresh
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
              } else {
                widget = Scaffold(
                  backgroundColor: Configuration.customerPrimaryColor,
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
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Configuration.customerSecondaryColor),
                                    ),
                                    Text('Cargando...',
                                        style: TextStyle(
                                            color: Configuration.customerSecondaryColor,
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
                );
              }
              return widget;
            }
        );
  }

  Future<List<Batch>> _getBatchData(something) async{
    // Obtener lista de lotes Draft (en principio) desde Athento
    final batches =  BusinessServices.getRetailActiveBatches();
    return batches;
  }

  String _getBatchSubTitle(Batch batch) {
    var batchDescription = (batch.description ?? '' ).trim();
    if (batchDescription.length==0){
      batchDescription = '(sin descripción)';
    }
    final batchRetailReference = (batch.retailReference ?? '').trim();
    return batchRetailReference  != '' ? batchRetailReference : batchDescription;
  }

  Future<void> _refresh() async{
    setState(() {
      _localData =  _getScreenData();
    });
  }
}

