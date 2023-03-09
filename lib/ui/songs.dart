import 'package:flutter/material.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/batch_states.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/sp_ws/web_service_exception.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:navigation_app/ui/ui_helper.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../config/cache.dart';
import '../config/configuration.dart';
import '../router/ui_pages.dart';
import '../services/business/song.dart';
import '../web_services/smule_api.dart';

class Songs extends StatefulWidget{
  const Songs({Key? key}) : super(key: key);

  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  TextEditingController songTextController = TextEditingController();
  final FocusNode _focusNodeSong = FocusNode();
  var _songSearchColor = Configuration.customerSecondaryColor.withOpacity(0.3);
  var _songs;

  late Future<ScreenData<String, List<Song>>> _localData;

  @override
  void initState(){
    super.initState();
    _localData =  _getScreenData();
    _focusNodeSong.addListener(() {
      if(_focusNodeSong.hasFocus){
        setState(() {
          _songSearchColor = Configuration.customerSecondaryColor.withOpacity(0.75);
        });
      }
      else{
        setState(() {
          _songSearchColor = Configuration.customerSecondaryColor.withOpacity(0.3);
        });
      }
    });
  }

  Future<ScreenData<String, List<Song>>> _getScreenData({String? songText = ''}) => ScreenData<String, List<Song>>(dataGetter: _getPerformancesData).getScreenData(dataGetterParam: songText);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return FutureBuilder<ScreenData<void, List<Song>>>(

        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<ScreenData<dynamic, List<Song>>> snapshot) {

          Widget widget;
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            final data = snapshot.data!;
            final userInfo = data.userInfo;
            final songs = data.data!;
            final songsToShow = _songs ?? songs;
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
                body: SafeArea(
                  child: RefreshIndicator(child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        DataTable(
                          dataRowHeight: 55,
                          columns: <DataColumn>[
                            DataColumn(
                              label: Row(
                                  //mainAxisSize: MainAxisSize.min,
                                  children:[
                                    const Text(
                                      'Canciones',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                      ),
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                            border: const UnderlineInputBorder(),
                                            hintText: 'Search',
                                            filled: true,
                                            fillColor: _songSearchColor
                                        ),
                                        onChanged: (text){
                                          setState(() {
                                            if(text != ''){
                                              _songs = songs.where((s) => s.title.toUpperCase().contains(text.toUpperCase()) || s.message!.toUpperCase().contains(text.toUpperCase())).toList();
                                            //_localData = _getScreenData(songText: text);
                                            } else {
                                              _songs = songs;
                                            }
                                          });
                                        },
                                        controller: songTextController,
                                        focusNode: _focusNodeSong
                                      ),
                                    )
                                  ])
                            ),
                          ],
                          rows: List<DataRow>.generate (
                            songsToShow.length,
                          (int index) => DataRow(
                            cells: <DataCell>[
                              DataCell(
                                ListTile(
                                  //isThreeLine: true,
                                  leading: CircleAvatar(
                                        backgroundImage: NetworkImage(songsToShow[index].coverURL), // No matter how big it is, it won't overflow
                                  ),
                                  title: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,//y
                                    crossAxisAlignment: CrossAxisAlignment.start,//x
                                    children:[
                                      Text(
                                          songsToShow[index].title,
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
                                        )
                                      ),
                                      Text(
                                        '${songsToShow[index].message}',
                                        style: const TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey
                                        )
                                      )
                                    ]
                                ),
                              ),
                              onTap: () async {
                                final url = Configuration.songsURL + songsToShow[index].webURL;
                                if(await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                }else{
                                  print("URL can't be launched.");
                                }
                              }
                          )
                        ],
                      ),
                    ),
                  )
                  ]
                  )
                  ),
                      onRefresh: _refresh
                  )
                )
                            //const Text('Aca van las mejores canciones de los dos en listado, con titulo y mes + año. Mostrar reproductor de canciones al clickear en una')
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

  Future<List<Song>> _getPerformancesData(String? songText) async{

    //get actual user smule id
    final actualUser = await Cache.getUserName();
    final usersData =  Configuration.usersJson.entries;
    final filteredUsersData = usersData.where((e) => actualUser == e.key).map((u) => u.value['smuleId']).toList();
    final actualUserSmuleId = filteredUsersData[0];

    //get songs from that smule id
    var smuleSongs = await getSmuleSongs(actualUserSmuleId);

    //filter in case of search
    if(songText != ''){
      smuleSongs = smuleSongs.where((s) => s.title.contains(songText!) || s.message!.contains(songText)).toList();
    }

    return smuleSongs;
  }

  Future<void> _refresh() async{
    setState(() {
      _localData =  _getScreenData();
    });
  }
}