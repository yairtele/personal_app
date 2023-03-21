import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:navigation_app/ui/ui_helper.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_state.dart';
import '../config/cache.dart';
import '../config/configuration.dart';
import '../router/ui_pages.dart';

class MoviePart2 extends StatefulWidget{
  const MoviePart2({Key? key}) : super(key: key);

  @override
  _MoviePart2State createState() => _MoviePart2State();
}

class _MoviePart2State extends State<MoviePart2> {

  late Future<ScreenData<void, String>> _localData;
  late String _userPhoto;

  @override
  void initState(){
    super.initState();
    _localData =  _getScreenData();
  }

  Future<ScreenData<void, String>> _getScreenData() => ScreenData<void, String>(dataGetter: _loadText).getScreenData();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return FutureBuilder<ScreenData<void, String>>(

        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<ScreenData<void, String>> snapshot) {

          Widget widget;
          if (snapshot.connectionState == ConnectionState.done &&  snapshot.hasData) {
            final data = snapshot.data!;
            final userInfo = data.userInfo;
            final textToShow = data.data!;
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
                      color: Colors.white),
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
                  ),
                ],
              ),
              body: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                  child: Text(textToShow)
              )
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

  Future<String> _loadText(void _) async {
    _userPhoto = 'assets/images/'+ (await Cache.getUserName())! + '_user.jpg';

    return rootBundle.loadString('assets/texts/movie_part2.txt');
  }

  Future<void> _refresh() async{
    setState(() {
      _localData =  _getScreenData();
    });
  }
}

