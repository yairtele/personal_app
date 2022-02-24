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

import '../app_state.dart';
import '../router/ui_pages.dart';

class Batches extends StatefulWidget{
  const Batches({Key key}) : super(key: key);

  @override
  _BatchesState createState() => _BatchesState();
}



class _BatchesState extends State<Batches> {

  Future<ScreenData<dynamic, List<Batch>>> _localData;

  @override
  void initState(){
    super.initState();
    _localData =   ScreenData<void, List<Batch>>(dataGetter: _getBatchData).getScreenData();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return FutureBuilder<ScreenData<void, List<Batch>>>(
        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<ScreenData<dynamic, List<Batch>>> snapshot) {

          Widget widget;
          if (snapshot.hasData) {
            final data = snapshot.data;
            final userInfo = data.userInfo;
            final batches = data.data;

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
                  ElevatedButton.icon(onPressed: () {
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
                child: DataTable(columns: <DataColumn>[
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
                       leading: const Icon(Icons.article,color: Colors.green),
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
    /*
    return  Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey,
        title: const Text(
          'Lotes',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        actions: [
          Center(
              child: Text(
            'Bienvenido, ${appState.userInfo.firstName}!\nCUIT: ${appState.userInfo.idNumber}',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
          )),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => appState.currentAction =
                PageAction(state: PageState.addPage, page: SettingsPageConfig),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => appState.currentAction =
                PageAction(state: PageState.addPage, page: NewBatchPageConfig),
          ),
          RaisedButton.icon(onPressed:(){
            launch('https://newsan.athento.com/accounts/login/?next=/dashboard/');
              }
              ,icon: Image.asset('assets/images/boton_athento.png'),
               label: const Text(''),
               color: Colors.grey,
          ),
        ],
      ),
      body: SafeArea(
          child: ListView.builder(
          itemCount: batches.length,
          itemBuilder: (context, index) {
            return ListTile(
              isThreeLine: true,
              leading: const Icon(Icons.article),
              title: Text('${_getBatchTitle(batches[index])}',style: const TextStyle(fontSize: 14.0 ,fontWeight:FontWeight.bold,color: Colors.black)
              ),
              subtitle: Text('${_getBatchSubTitle(batches[index])}\n'),
              onTap: () {
                appState.currentAction = PageAction(
                    state: PageState.addWidget,
                    widget: Details(_getBatchTitle(batches[index]),_getBatchSubTitle(batches[index])),
                    page: DetailsPageConfig);
              },
            );
          },
        ),
      ),
    );
    */
  }

  Future<List<Batch>> _getBatchData(something) async{
    // Obtener lista de lotes Draft (en principio) desde Athento
    final batches = await BusinessServices.getBatches();
    return batches;
  }

  String _getBatchTitle(Batch batch) {
    return batch.retailReference != '' ? batch.retailReference : batch.description;
  }
  String _getBatchSubTitle(Batch batch) {
    return batch.description != '' ? (batch.retailReference == '' ? '(sin referencia)' : batch.description) : '(Sin descripción)';
  }
}

