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
import 'package:navigation_app/services/business_services.dart';
import 'package:navigation_app/services/sp_athento_services.dart';
import 'package:navigation_app/ui/details.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../router/ui_pages.dart';

class ListItems extends StatelessWidget {
  const ListItems({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    // Obtener CUIT del usuario (del perfil de Athento)
    UserInfo user_cuit;
    if(appState.userInfo == null){
      user_cuit = BusinessServices.getUserInfo(appState.emailAddress);
      appState.userInfo = user_cuit;
    }

    // Obtener Razon social con el servicio de Newsan
    String company_name;
    if(appState.companyName == ''){
      company_name = BusinessServices.getCompanyName(appState.userInfo.idNumber);
      appState.companyName = company_name;
    }

    // Obtener lista de lotes Draft (en principio) desde Athento
    var batches = BusinessServices.getBatches();
    appState.companyName = company_name;
    return Scaffold(
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
                    widget: Details(_getBatchTitle(batches[index])),
                    page: DetailsPageConfig);
              },
            );
          },
        ),
      ),
    );
  }

  String _getBatchTitle(Batch batch) {
    return batch.retailReference != '' ? batch.retailReference : batch.description;
  }
  String _getBatchSubTitle(Batch batch) {
    return batch.description != '' ? (batch.retailReference == '' ? '(sin referencia)' : batch.description) : '(Sin descripción)';
  }
}
