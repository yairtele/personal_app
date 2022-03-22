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
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/ui/batch_details.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_state.dart';
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
    _localData =   ScreenData<dynamic, List<Batch>>(dataGetter: _getBatchData).getScreenData();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return FutureBuilder<ScreenData<void, List<Batch>>>(
        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<ScreenData<dynamic, List<Batch>>> snapshot) {

          Widget widget;
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final userInfo = data.userInfo;
            final batches = data.data!;

            widget = Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.grey,
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
                        PageAction(
                            state: PageState.addPage, page: NewBatchPageConfig),
                  ),
                  ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                  ),
                    onPressed: () {
                    launch(
                        'https://newsan.athento.com/accounts/login/?next=/dashboard/');
                  }
                    ,
                    icon: Image.asset(
                        'assets/images/boton_athento.png',
                      height: 40.0,width: 40.0,),
                    label: const Text(''),
                    //color: Colors.grey,
                  ),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                child: Column(
                  children:[
                      DataTable(columns: <DataColumn>[
                      const DataColumn(
                      label: Text('Lotes Draft',style: TextStyle(fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                      ),
                      ],
                      rows: List<DataRow>.generate (
                        batches.length,
                             (int index) => DataRow(
                            cells: <DataCell>[DataCell(ListTile(isThreeLine: true,
                             leading: const Icon(FontAwesomeIcons.archive,color: Colors.grey),
                            title: Text('${_getBatchTitle(batches[index])}',
                            style: const TextStyle(fontSize: 14.0,
                             fontWeight: FontWeight.bold,
                             color: Colors.black)),
                             subtitle: Text('${_getBatchSubTitle(batches[index])}\n\n\n'),
                            ),onTap: () {
                            appState.currentAction = PageAction(
                                state: PageState.addWidget,
                                widget: BatchDetails(batch: batches[index]),
                                page: DetailsPageConfig);})],
                       //selected: selected[index],
                            ),
                          ),
                      ),
                    DataTable(columns: <DataColumn>[
                      const DataColumn(
                        label: Text('Lotes en Auditoria',style: TextStyle(fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                      ),
                    ],
                      rows: List<DataRow>.generate (
                        batches.length,
                            (int index) => DataRow(
                          cells: <DataCell>[DataCell(ListTile(isThreeLine: true,
                            leading: const Icon(FontAwesomeIcons.archive,color: Colors.blue),
                            title: Text('${_getBatchTitle(batches[index])}',
                                style: const TextStyle(fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            subtitle: Text('${_getBatchSubTitle(batches[index])}\n\n\n'),
                          ),onTap: () {
                            appState.currentAction = PageAction(
                                state: PageState.addWidget,
                                widget: BatchDetails(batch: batches[index]),
                                page: DetailsPageConfig);})],

                          //selected: selected[index],
                        ),
                      ),
                    ),
                    ],
                  ),
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
                      const Opacity(
                        opacity: 1,
                        child: CircularProgressIndicator(backgroundColor: Colors.grey),
                      ),
                      const Padding(
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

  Future<List<Batch>> _getBatchData(something) async{
    // Obtener lista de lotes Draft (en principio) desde Athento
    final batches = await BusinessServices.getRetailActiveBatches();
    return batches;
  }


  String _getBatchTitle(Batch batch) {

    final batchRetailReference = (batch.retailReference ?? '').trim();
    final batchDescription = (batch.description ?? '').trim();
    if((batchRetailReference + batchDescription).length == 0){
      return '(sin referencia interna)';
    }
    return batchRetailReference != '' ? batchRetailReference : batchDescription;
  }
  String _getBatchSubTitle(Batch batch) {
    final batchDescription = (batch.description ?? '' ).trim();
    final batchRetailReference = (batch.retailReference ?? '').trim();
    return batchDescription  != '' ? batchDescription : '(sin descripción)';
  }
}

