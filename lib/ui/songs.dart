import 'package:flutter/material.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:navigation_app/ui/ui_helper.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import '../app_state.dart';
import '../config/configuration.dart';
import '../router/ui_pages.dart';

class Songs extends StatefulWidget{
  const Songs({Key? key}) : super(key: key);

  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends State<Songs> {

  late Future<ScreenData<dynamic, bool>> _localData;
  @override
  void initState(){
    super.initState();
    _localData =  _getScreenData();
  }

  Future<ScreenData<dynamic, bool>> _getScreenData() => ScreenData<dynamic, bool>(dataGetter: _getPerformancesData).getScreenData();

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
            //final batches = data.data!;
            //final draftBatches = batches.where((batch) => batch.state == BatchStates.Draft).toList();
            //final auditedBatches = batches.where((batch) => batch.state != BatchStates.Draft).toList();
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
                    Center(
                        child: Text(
                          '${userInfo.firstName}\n${userInfo.lastName}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Configuration.customerSecondaryColor
                          ),
                        )),
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
                        'assets/images/yayo_user.jpg',//TODO: PAPP - Mostrar imagen del usuario, tomarlo de alguna asociacion user-photofile
                        height: 40.0, width: 40.0,),
                      label: const Text(''),
                    ),
                  ],
                ),
                //TODO: En la previa del acceso a esta screen, llamar a smule para obtener canciones del usuario logueado -> en el body mostrar las canciones en tiles
                body: const Text('Aca van las mejores canciones de los dos en listado, con titulo y mes + año. Mostrar reproductor de canciones al clickear en una')
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

  Future<dynamic> _getPerformancesData(String username) async {

    await http.get(Uri.parse(Configuration.getInitialPerformancesURL(username)));



    return true;
    /*final batches =  BusinessServices.getRetailActiveBatches();
    return batches;*/
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