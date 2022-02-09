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
import 'package:navigation_app/services/business_services.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';
import 'package:navigation_app/ui/details.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../router/ui_pages.dart';

class ListItems extends StatefulWidget{
  const ListItems({Key key}) : super(key: key);

  @override
  _ListItemsState createState() => _ListItemsState();
}


class _ListItemsState extends State<ListItems> {

  Future<_LocalData> _localData;

  @override
  void initState(){
    super.initState();
    _localData = _getUserAndBatchData();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return FutureBuilder<_LocalData>(
        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<_LocalData> snapshot) {
          final data = snapshot.data;

          Widget widget;
          if (snapshot.hasData) {
            widget = Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.grey,
                title: const Text(
                  'Lotes',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                actions: [
                  Center(
                      child: Text(
                        'Bienvenido, ${data.userInfo.firstName}!\nCUIT: ${data
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
                  RaisedButton.icon(onPressed: () {
                    launch(
                        'https://newsan.athento.com/accounts/login/?next=/dashboard/');
                  }
                    ,
                    icon: Image.network(
                        'https://pbs.twimg.com/profile_images/1721100976/boton-market_sombra24_400x400.png'),
                    label: const Text(''),
                    color: Colors.grey,
                  ),
                ],
              ),
              body: SafeArea(
                child: ListView.builder(
                  itemCount: data.batches.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      isThreeLine: true,
                      leading: const Icon(Icons.article),
                      title: Text('${_getBatchTitle(data.batches[index])}',
                          style: const TextStyle(fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)
                      ),
                      subtitle: Text('${_getBatchSubTitle(data
                          .batches[index])}\n'),
                      onTap: () {
                        appState.currentAction = PageAction(
                            state: PageState.addWidget,
                            widget: Details(index),
                            page: DetailsPageConfig);
                      },
                    );
                  },
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
              ,icon: Image.network('https://pbs.twimg.com/profile_images/1721100976/boton-market_sombra24_400x400.png'),
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

  Future<_LocalData> _getUserAndBatchData() async{

    // Obtener CUIT del usuario (del perfil de Athento)
    var userInfo = await Cache.getUserInfo();

    if(userInfo == null) {
      final userName = await Cache.getUserName();
      userInfo = await BusinessServices.getUserInfo(userName);
      Cache.saveUserInfo(userInfo);
    }

    // Obtener Razon social con el servicio de Newsan
    var companyName = await Cache.getCompanyName();
    if(companyName ==  null) {
      companyName = await BusinessServices.getCompanyName(userInfo.idNumber); // En el idNumber del perfil de athento se guarda l CUIT retail
      Cache.saveCompanyName(companyName);
    }

    // Obtener lista de lotes Draft (en principio) desde Athento
    final batches = await BusinessServices.getBatches();

    return _LocalData(userInfo: userInfo, companyName: companyName, batches: batches);
  }

  String _getBatchTitle(Batch batch) {
    return batch.retailReference != '' ? batch.retailReference : batch.description;
  }
  String _getBatchSubTitle(Batch batch) {
    return batch.description != '' ? (batch.retailReference == '' ? '(sin referencia)' : batch.description) : '(Sin descripción)';
  }
}

class _LocalData{
  List<Batch> batches;
  UserInfo userInfo;
  String companyName;

  _LocalData({@required UserInfo this.userInfo, @required this.companyName, @required this.batches});
}