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
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';
import 'details_return.dart';
final returns = List<String>.generate(5, (i) => 'Solicitud $i');

class Details extends StatelessWidget {
  final int id;
  const Details(this.id);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey,
        title: Text(
          'Lote $id',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        actions: [
          const Text(
            '\nBienvenido: Juan Perez\nCUIT: 39-558978954-0',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => appState.currentAction =
                PageAction(state: PageState.addPage, page: SettingsPageConfig),
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
      body: SafeArea(
        child: ListView.builder(
          itemCount: returns.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${returns[index]}'
              ),
              onTap: () {
                appState.currentAction = PageAction(
                    state: PageState.addWidget,
                    widget: DetailsReturn(index),
                    page: DetailsReturnPageConfig);
              },
            );
          },
        ),
      ),
    );
  }
}
