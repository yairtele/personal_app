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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marieyayo/services/business/batch.dart';
import 'package:marieyayo/ui/screen_data.dart';
import 'package:marieyayo/ui/ui_helper.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../config/cache.dart';
import '../config/configuration.dart';
import '../router/ui_pages.dart';

class Presentation extends StatefulWidget{
  const Presentation({Key? key}) : super(key: key);

  @override
  _PresentationState createState() => _PresentationState();
}

class _PresentationState extends State<Presentation> {

  late Future<ScreenData<dynamic, bool>> _localData;
  late String _userPhoto;
  @override
  void initState(){
    super.initState();
    _localData =  _getScreenData();
  }

  Future<ScreenData<dynamic, bool>> _getScreenData() => ScreenData<dynamic, bool>(dataGetter: _getBatchData).getScreenData();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return FutureBuilder<ScreenData<void, bool>>(

        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<ScreenData<dynamic, bool>> snapshot) {

          Widget widget;
          if (snapshot.connectionState == ConnectionState.done &&  snapshot.hasData) {
            final data = snapshot.data!;
            final userInfo = data.userInfo;
            widget = Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Configuration.customerPrimaryColor,
                title: const Text(
                  '',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Configuration.customerSecondaryColor),
                ),
                actions: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        primary: Configuration.customerPrimaryColor
                    ),
                    onPressed: () {
                      //TODO: PAPP - Mostrar notita de alerta con info del user logueado
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                            title: const Text('Alerta'),
                            content: const Text('¿Cerrar sesión?'),
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
                    },
                    icon: Image.asset(
                      _userPhoto,
                      height: 40.0,
                      width: 40.0
                    ),
                    label: Center(
                        child: Text(
                            '${userInfo.firstName}\n${userInfo.lastName}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Configuration.customerSecondaryColor,
                            ),
                            textAlign: TextAlign.center
                        )
                    ),
                  )
                  ],
              ),
              body: ListView(
                children: [
                  Card(
                    child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                      fit: BoxFit.cover,
                        image: AssetImage(
                          'assets/images/mov1_bg.jpg',
                        ),
                        opacity: 0.5
                      ),
                    ),
                    child: ListTile(
                        leading: const Icon(FontAwesomeIcons.heart),
                        title: const Text('Movie Part 1'),
                        subtitle: const Text(
                            'Primera parte de esta historia.'
                        ),
                        //trailing: const Icon(Icons.more_vert), //TODO: Agregar mas info o no?
                        //isThreeLine: true,
                        onTap: () => appState.waitCurrentAction<bool>(
                            PageAction(state: PageState.addPage,
                                pageConfig: MoviePart1PageConfig)
                        ),
                      ),
                    )
                  ),
                  Card(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            'assets/images/mov2_bg.jpg',
                          ),
                          opacity: 0.5
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(FontAwesomeIcons.heart),
                        title: const Text('Movie Part 2'),
                        subtitle: const Text(
                            'Segunda parte de esta historia.'
                        ),
                        //trailing: const Icon(Icons.more_vert), //TODO: Agregar mas info o no?
                        //isThreeLine: true,
                        onTap: () => appState.waitCurrentAction<bool>(
                            PageAction(state: PageState.addPage,
                                pageConfig: MoviePart2PageConfig)
                        ),
                      ),
                    )
                  ),
                  Card(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            'assets/images/photos_bg.jpg',
                          ),
                          opacity: 0.5
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(FontAwesomeIcons.photoVideo),
                        title: const Text('Fotos'),
                        subtitle: const Text(
                            'Las mejores fotos de este viaje.'
                        ),
                        //trailing: const Icon(Icons.more_vert), //TODO: Agregar mas info o no?
                        //isThreeLine: true,
                        onTap: () {
                          try {
                            appState.waitCurrentAction<bool>(
                                PageAction(state: PageState.addPage,
                                    pageConfig: FotosPageConfig)
                            );
                          } on Exception catch (_) {
                            UIHelper.showErrorSnackBar('No fue posible recuperar las fotos.', context);
                          }
                        }
                      ),
                    )
                  ),
                  Card(
                    child: Container(
                      decoration: const BoxDecoration(
                      image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                      'assets/images/songs_bg.jpg',
                      ),
                      opacity: 0.5
                      ),
                      ),
                      child: ListTile(
                        leading: const Icon(FontAwesomeIcons.music),
                        title: const Text('Canciones'),
                        subtitle: const Text(
                            'Todos los éxitos de esta dupla.'
                        ),
                        //trailing: const Icon(Icons.more_vert), //TODO: Agregar mas info o no?
                        //isThreeLine: true,
                        onTap: () => appState.waitCurrentAction<bool>(
                            PageAction(state: PageState.addPage,
                                pageConfig: SongsPageConfig)
                        ),
                      ),
                    )
                  )
                ],
              ));
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
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Configuration.customerSecondaryColor),
                                  ),
                                  const Text('Cargando...',
                                      style: TextStyle(
                                          color: Configuration.customerSecondaryColor,
                                          height: 8,
                                          fontSize: 14
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

  Future<bool> _getBatchData(something) async{

    _userPhoto = 'assets/images/'+ (await Cache.getUserName())! + '_user.jpg';
    // Obtener lista de lotes Draft (en principio) desde Athento
    return true;
  }

  Future<void> _refresh() async{
    setState(() {
      _localData =  _getScreenData();
    });
  }
}